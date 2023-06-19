Import-Function -Name ConvertTo-Xlsx
$results = @();
$bulk = New-Object 'Sitecore.Data.BulkUpdateContext'
filter IsRendering {
    $templateName = $_.TemplateName
    
    if ($templateName -eq "Controller rendering") {
        $_
        Return
    }
    if ($templateName -eq "View rendering") {
        $_
        Return
    }
}

$renderingsRootItem = Get-Item -Path "master:/sitecore/layout/Renderings/Project"
$items = Get-ChildItem -Path $renderingsRootItem.ProviderPath -Recurse | IsRendering
try
{
    foreach ($i in $items){
        if($i -ne $null) {
            $referingCount = Get-ItemReferrer -Item $i -ErrorAction SilentlyContinue
        	$count = $referingCount | measure
        	$properties = @{
				ItemId   = $i.ID
				ItemName = $i.Name
				ItemPath = $i.Paths.FullPath	
				ItemReferringTo = $count.Count
			}
			$global:results += New-Object psobject -Property $properties
        }
    }
}
finally {
    $bulk.Dispose();
}
[byte[]]$outobject = $results | Select-Object -Property ItemId, ItemName, ItemPath, ItemReferringTo | ConvertTo-Xlsx
Out-Download -Name 'ProjectRenderingReport.xlsx' -InputObject $outobject