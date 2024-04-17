```                                                                                                 

                       _                                                              _               _
  _ __  __ __ __  ___ | |_    ___   ___  __ __  ___   __   ___   __ _   _ _    __ _  | |  _  _   ___ (_)  ___
 | '_ \ \ V  V / (_-< | ' \  |___| / -_) \ \ / / -_) / _| |___| / _ |  | ' \  / _  | | | | || | (_-< | | (_-<
 | .__/  \_/\_/  /__/ |_||_|       \___| /_\_\ \___| \__|       \__,_| |_||_| \__,_| |_|  \_, | /__/ |_| /__/
 |_|                                                                                      |__/


```

# PowerShell Execution Analysis

This repository contains scripts and configurations for analyzing PowerShell execution on Windows systems. It is inspired by the work of [IppSec's PowerSiem](https://github.com/IppSec/PowerSiem) and [Neo23x0's sysmon-config](https://github.com/Neo23x0/sysmon-config). The objective is to analyze dynamically the execution of AI-generated PowerShell commands or short scripts, then compare this execution with ground truth snippets.

## Overview

The provided scripts and configurations are designed to enhance visibility into PowerShell activity on Windows systems. By leveraging PowerShell logging and Sysmon configurations, this analysis tool helps in identifying PowerShell commands and activities. After the recording phase for reference and generated commands, there is an event filtering phase, then for each command precision and recall are computed by determining the correspondence between ground truth events (from the reference command) and target events (from the generated command). 

![Overview](https://github.com/cridin1/pwsh-execution-analysis/blob/main/exec-analysis.png)

PowerShell version: 5.1.19041.1645 (or compatible)

## Usage

### Virtual Machine Setup
1. Ensure that you have VirtualBox and VBoxManage installed.
2. Install a Windows virtual machine with the following name `Malware-VM-Windows`.
3. Clone the repository on the target VM.
4. Ensure that the VM username and password match in `exec-from-host.ps1`.
5. Ensure that PowerShell (`pwsh`) is running with administrative privileges.
6. Save a snapshot and update the id in `exec-from-host.ps1` script.

### Using the tool
To utilize the tools in this repository, follow these steps:
1. Clone or download this repository to your local machine.
2. Run the `exec-from-host.ps1` script with the appropriate parameters:

```PowerShell
.\exec-from-host.ps1 OUTPUT_DIR_PATH COMMANDS_PATH
```

In utils, you can find different scripts: <br />
`common_events_parser.py` extracts common events in different executions of the ground truth commands.<br />
`intersection_ground_truth.py` profiles the ground truth executions.<br />
`event_analysis.py` extracts precision and recall for each command, then calculates the overall execution f1-score.<br />

To execute the analysis you need to generate the outputs for both ground truth and generated commands through `exec-from-host.ps1`. For example: <br />
```
.\exec-from-host.ps1 output_folder1 commands.out
.\exec-from-host.ps1 output_folder2 commands_groundtruth.out
python utils\event_analysis.py --folder1 output_folder1 --folder2 output_folder2
```

Maybe you need to update `common_events_filter_merged.csv` with common events to filter out on your VM.

### Commands integration
In `cmds`, you can find a custom module to integrate malicious/custom commands into the PowerShell default configuration. You can easily add new commands to be executed.

### Results
In `results`, there are some of the results from different models.
