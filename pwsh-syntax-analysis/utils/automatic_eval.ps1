param(
    [string]$path
)

$folders = Get-ChildItem $path

foreach ($folder in $folders){

    Write-Host "***************"
    Write-Host $folder

    #extract .gold and .output files
    $gold = Get-ChildItem $folder\*.gold
    $output = Get-ChildItem $folder\*.output

    #take full path of .gold and .output files
    $gold_path = $gold.FullName
    $output_path = $output.FullName
    $csv_path = $folder.Name + ".csv"

    Write-Host $output_path $gold_path $csv_path
    python analyzer.py $output_path $gold_path $csv_path

}