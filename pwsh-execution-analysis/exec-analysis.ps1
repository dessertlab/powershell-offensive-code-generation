param(
    [string]$path_commands = "example.txt",
    [string]$outdir = "output",
    [string]$config_file = "configs\sysmonconfig-excludes-only.xml"
)

$pwd_base="C:\Users\unina\Desktop\tesi\pwsh-execution-analysis"
$path_commands = "$pwd_base\$path_commands"
$outdir = "$pwd_base\$outdir"
$config_file = "$pwd_base\$config_file"

Function Parse-Event {
    # Credit: https://github.com/RamblingCookieMonster/PowerShell/blob/master/Get-WinEventData.ps1
    param(
        [Parameter(ValueFromPipeline=$true)] $Event
    )

    Process
    {
        foreach($entry in $Event)
        {
            $XML = [xml]$entry.ToXml()
            $X = $XML.Event.EventData.Data
            For( $i=0; $i -lt $X.count; $i++ ){
                $Entry = Add-Member -InputObject $entry -MemberType NoteProperty -Name "$($X[$i].name)" -Value $X[$i].'#text' -Force -Passthru
            }
            $Entry
        }
    }
}

Function Write-Alert ($alerts) {
    Write-Output "Type: $($alerts.Type)"
    $alerts.Remove("Type")
    foreach($alert in $alerts.GetEnumerator()) {
        Write-Output "$($alert.Name): $($alert.Value)"
    }
    Write-Output "-----"
}

