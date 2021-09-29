BEGIN
{
    $queries = New-Object System.Collections.ArrayList

    Function GetUrlStatus($Site)
    {
        try
        {
            $request = Invoke-WebRequest -Uri $Site
        }
        catch [System.Net.WebException]
        {
            if([int]$_.Exception.Response.StatusCode -eq 404)
            {
                $request = [PSCustomObject]@{Site=$site;ReturnCode=[int]$_.Exception.Response.StatusCode}
            }
            else
            {
                $request = [PSCustomObject]@{Site=$site;ReturnCode='another_thing'}
            }
        }
        catch
        {
            $request = [PSCustomObject]@{Site=$site;ReturnCode='request_failure'}
        }

        if($request.StatusCode)
        {
            $siteURI = $Site
            $response = $request.StatusCode
        }
        else
        {
            $response = $request.ReturnCode
        }
        return [PSCustomObject]@{Site=$Site;Response=$response}
    }
}
PROCESS
{
	$results = @()
	[string[]]$ItemList = Get-Content -Path 'D:\urls.txt'
	foreach ($item in $ItemList)
	{
		$status = GetUrlStatus -Site $item
		$details = @{
			Url			=$status.Site
			Status 		=$status.Response
		}
		$results += New-Object PSObject -Property $details
	}
	$results | export-csv -Path D:\reports.csv -NoTypeInformation
}
END{}
