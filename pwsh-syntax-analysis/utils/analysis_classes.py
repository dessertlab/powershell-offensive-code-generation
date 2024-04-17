import pandas as pd
import logging as lg
import matplotlib.pyplot as plt
lg.basicConfig(format='%(asctime)s - %(message)s', datefmt='%d-%b-%y %H:%M:%S')


def str2list(string):
    if(string == [''] or string == '' or string == ['']):
        return []
    else:
        return string[1:-1].split(",")

def calculate_syntax_metric_single(df, tipo) -> float:
    l = df.shape[0]
    count = 0
    skip_error_rule = ['RedirectionNotSupported', 'MissingFileSpecification'] #["The '<' operator is reserved for future use. "]
    list_entries = []
    
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
        
        if(tipo != "ParseError"):
            found = False
            for elem_a in list_a:
                if(elem_a[1] == "ParseError" and  elem_a[0] not in skip_error_rule):
                    l -= 1
                    found = True
                    break
            if(found): continue
            
            for elem_a in list_a:
                if(elem_a[1] == tipo and  elem_a[0] not in skip_error_rule):
                    list_a_filtered.append(elem_a)
            
            for j,elem in enumerate(list_a_filtered):
                if(elem[1] == tipo):
                    count += 1
                    list_entries.append(elem[0])
        else:
            for elem_a in list_a:
                if(elem_a[1] == tipo and  elem_a[0] not in skip_error_rule):
                    list_a_filtered.append(elem_a)
            #if parse error is present, count only one
            for j,elem in enumerate(list_a_filtered):
                if(elem[1] == tipo):
                    count += 1
                    list_entries.append(elem[0])
                    break
        
    print(f"Count valid {tipo}: {count}/{l}")
    
    return round((count/l)*100,2),list_entries

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
                lg.debug(f"Answer: {elem} {i}")
                break
            elif(elem[1] == 'ParseError' and elem in list_equals):
                print(f"Answer: {elem} {i}")
                
    lg.info(f"Count valid ParseErrors: {count}/{l}")
    
    return round((1-count/l)*100,2)


file_list = ['codegen_pretrained.csv', 'codegpt_nopretrain.csv', 'codet5_pretrained.csv', 'groundtruth.csv']

for elem in file_list:
    df  = pd.read_csv(elem)
    percentage_parse, parse_errors_list = calculate_syntax_metric_single(df, "ParseError")
    percentage_error, error_list = calculate_syntax_metric_single(df, "Error")
    percentage_warning, warning_list = calculate_syntax_metric_single(df, "Warning")
    print(pd.Series(warning_list).value_counts())
    
    if(elem != 'groundtruth.csv'):
        doub = calculate_syntax_metric_double(df)
        
    print(elem)
    print(f"Percentage ParseError: {percentage_parse}")
    print(f"Percentage Error: {percentage_error}")
    print(f"Percentage Warning: {percentage_warning} \n")
    print(f"Percentage Double: {doub} \n")