Function Print-Logs($logs){
    foreach ($log in $logs) {
        $evt = $log | Parse-Event
        if ($evt.id -eq 1) {
            $output = @{}
            $output.add("Type", "Process Create")
            $output.add("PID", $evt.ProcessId)
            $output.add("Image", $evt.Image)
            $output.add("CommandLine", $evt.CommandLine)
            $output.add("CurrentDirectory", $evt.CurrentDirectory)
            $output.add("User", $evt.User)
            $output.add("ParentImage", $evt.ParentImage)
            $output.add("ParentCommandLine", $evt.ParentCommandLine)
            $output.add("ParentUser", $evt.ParentUser)
            write-alert $output
        }
        if ($evt.id -eq 2) {
            $output = @{}
            $output.add("Type", "File Creation Time Changed")
            $output.add("PID", $evt.ProcessId)
            $output.add("Image", $evt.Image)
            $output.add("TargetFilename", $evt.TargetFileName)
            $output.add("CreationUtcTime", $evt.CreationUtcTime)
            $output.add("PreviousCreationUtcTime", $evt.PreviousCreationUtcTime)
            write-alert $output
        }
        if ($evt.id -eq 3) {
            $output = @{}
            $output.add("Type", "Network Connection")
            $output.add("Image", $evt.Image)
            $output.add("DestinationIp", $evt.DestinationIp)
            $output.add("DestinationPort", $evt.DestinationPort)
            $output.add("DestinationHost", $evt.DestinationHostname)
            write-alert $output
        }
        if ($evt.id -eq 5) {
            $output = @{}
            $output.add("Type", "Process Ended")
            $output.add("PID", $evt.ProcessId)
            $output.add("Image", $evt.Image)
            $output.add("CommandLine", $evt.CommandLine)
            $output.add("CurrentDirectory", $evt.CurrentDirectory)
            $output.add("User", $evt.User)
            $output.add("ParentImage", $evt.ParentImage)
            $output.add("ParentCommandLine", $evt.ParentCommandLine)
            $output.add("ParentUser", $evt.ParentUser)
            write-alert $output
        }
        if ($evt.id -eq 6) {
            $output = @{}
            $output.add("Type", "Driver Loaded")
            write-alert $output
        }
        if ($evt.id -eq 7) {
            $output = @{}
            $output.add("Type", "DLL Loaded By Process")
            write-alert $output
        }
        if ($evt.id -eq 8) {
            $output = @{}
            $output.add("Type", "Remote Thread Created")
            write-alert $output
        }
        if ($evt.id -eq 9) {
            $output = @{}
            $output.add("Type", "Raw Disk Access")
            write-alert $output
        }
        if ($evt.id -eq 10) {
            $output = @{}
            $output.add("Type", "Inter-Process Access")
            write-alert $output
        }
        if ($evt.id -eq 11) {
            $output = @{}
            $output.add("Type", "File Create")
            $output.add("RecordID", $evt.RecordID)
            $output.add("TargetFilename", $evt.TargetFileName)
            $output.add("User", $evt.User)
            $output.add("Process", $evt.Image)
            $output.add("PID", $evt.ProcessID)
            write-alert $output
        }
        if ($evt.id -eq 12) {
            $output = @{}
            $output.add("Type", "Registry Added or Deleted")
            write-alert $output
        }
        if ($evt.id -eq 13) {
            $output = @{}
            $output.add("Type", "Registry Set")
            write-alert $output
        }
        if ($evt.id -eq 14) {
            $output = @{}
            $output.add("Type", "Registry Object Renamed")
            write-alert $output
        }
        if ($evt.id -eq 15) {
            $output = @{}
            $output.add("Type", "ADFS Created")
            write-alert $output
        }
        if ($evt.id -eq 16) {
            $output = @{}
            $output.add("Type", "Sysmon Configuration Change")
            write-alert $output
        }
        if ($evt.id -eq 17) {
            $output = @{}
            $output.add("Type", "Pipe Created")
            write-alert $output
        }
        if ($evt.id -eq 18) {
            $output = @{}
            $output.add("Type", "Pipe Connected")
            write-alert $output
        }
        if ($evt.id -eq 19) {
            $output = @{}
            $output.add("Type", "WMI Event Filter Activity")
            write-alert $output
        }
        if ($evt.id -eq 20) {
            $output = @{}
            $output.add("Type", "WMI Event Consumer Activity")
            write-alert $output
        }
        if ($evt.id -eq 21) {
            $output = @{}
            $output.add("Type", "WMI Event Consumer To Filter Activity")
            write-alert $output
        }
        if ($evt.id -eq 22) {
            $output = @{}
            $output.add("Type", "DNS Query")
            write-alert $output
        }
        if ($evt.id -eq 23) {
            $output = @{}
            $output.add("Type", "File Delete")
            $output.add("RecordID", $evt.RecordID)
            $output.add("TargetFilename", $evt.TargetFileName)
            $output.add("User", $evt.User)
            $output.add("Process", $evt.Image)
            $output.add("PID", $evt.ProcessID)
            write-alert $output
        }
        if ($evt.id -eq 24) {
            $output = @{}
            $output.add("Type", "Clipboard Event Monitor")
            write-alert $output
        }
        if ($evt.id -eq 25) {
            $output = @{}
            $output.add("Type", "Process Tamper")
            write-alert $output
        }
        if ($evt.id -eq 26) {
            $output = @{}
            $output.add("Type", "File Delete Logged")
            $output.add("RecordID", $evt.RecordID)
            $output.add("TargetFilename", $evt.TargetFileName)
            $output.add("User", $evt.User)
            $output.add("Process", $evt.Image)
            $output.add("PID", $evt.ProcessID)
            write-alert $output
        }
        $maxRecordId = $evt.RecordId
    }

}

Function Create-PowerShell-Process($output_file){
    $Process = New-Object System.Diagnostics.Process

    $ProcessStartInfoParam = [ordered]@{
        Arguments              = " -File $pwd_base\bufferone.ps1"
        CreateNoWindow         = $False
        FileName               = 'pwsh'
        WindowStyle            = 'Hidden'
        LoadUserProfile        = $False
        UseShellExecute        = $False
        RedirectStandardOutput = $True
        
    }

    $ProcessStartInfo = New-Object -TypeName 'System.Diagnostics.ProcessStartInfo' -Property $ProcessStartInfoParam
    $Process.StartInfo = $ProcessStartInfo
    $Process.Start()
    $Output = $Process.StandardOutput.ReadToEnd()
    $Output | Out-File -FilePath $output_file

    $Process.WaitForExit()

    return $Process
}

