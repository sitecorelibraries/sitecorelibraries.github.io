[CmdletBinding()]
Param (
 [Parameter(Mandatory = $true)]
 [string]
 [ValidateNotNullOrEmpty()]
 $InstanceName,
 [Parameter(Mandatory = $true)]
 [string]
 [ValidateNotNullOrEmpty()]
 $LicenseXmlPath,
 [Parameter(Mandatory = $true)]
 [string]
 [ValidateNotNullOrEmpty()]
 $SitecoreAdminPassword,
 [Parameter(Mandatory = $true)]
 [string]
 [ValidateNotNullOrEmpty()]
 $SqlSaPassword
)

$ErrorActionPreference = "Stop";
if (-not (Test-Path $LicenseXmlPath)) {
 throw "Did not find $LicenseXmlPath"
}
if (-not (Test-Path $LicenseXmlPath -PathType Leaf)) {
 throw "$LicenseXmlPath is not a file"
}
# Check for Sitecore Gallery
Import-Module PowerShellGet
$SitecoreGallery = Get-PSRepository | Where-Object { $_.SourceLocation -eq "https://sitecore.myget.org/F/sc-powershell/api/v2" }
if (-not $SitecoreGallery) {
 Write-Host "Adding Sitecore PowerShell Gallery..." -ForegroundColor Green
 Register-PSRepository -Name SitecoreGallery -SourceLocation https://sitecore.myget.org/F/scpowershell/api/v2 -InstallationPolicy Trusted
 $SitecoreGallery = Get-PSRepository -Name SitecoreGallery
}
# Install and Import SitecoreDockerTools
$dockerToolsVersion = "10.0.5"
Remove-Module SitecoreDockerTools -ErrorAction SilentlyContinue
if (-not (Get-InstalledModule -Name SitecoreDockerTools -RequiredVersion $dockerToolsVersion -ErrorAction SilentlyContinue)) {
 Write-Host "Installing SitecoreDockerTools..." -ForegroundColor Green
 Install-Module SitecoreDockerTools -RequiredVersion $dockerToolsVersion -AllowPrerelease -Scope CurrentUser -Repository $SitecoreGallery.Name
}
Write-Host "Importing SitecoreDockerTools..." -ForegroundColor Green
Import-Module SitecoreDockerTools -RequiredVersion $dockerToolsVersion
# To generate environment file
Write-Host "Populating required .env file variables..." -ForegroundColor Green
Set-DockerComposeEnvFileVariable "SITECORE_ADMIN_PASSWORD" -Value $SitecoreAdminPassword
Set-DockerComposeEnvFileVariable "SQL_SA_PASSWORD" -Value $SqlSaPassword
Set-DockerComposeEnvFileVariable "TELERIK_ENCRYPTION_KEY" -Value (Get-SitecoreRandomString 128)
Set-DockerComposeEnvFileVariable "SITECORE_IDSECRET" -Value (Get-SitecoreRandomString 64 -DisallowSpecial)
$idCertPassword = Get-SitecoreRandomString 12 -DisallowSpecial
Set-DockerComposeEnvFileVariable "SITECORE_ID_CERTIFICATE" -Value (Get-SitecoreCertificateAsBase64String -DnsName "localhost" -Password (ConvertTo-SecureString -String $idCertPassword -Force -AsPlainText))
Set-DockerComposeEnvFileVariable "SITECORE_ID_CERTIFICATE_PASSWORD" -Value $idCertPassword
Set-DockerComposeEnvFileVariable "SITECORE_LICENSE" -Value (ConvertTo-CompressedBase64String -Path $LicenseXmlPath)
# To generate certificates 
Push-Location traefik\certs
try {
 $mkcert = ".\mkcert.exe"
 if ($null -ne (Get-Command mkcert.exe -ErrorAction SilentlyContinue)) {
 $mkcert = "mkcert"
 } elseif (-not (Test-Path $mkcert)) {
 Write-Host "Downloading and installing mkcert certificate tool..." -ForegroundColor Green 
 Invoke-WebRequest "https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcertv1.4.1-windows-amd64.exe" -UseBasicParsing -OutFile mkcert.exe
 if ((Get-FileHash mkcert.exe).Hash -ne "1BE92F598145F61CA67DD9F5C687DFEC17953548D013715FF54067B34D7C3246") {
 Remove-Item mkcert.exe -Force
 throw "Invalid mkcert.exe file"
 }
 }
 Write-Host "Generating Traefik TLS certificates..." -ForegroundColor Green
 & $mkcert -install
 & $mkcert -cert-file $InstanceName.cm.localhost.crt -key-file $InstanceName.cm.localhost.key "$InstanceName.cm.localhost"
 & $mkcert -cert-file $InstanceName.id.localhost.crt -key-file $InstanceName.id.localhost.key "$InstanceName.id.localhost"
}
catch {
 Write-Host "An error occurred while attempting to generate TLS certificates: $_" -ForegroundColor Red
}
finally {
 Pop-Location
}
Write-Host "Adding Windows hosts file entries..." -ForegroundColor Green
Add-HostsEntry "$InstanceName.cm.localhost"
Add-HostsEntry "$InstanceName.id.localhost"
Write-Host "Done!" -ForegroundColor Green