import pandas as pd
from functools import reduce
from event_analysis import parse_folder
import os

dfs1 = parse_folder(os.path.join(r"C:\Users\super\Desktop\tesi_magistrale\pwsh-execution-analysis\outputs\outputs-ground-truth\ground-truth-output", "xml"), name = "ground")
dfs2 = parse_folder(os.path.join(r"C:\Users\super\Desktop\tesi_magistrale\pwsh-execution-analysis\outputs\outputs-ground-truth\ground-truth-output2", "xml"), name = "ground")
dfs3 = parse_folder(os.path.join(r"C:\Users\super\Desktop\tesi_magistrale\pwsh-execution-analysis\outputs\outputs-ground-truth\ground-truth-output3", "xml"), name = "ground")
dfs4 = parse_folder(os.path.join(r"C:\Users\super\Desktop\tesi_magistrale\pwsh-execution-analysis\outputs\outputs-ground-truth\ground-truth-output4", "xml"), name = "ground")
dfs5 = parse_folder(os.path.join(r"C:\Users\super\Desktop\tesi_magistrale\pwsh-execution-analysis\outputs\outputs-ground-truth\ground-truth-output5", "xml"), name = "ground")

dfs1 = list(dfs1.values())
dfs2 = list(dfs2.values())
dfs3 = list(dfs3.values())
dfs4 = list(dfs4.values())
dfs5 = list(dfs5.values())

dfs = dfs1 + dfs2 + dfs3 + dfs4 + dfs5

final_df = reduce(lambda  left,right: pd.merge(left,right,
                                            how='inner'), dfs).drop_duplicates()

final_df.to_csv(f"common_events_filter_merged.csv", index=False)