param(
    [string]$path
)

$folders = Get-ChildItem $path

foreach ($folder in $folders){

    Write-Host "***************"
    Write-Host $folder

    #extract .gold and .output files
    $output = Get-ChildItem $folder\*.output

    #take full path of .output files
    $output_path = $output.FullName
    python extract_output.py $output_path "$($folder.Name).output"

    Write-Host $output_path $output
    #.\exec_from_host $folder.Name $output_path

}