Function Export-Logs($lines){
    $i = 0
    $LogName = "Microsoft-Windows-Sysmon/Operational"
    $Provider = "Microsoft-Windows-Sysmon"
    $maxRecordId = (Get-WinEvent -Provider $Provider -max 1).RecordID
    
    foreach ($line in $lines)
    {
        Start-Sleep 1
        $i = $i + 1
        $maxRecordId = (Get-WinEvent -Provider $Provider -max 1).RecordID #testare se funziona
        
        Write-Output "Executing {$i}: $line"
        Write-Host "Executing {$i}: $line"
        $scriptBlock = [Scriptblock]::Create($line)
        Set-Content -Path "$pwd_base\bufferone.ps1" -Value $scriptBlock

        $Process = Create-PowerShell-Process "$outdir\txt\output$i.txt"
        $id = $Process.Id
        Write-Output "Executed {$i}: {$($Process.HasExited)} "
        Write-Host "Executed {$i}: {$($Process.HasExited)} "
    
        #$image = "C:\Program Files\PowerShell\7\pwsh.exe"
        
        $XPath="*[System[EventRecordID > $maxRecordId]]"
        try{
            $XPath_child = "*[System[EventRecordID > $maxRecordId] and EventData[Data[@Name='ParentProcessId'] = $id]]"
            $child_logs = Get-WinEvent -Provider $Provider -FilterXPath  $XPath_child -ErrorAction Stop | Select-Object -Property @{Name="Process Id";Expression={$_.Properties[3].Value}}
            $ids = $child_logs."Process Id"
            
            $XPath = "*[System[EventRecordID > $maxRecordId] and EventData[ Data[@Name='ProcessId'] = $id or "
            $j = 0
            foreach($id in $ids){
                if($j -eq 0){
                    $XPath += "Data[@Name='ProcessId'] = $id "
                }
                else{
                    $XPath += " or Data[@Name='ProcessId'] = $id "
                }
                $j++
            }
            $XPath += "]]"
            Write-Output $XPath
        
        }
        catch{
             $XPath = "*[System[EventRecordID > $maxRecordId] and EventData[Data[@Name='ParentProcessId'] = $id or Data[@Name='ProcessId'] = $id]]"
        }
 
        $SourceType = "LogName"
        $EvtSession = [System.Diagnostics.Eventing.Reader.EventLogSession]::New()
        try{
            $EvtSession.ExportLog($LogName, [System.Diagnostics.Eventing.Reader.PathType]::$SourceType, $XPath, "$outdir\evtx\output$i.evtx")
        }
        catch{
            Write-Output("Error")
            $EvtSession.Dispose()
            return
        }

        $EvtSession.ClearLog($LogName)
        $EvtSession.Dispose()
        $logs = Get-WinEvent -Path "$outdir\evtx\output$i.evtx"

        $xml = [xml]((wevtutil query-events "$outdir\evtx\output$i.evtx" /logfile /element:root) -replace "\x01","" -replace "\x0f","" -replace "\x02","")
        $xml.Save("$outdir\xml\output$i.xml")

        Print-Logs $logs
    }
}

function Load-Module ($m) {
	$m = [io.path]::GetFileNameWithoutExtension($m)

    # If module is imported say that and do nothing
    if (Get-Module | Where-Object {$_.Name -eq $m}) {
        Write-Output "Module $m is already imported."
    }
    else {
        Import-Module "$pwd_base\cmds\$m.ps1"
        Get-Module | Where-Object {$_.Name -eq $m}
    }
}


Function Start-Analysis($path_commands = "example.txt", $outdir = "$pwd_base\output"){
    whoami
    if (!(Test-Path "$outdir")) {
        New-Item -ItemType Directory -Path "$outdir"
    }

    if (!(Test-Path "$outdir\evtx")) {
        New-Item -ItemType Directory -Path "$outdir\evtx"
    }
    else{
        Write-Output "Alreadyy present evtx directory"
        return
    }

    if (!(Test-Path "$outdir\txt")) {
        New-Item -ItemType Directory -Path "$outdir\txt"
    }

    if (!(Test-Path "$outdir\xml")) {
        New-Item -ItemType Directory -Path "$outdir\xml"
    }

    #clearing dns
    ipconfig /flushdns

    Write-Output "Importing cmds"
	Import-Module C:\Windows\System32\WindowsPowerShell\v1.0\Modules\cmds

	Write-Output "Importing Powersploit"
	Import-Module C:\Windows\System32\WindowsPowerShell\v1.0\Modules\Powersploit

	Write-Output "All imported"
	

    Write-Output "Executing sysmon: "
    sysmon.exe -accepteula -i $config_file

    $lines = Get-Content -Path $path_commands
    Export-Logs($lines)

    cp $path_commands "$outdir\input.txt" 
    
    Write-Output "Uninstalling sysmon: "
    sysmon.exe -u
    Remove-Item "$pwd_base\bufferone.ps1"
}

Start-Analysis $path_commands $outdir