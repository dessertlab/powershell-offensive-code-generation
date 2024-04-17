import pandas as pd
import os,ast,subprocess,argparse
import logging as lg
from  math import pow
from tqdm import tqdm

lg.basicConfig(format='%(asctime)s - %(message)s', datefmt='%d-%b-%y %H:%M:%S')

def extract_dataframe(answer_path, ground_truth="", FROM_ESCAPE=False) -> pd.DataFrame:

    if(FROM_ESCAPE == True):
        with open(answer_path, 'r') as f:
            list_answer = [elem.split("\t")[1].strip() for elem in f.readlines()]
        f.close()
        lg.debug("Extracted answers: " + str(len(list_answer)))
    else:
        with open(answer_path, 'r') as f:
            list_answer = [elem.strip() for elem in f.readlines()]
        f.close()
        lg.debug("Extracted answers: " + str(len(list_answer)))

    # with open(des_path, 'r') as f:
    #     #list_answer = ast.literal_eval(f.read())
    #     list_des = [elem.strip() for elem in f.readlines()]
    # f.close()
    # lg.debug("Extracted answers: " + str(len(list_des)))

    if(ground_truth != ""):
        if(FROM_ESCAPE == True):
            with open(ground_truth, 'r') as f:
                list_truth = [elem.split("\t")[1].strip() for elem in f.readlines()]
            f.close()
            lg.debug("Extracted truth: "+ str(len(list_truth)))
        else:
            with open(ground_truth, 'r') as f:
                list_truth = [elem.strip() for elem in f.readlines()]
            f.close()
            lg.debug("Extracted truth: "+ str(len(list_truth)))

        #df = pd.DataFrame(data={"Description": list_des,"Answer" : list_answer, 'Ground Truth': list_truth})
        df = pd.DataFrame(data={"Answer" : list_answer, 'Ground Truth': list_truth})

        lg.debug("Created dataframe: ")
        return df
    else:
        #df = pd.DataFrame(data={"Description": list_des,"Answer" : list_answer})
        df = pd.DataFrame(data={"Answer" : list_answer})
        lg.debug("Created dataframe: ")
        return df


def parse_output(answer) -> []:
    lg.debug(answer)

    current_dir = os.getcwd()
    
    with open("buffer.ps1", 'w') as f:
        f.write(answer)
    f.close()

    #pwsh o powershell a piacer del tuo WINDOWS
    result = subprocess.run(f'pwsh {os.path.join(current_dir,"parser.ps1")} {os.path.join(current_dir,"buffer.ps1")}', stdout=subprocess.PIPE, text=True)
    result = result.stdout.strip().split("--")
    result = [elem.strip("|").strip().strip("|") for elem in result]

    try: 
        result = [elem.split("|") for elem in result]
    except:
        pass
    
    lg.debug(result)
    return result

def add_results_compare(df, df_partial,FILE_CSV) -> pd.DataFrame:
    l = df.shape[0]
    N = df_partial.shape[0]
    for i,row in tqdm(df.iterrows(),total=l, colour='blue'):
        if(i>=N):
            answer,truth = row['Answer'], row['Ground Truth']
            answer_out = parse_output(answer)
            truth_out = parse_output(truth) 

            if(answer_out == ['']):
                answer_out = ['','','']

            if(truth_out == ['']):
                truth_out = ['','','']

            lg.debug(f"It: {i+1}/{l} Len_ans_out: {len(answer_out)} Len_truth_out: {len(truth_out)}")
            
            
            try:
                df_partial.loc[len(df_partial.index)] = answer_out+truth_out
            finally:
                df_partial.to_csv(FILE_CSV, index=False)

    df_out = pd.concat([df,df_partial], axis = 1)
    
    if(os.path.exists("buffer.ps1")):
        os.remove("buffer.ps1")

    return df_out

def add_results_single(df,df_partial,FILE_CSV) -> pd.DataFrame:
    l = df.shape[0]
    N = df_partial.shape[0]
    for i,row in tqdm(df.iterrows(), total=l, colour='blue'):
        if(i>=N):
            answer = row['Answer']
            answer_out = parse_output(answer)

            if(answer_out == ['']):
                answer_out = ['','','']

            lg.debug(f"It: {i+1}/{l} Len_ans_out: {len(answer_out)}")
            
            try:
                df_partial.loc[len(df_partial.index)] = answer_out
            finally:
                df_partial.to_csv(FILE_CSV, index=False)

    df_out = pd.concat([df,df_partial], axis = 1)

    if(os.path.exists("buffer.ps1")):
        os.remove("buffer.ps1")

    return df_out

def str2list(string):
    if(string == [''] or string == '' or string == ['']):
        return []
    else:
        return string[1:-1].split(",")

def calculate_syntax_metric_single(df) -> float:
    l = df.shape[0]
    count = 0
    skip_error_rule = ['RedirectionNotSupported', "MissingFileSpecification"] #["The '<' operator is reserved for future use. "]
    
    for i,row in df.iterrows():
        
        if(type(row['ANSWER Rulename']) == str):
            list_rulename = [elem.replace("'","").replace(" ","") for elem in str2list(row['ANSWER Rulename'])]
            list_severity = [elem.replace("'","").replace(" ","") for elem in str2list(row['ANSWER Severity'])]
        else:
            list_rulename = [elem.replace("'","").replace(" ","") for elem in row['ANSWER Rulename']]
            list_severity = [elem.replace("'","").replace(" ","") for elem in row['ANSWER Severity']]
        
        if(list_rulename == [] or list_rulename == ['']):
            continue
        
        list_a = list(zip(list_rulename,list_severity))
        
        list_a_filtered = []
        for elem_a in list_a:
            if(elem_a[1] == "ParseError" and  elem_a[0] not in skip_error_rule):
                list_a_filtered.append(elem_a)
        
        for j,elem in enumerate(list_a_filtered):
            if(elem[1] == 'ParseError'):
                count += 1
                lg.info(f"Answer: {row} {i}")
                break
    
    lg.info(f"Count valid ParseErrors: {count}/{l}")
    
    return round((1-count/l)*100,2)

