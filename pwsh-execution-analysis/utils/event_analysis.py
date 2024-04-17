import xml.etree.ElementTree as etree
import pandas as pd
import os
import re
import argparse

def filter_entries(text) -> bool:
    raw_text = r"{}".format(text)
    patterns = [r"(output\d+\.txt$)", r"(__PSScriptPolicyTest)",r"(C:\\Users\\unina\\AppData\\Local\\Temp)", r"(\\dotnet-diagnostic-\d+)",
                r"(\\PSHost.\d+.\d+.DefaultAppDomain)",r"(C:\\Users\\unina\\AppData\\Local\\Microsoft\\PowerShell\\StartupProfileData-NonInteractive)",
                r"(C:\\Users\\unina\\AppData\\Local\\Microsoft\\Windows\\PowerShell\\StartupProfileData-NonInteractive)"]
    patterns = "|".join(patterns)
    found = re.search(patterns,raw_text)
    if(found == None): return True
    else: return False

def parse_xml(path, name="") -> pd.DataFrame:
    tree = etree.iterparse(path)
    ns = "{http://schemas.microsoft.com/win/2004/08/events/event}"

    data = []
    keys = ["Task", "Image", "CommandLine", "TargetFilename", 
            "ImageLoaded", "PipeName", "QueryName", "EventType",
            "TargetObject", "DestinationIp" ,"DestinationPort" ]
    
    common_events = pd.read_csv("common_events_filter_merged.csv")
    images = list(common_events["ImageLoaded"].unique())[1:] #skipping "-"
    if(name == "ground"):
        images = [] #take all images to find common events
    
    #for debug
    #keys+=["ProcessId","UtcTime", "ParentProcessId"]

    for _,eventID in tree:
        row = {}
        skip = False
        if eventID.tag == f"{ns}System":
            for attr in eventID.iter():
                if attr.tag == f'{ns}Task':
                    row['Task'] = attr.text
            
            #iterate until EventData
            _,next_element = next(tree)
            while(next_element.tag != f"{ns}EventData"):
                _,next_element = next(tree)

            if next_element.tag == f"{ns}EventData":
                for attr in next_element.iter():
                    if attr.tag == f'{ns}Data' and attr.get('Name') in keys:
                        if(filter_entries(attr.text)):
                            if(attr.get('Name') == "ImageLoaded" and attr.text in images):
                                skip = True
                                break
                            else:
                                row[attr.get('Name')] = attr.text
                        else:
                            skip = True
                            break
            
            #check if row is equal to a row in common_events
            if(skip == False and row != {}):
                data.append(row)

    output = []
    for row in data:
        row_out = []
        for key in keys:
            if key not in row:
                row[key] = "-"
            row_out.append(row[key])
        output.append(row_out)

    df = pd.DataFrame(output, columns=keys).drop_duplicates()
    if(name != "ground"):
        df = df[df["CommandLine"] != common_events["CommandLine"][0]] #remove common command
    return df

def compare_df(df1,df2):
    df_intersection = pd.merge(df1, df2, how='inner')
    
    if(df_intersection.shape[0] == 0):
        return 0,0, df_intersection
    
    #precision is the fraction of relevant instances among the retrieved instances
    p = df_intersection.shape[0]/df1.shape[0]
    #recall is the fraction of relevant instances that were retrieved.
    r = df_intersection.shape[0]/df2.shape[0]
    
    return round(p,2), round(r,2), df_intersection

def parse_folder(path, name = ""):
    elems = os.listdir(path)
    dfs = {}
    
    if(name != "csv"):
        for elem in elems:
            path_elem = os.path.join(path,elem)
            #print(path_elem)
            number = int(re.search(r"\d+",elem).group())
            dfs[number] = parse_xml(path_elem, name)
    else:
        for elem in elems:
            path_elem = os.path.join(path,elem)
            number = int(elem.split(".")[0])
            dfs[number] = pd.read_csv(path_elem, dtype=object)
            
    return dfs 

if __name__ == "__main__":
    
    argparse = argparse.ArgumentParser()
    argparse.add_argument("--folder1", help="path to first folder")
    argparse.add_argument("--folder2", help="path to second folder")
    #boolean argument
    argparse.add_argument("--gt", help="if true, the second folder is the ground truth", action="store_true")
    args = argparse.parse_args()
    
    dfs1 = parse_folder(os.path.join(args.folder1, "xml"))
    
    if(args.gt):
        dfs2 = parse_folder(os.path.join(args.folder2, ""), name = "csv")
        commands_1,commands_2 = open(os.path.join(args.folder1, "input.txt")).readlines(), open(r"C:\Users\super\Desktop\tesi_magistrale\pwsh-execution-analysis\exec_samples\exec_samples.out").readlines()

    else:
        dfs2 = parse_folder(os.path.join(args.folder2, "xml"))
        commands_1,commands_2 = open(os.path.join(args.folder1, "input.txt")).readlines(), open(os.path.join(args.folder2, "input.txt")).readlines()
    
    print("dfs extracted : ",len(dfs1), len(dfs2))

    overall_p = 0
    overall_r = 0
    
    i = 0
    for i in range(len(commands_1)):
        df1 = dfs1[i+1]
        df2 = dfs2[i+1]
        
        p,r, df_comm = compare_df(df1,df2)
        
        print(i+1)
        print(f"command1: {commands_1[i].strip()}")
        print(f"command2: {commands_2[i].strip()}")
        print("\n precision: {} recall: {} \ncommon entries: {} \ntarget entries: {} \nground truth entries: {}".format(p,r,df_comm.shape[0], df1.shape[0], df2.shape[0]))
        
        print("\n")

        #for debug
        # df_comm.to_csv(f"./temp/out_common_{i+1}.csv", index=False)
        # dfdiff = pd.concat([df1,df2]).drop_duplicates(keep=False)
        # dfdiff.to_csv(f"./temp/out_diff_{i+1}.csv", index=False)
        # df1.to_csv(f"./temp/out_{i+1}_1.csv", index=False)
        # df2.to_csv(f"./temp/out_{i+1}_2.csv", index=False)
        
        i+=1
        
        overall_p += p
        overall_r += r
    
    overall_p = round(overall_p/len(commands_1),5)
    overall_r = round(overall_r/len(commands_1),5)
    
    overall_f1 = round(2*(overall_p)*(overall_r)/((overall_p)+(overall_r)),5)
    
    print("overall precision: {} overall recall: {}".format(overall_p, overall_r))
    print("overall f1 score: {}".format(overall_f1))

    
    