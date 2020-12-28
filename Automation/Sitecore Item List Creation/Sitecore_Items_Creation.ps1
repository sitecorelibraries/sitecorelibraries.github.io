#Script to generate Items from Listing file#

#$ItemListFilePath = Show-Input "Please provide ItemListing File Path as txt"
$TemplateType = Show-Input "From which Template items will be created?"
$currentItem = Get-Item .
$currentItemPath = $currentItem.FullPath

[string[]]$ItemList = Get-Content -Path 'C:\countryList.txt'

for($item in $ItemList)
{
	$newItem = new-item -Path $currentItemPath -Name $item -type $TemplateType
}