def calculate_syntax_metric_double(df) -> float:
    l = df.shape[0]
    count= 0
    skip_error_rule = ['RedirectionNotSupported', "MissingFileSpecification"] #["The '<' operator is reserved for future use. "]
    
    for i,row in df.iterrows():
        
        if(type(row['ANSWER Rulename']) == str):
            list_rulename = [elem.replace("'","").replace(" ","") for elem in str2list(row['ANSWER Rulename'])]
            list_severity = [elem.replace("'","").replace(" ","") for elem in str2list(row['ANSWER Severity'])]
            list_rulename_t = [elem.replace("'","").replace(" ","") for elem in str2list(row['TRUTH Rulename'])]
            list_severity_t = [elem.replace("'","").replace(" ","") for elem in str2list(row['TRUTH Severity'])]
        else:
            list_rulename = [elem.replace("'","").replace(" ","") for elem in row['ANSWER Rulename']]
            list_severity = [elem.replace("'","").replace(" ","") for elem in row['ANSWER Severity']]
            list_rulename_t = [elem.replace("'","").replace(" ","") for elem in row['TRUTH Rulename']]
            list_severity_t = [elem.replace("'","").replace(" ","") for elem in row['TRUTH Severity']]
        
        list_a = list(zip(list_rulename, list_severity))
        list_b = list(zip(list_rulename_t, list_severity_t))
        
        list_a_filtered = []
        for elem_a in list_a:
            if(elem_a[1] == "ParseError" and  elem_a[0] not in skip_error_rule):
                list_a_filtered.append(elem_a)
        
        list_b_filtered = []      
        for elem_b in list_b:
            if(elem_b[1] == "ParseError" and elem_b[0] not in skip_error_rule):
                list_b_filtered.append(elem_b)
        
        list_equals = list(set(list_a_filtered) & set(list_b_filtered))
        
        for j,elem in enumerate(list_a_filtered):
            if(elem[1] == 'ParseError' and elem not in list_equals):
                count += 1
                lg.info(f"Answer: {elem} {i}")
                break
    
    lg.info(f"Count valid ParseErrors: {count}/{l}")
    
    return round((1-count/l)*100,2)


if __name__ == '__main__':
 
    print("""                                                                                                                                  
     __        __           __           ___                                     __  ___  __  
    |__) |  | /__` |__| __ /__` \ / |\ |  |   /\  \_/ __  /\  |\ |  /\  |    \ /  / |__  |__) 
    |    |/\| .__/ |  |    .__/  |  | \|  |  /~~\ / \    /~~\ | \| /~~\ |___  |  /_ |___ |  \ 
                                                                                            
    """)
    parser = argparse.ArgumentParser(description="Python NLP wrapper for powershell syntax analysis through PSScript Analyzer")
    #parser.add_argument("DESCRIPTION_PATH", help="Description text file path from the model")
    parser.add_argument("OUT_FILE", help="Output csv file", nargs='?',const="output.csv")
    parser.add_argument("ANSWER_PATH", help="Answers text file path from the model")
    parser.add_argument("GROUND_TRUTH", help="Ground truth text file path",nargs='?',  default="")
    parser.add_argument("FROM_ESCAPE", help="Output files from ESCAPE", type=bool, nargs="?", default=False)
    parser.add_argument("-v", help="Verbose", nargs='?', type=int, const=1, default=0)
    
    args = parser.parse_args()
    
    #DESCRIPTION_PATH = args.DESCRIPTION_PATH
    ANSWER_PATH = args.ANSWER_PATH
    GROUND_TRUTH = args.GROUND_TRUTH
    FROM_ESCAPE= args.FROM_ESCAPE
    OUT_FILE = args.OUT_FILE
    VERBOSE = args.v
    
    if(VERBOSE):
        lg.getLogger().setLevel(lg.DEBUG)
        lg.debug(vars(args))
    else:
        lg.getLogger().setLevel(lg.INFO)

    N = 0
    
    if(GROUND_TRUTH != ""):
        if((os.path.exists(OUT_FILE))):
            df_partial = pd.read_csv(OUT_FILE)
        else:
            df_partial = pd.DataFrame(columns=["ANSWER Rulename",'ANSWER Message','ANSWER Severity',
                                    "TRUTH Rulename",'TRUTH Message','TRUTH Severity'])
            
        df = extract_dataframe(ANSWER_PATH,GROUND_TRUTH,FROM_ESCAPE)
        df_out = add_results_compare(df, df_partial, OUT_FILE)
        
        print("Syntax metric single: ",calculate_syntax_metric_single(df_out))
        print("Syntax metric double: ",calculate_syntax_metric_double(df_out))
        
    else:
        if((os.path.exists(OUT_FILE))):
            df_partial = pd.read_csv(OUT_FILE)
        else:
            df_partial = pd.DataFrame(columns=["ANSWER Rulename",'ANSWER Message','ANSWER Severity'])
            
        df = extract_dataframe(ANSWER_PATH)
        df_out = add_results_single(df,df_partial,OUT_FILE)

        print("Syntax metric single: ",calculate_syntax_metric_single(df_out))
        
    df_out.to_csv(OUT_FILE, index=False)
    
