param(
    [string]$outdir = "output",
    [string]$path_commands = "example.out"
)

write-host 
"""

                       _                                                              _               _      
  _ __  __ __ __  ___ | |_    ___   ___  __ __  ___   __   ___   __ _   _ _    __ _  | |  _  _   ___ (_)  ___
 | '_ \ \ V  V / (_-< | ' \  |___| / -_) \ \ / / -_) / _| |___| / _` |  | ' \  / _`  | | | | || | (_-< | | (_-<
 | .__/  \_/\_/  /__/ |_||_|       \___| /_\_\ \___| \__|       \__,_| |_||_| \__,_| |_|  \_, | /__/ |_| /__/
 |_|                                                                                      |__/               

 
"""

mkdir $pwd\$outdir

$VMName = "Malware-VM-Windows"
$base_path="C:\Users\unina\Desktop\tesi\pwsh-execution-analysis"
$setup_path = "$base_path\setup.ps1"
$analysis_path = "$base_path\exec-analysis.ps1"

#Starting the test
VBoxManage snapshot $VMName restore b7a5cb3a-3952-4703-a1db-cbcf93357f6e
VBoxManage startvm $VMName --type headless
Start-Sleep -Seconds 30

$started = $false
while($started -eq $false){
    try{
        Write-Host "Trying to start VM..."
        $result = VBOxManage guestcontrol $VMName copyto --username unina --password unina --target-directory="$base_path\" $path_commands 2>&1 | Out-String
        $started = (-not ($result -Match "error"))
        Write-Host "VM started? " $started $result
        Start-Sleep -Seconds 30
    }
    catch{
        Write-Host $error[0].Exception.Message
        Write-Host "VM not yet started..."
        Start-Sleep -Seconds 10
    }
}

Write-Host "Vm Started and ready to execute commands"
VBOxManage guestcontrol $VMName --username unina --password unina run --exe C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe /file $setup_path  --wait-stdout
Start-Sleep -Seconds 5

$commands = Split-Path $path_commands -leaf
Write-Host "Executing the analysis..."
VBOxManage guestcontrol $VMName --username unina --password unina run --exe C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe /command "$analysis_path $commands > $base_path\log.txt" --no-wait-stdout

Start-Sleep -Seconds 10
#saving files
VBOxManage guestcontrol $VMName copyfrom --username unina --password unina --verbose --recursive --target-directory="$pwd\$outdir" C:\Users\unina\Desktop\tesi\pwsh-execution-analysis\output
VBOxManage guestcontrol $VMName copyfrom --username unina --password unina --verbose --target-directory="$pwd\$outdir\" C:\Users\unina\Desktop\tesi\pwsh-execution-analysis\log.txt

#save snapshot
VBoxManage controlvm $VMName acpipowerbutton --verbose

