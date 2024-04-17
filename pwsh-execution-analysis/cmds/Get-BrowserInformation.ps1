function Get-BrowserInformation {
<#
    .SYNOPSIS
        Dumps Browser Information
        Author: @424f424f
        License: BSD 3-Clause
        Required Dependencies: None
        Optional Dependencies: None
    .DESCRIPTION
        Enumerates browser history or bookmarks
    .PARAMETER Browser
        Chrome, IE, Firefox or ALL
    .PARAMETER Datatype
        History or Bookmarks
    .PARAMETER UserName
        User to search
    .PARAMETER Search
        Term to search for
    .EXAMPLE
        Get-BrowserInformation -Browser IE -Datatype Bookmarks -UserName user1
        Get-BrowserInformation -Browser All -Datatype History -UserName user1 -Search "github"
#>
[CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $True)]
        [String[]]
        [ValidateSet("Chrome","IE","FireFox", "All")]
        $Browser = "All",

        [Parameter(Position = 1, Mandatory = $True)]
        [String[]]
        [ValidateSet("History","Bookmarks","All")]
        $DataType = "All",

        [Parameter(Position = 2)]
        [String]
        $Search = '',

        [Parameter(Position = 3, Mandatory = $True)]
        [String]
        $UserName = ''

    )

    function ConvertFrom-Json20([object] $item){ 
        #http://stackoverflow.com/a/29689642
        add-type -assembly system.web.extensions
        $ps_js=new-object system.web.script.serialization.javascriptSerializer
        return ,$ps_js.DeserializeObject($item)
    }

    function Get-ChromeHistory {
        $Path =  "c:\Users\$UserName\AppData\Local\Google\Chrome\User Data\Default\History"
        if (-not (Test-Path -Path $Path)) {
            Write-Warning "[!] Could not find Chrome History."
            return
        }
        $Regex = '([a-zA-Z]{3,})://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'
        Get-Content $Path | Select-String -Pattern $Regex -AllMatches | % { $_.Matches } | % { $_.Value } | Sort-Object -Unique |% {
            $Value = New-Object -TypeName PSObject -Property @{
                ChromeHistoryURL = $_
            }
            if ($Value -match $Search) {
                    $Value
            } 
        }
    }

    function Get-ChromeBookmarks {
        $Path = "c:\Users\$UserName\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
        if (-not (Test-Path -Path $Path)) {
            Write-Warning "[!] Could not find Chrome Bookmarks."
            return
        }
        $Json = Get-Content $Path
        $Jsondata = ConvertFrom-Json20($Json)
        $Objects = $Jsondata.roots.bookmark_bar.children
        $Objects.values | Select-String -AllMatches http |Foreach-Object {
            $Value = New-Object -TypeName PSObject -Property @{
                ChromeBookmarksURL = $_
            }
            if ($Value -match $Search) {
                    $Value
            } 
        }
    }

    function Get-InternetExplorerHistory {
        #https://crucialsecurityblog.harris.com/2011/03/14/typedurls-part-1/      
        $SidData = wmic useraccount Where "Name='$UserName'" get sid
        $Sid = $SidData[2].trim()
        $Path = "Registry::HKEY_USERS\$Sid\Software\Microsoft\Internet Explorer\TypedURLs"
        if (-not (Test-Path -Path $Path)) {
            Write-Warning "[!] Could not find IE History."
            return
        }
        Get-Item -Path $Path |% {
            $Key = $_
            $Key.GetValueNames() | % {
                $Value = $Key.GetValue($_)
                if ($Value -match $Search) {
                    New-Object -TypeName psobject -Property @{
                        InternetExplorerHistoryURL = $Value
                    }
                }          
            }  
        }   
    }

    function Get-InternetExplorerBookmarks {
        $Path = "c:\Users\$UserName\Favorites"
        if (-not (Test-Path -Path $Path)) {
            Write-Warning "[!] Could not find Internet Explorer Bookmarks."
            return
        }
        Get-ChildItem $Path -Filter *.url |
        Foreach-Object {
            Get-Content $_.FullName | Select-Object -Index 4 | Foreach-Object {
                $Value = New-Object -TypeName psobject -Property @{
                InternetExplorerURL = $($result.split("=")[1])
                }              
                if ($Value -match $Search) {
                    $Value
                }
            }
        }
    }

    function Get-FireFoxHistory {
        $Path = "c:\Users\$UserName\AppData\Roaming\Mozilla\Firefox\Profiles\"
        if (-not (Test-Path -Path $Path)) {
            Write-Warning "[!] Could not find FireFox History."
            return
        }
        $Profiles = Get-ChildItem "$Path\*.default\"
        $Regex = '([a-zA-Z]{3,})://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'
        Get-Content $Profiles\places.sqlite | Select-String -Pattern $Regex -AllMatches | % { $_.Matches } | % { $_.Value } | Sort-Object -Unique | % {
                    $Value = New-Object -TypeName PSObject -Property @{
                        FireFoxHistoryURL = $_
                    }
                    if ($Value -match $Search) {
                            $Value
                    } 
        }
    }

    function Get-FireFoxBookMarks {
        $Path = "c:\Users\$UserName\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
        if (-not (Test-Path -Path $Path)) {
            Write-Warning "[!] Could not find FireFox Bookmarks."
            return
        }
        $Json = Get-Content $Path
        $Output = ConvertFrom-Json20($Json)
        $Jsonobject = $Output.roots.bookmark_bar.children
        $Jsonobject.values |Select-String -AllMatches http |  Foreach-Object {
            $Value = New-Object -TypeName PSObject -Property @{
                FireFoxBookmarkURL = $_
            }
            if ($Value -match $Search) {
                    $Value
            }
        }
    }

    if(($Browser -Contains 'All') -or ($Browser -Contains 'Chrome')) {
        if (($DataType -Contains 'All') -or ($DataType -Contains 'History')) {
            Get-ChromeHistory
        }
        if (($DataType -Contains 'All') -or ($DataType -Contains 'Bookmarks')) {
            Get-ChromeBookmarks
        }
    }

    if(($Browser -Contains 'All') -or ($Browser -Contains 'IE')) {
        if (($DataType -Contains 'All') -or ($DataType -Contains 'History')) {
            Get-InternetExplorerHistory
        }
        if (($DataType -Contains 'All') -or ($DataType -Contains 'Bookmarks')) {
            Get-InternetExplorerBookmarks
        }
    }

    if(($Browser -Contains 'All') -or ($Browser -Contains 'FireFox')) {
        if (($DataType -Contains 'All') -or ($DataType -Contains 'History')) {
            Get-FireFoxHistory
        }
        if (($DataType -Contains 'All') -or ($DataType -Contains 'Bookmarks')) {
            Get-FireFoxBookMarks
        }
    }
}