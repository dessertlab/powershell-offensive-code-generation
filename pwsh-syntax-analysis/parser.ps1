param(
    [string]$script_path
)


$array = Invoke-ScriptAnalyzer $script_path -Settings PSGallery
$result = ''
foreach ($elem in $array) {
    $result+=$elem.Rulename + " | "
}
$result += '--'
foreach ($elem in $array) {
    $result+=$elem.Message + " | "
}
$result += '--'
foreach ($elem in $array) {
    $result+=$elem.Severity.ToString() + " | "
}
echo $result

