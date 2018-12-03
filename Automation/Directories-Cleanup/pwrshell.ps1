Param (
    [Parameter(Mandatory=$true)][string]$CleanupFilePath
)

$FolderList = New-Object System.Collections.ArrayList
$FolderList = Get-Content $CleanupFilePath

if ($FolderList.Count -gt 0)
{	
	foreach ($FolderName in $FolderList)
	{
		Get-ChildItem -Path $FolderName -Recurse | Remove-Item -Verbose
	}
}
