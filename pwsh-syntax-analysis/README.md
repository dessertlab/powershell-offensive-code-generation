# pwsh-syntax-analyzer
![syntax-analysis](https://github.com/cridin1/pwsh-syntax-analysis/blob/main/static-analysis.png)

Static code analysis for PowerShell code. 
Make sure you have installed [PSScript Analyzer](https://github.com/PowerShell/PSScriptAnalyzer).

```bash
PS > python analyzer.py -h                                                                 

     __        __           __           ___                                     __  ___  __
    |__) |  | /__` |__| __ /__` \ / |\ |  |   /\  \_/ __  /\  |\ |  /\  |    \ /  / |__  |__)
    |    |/\| .__/ |  |    .__/  |  | \|  |  /~~\ / \    /~~\ | \| /~~\ |___  |  /_ |___ |  \


usage: analyzer.py [-h] [-v [V]] [OUT_FILE] ANSWER_PATH [GROUND_TRUTH] [FROM_ESCAPE]

Python NLP wrapper for PowerShell syntax analysis through PSScript Analyzer

positional arguments:
  OUT_FILE      Output CSV file
  ANSWER_PATH   Answers text file path from the model
  GROUND_TRUTH  Ground truth text file path
  FROM_ESCAPE   Output files from ESCAPE

options:
  -h, --help    show this help message and exit
  -v [V]        Verbose
```

In `utils\analysis_classes.py`, the analysis is extended to different error types.
