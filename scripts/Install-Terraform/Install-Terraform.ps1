# Terraform - Download & Configure on Windows
# https://kpatnayakuni.com/2019/12/05/terraform-download-configure-on-windows-using-powershell/

# Ensure to run the function with administrator privilege 
if (-not (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{ Write-Host -ForegroundColor Red -Object "!!! Please run as Administrator !!!"; exit }
    
# Terrafrom download Url
$Url = 'https://www.terraform.io/downloads.html'
 
# Local path to download the terraform zip file
$DownloadPath = 'C:\Terraform\'
 
# Reg Key to set the persistent PATH 
$RegPathKey = 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment'
 
# Create the local folder if it doesn't exist
if ((Test-Path -Path $DownloadPath) -eq $false) { $null = New-Item -Path $DownloadPath -ItemType Directory -Force }
 
# Download the Terraform exe in zip format
$Web = Invoke-WebRequest -Uri $Url
$FileInfo = $Web.Links | Where-Object href -match windows_amd64
$DownloadLink = $FileInfo.href
$FileName = Split-Path -Path $DownloadLink -Leaf
$DownloadFile = [string]::Concat( $DownloadPath, $FileName )
Invoke-RestMethod -Method Get -Uri $DownloadLink -OutFile $DownloadFile
 
# Extract & delete the zip file
Expand-Archive -Path $DownloadFile -DestinationPath $DownloadPath -Force
Remove-Item -Path $DownloadFile -Force
 
# Setting the persistent path in the registry if it is not set already
if ($DownloadPath -notin $($ENV:Path -split ';')) {
    $PathString = (Get-ItemProperty -Path $RegPathKey -Name PATH).Path
    $PathString += ";$DownloadPath"
    Set-ItemProperty -Path $RegPathKey -Name PATH -Value $PathString
 
    # Setting the path for the current session
    $ENV:Path += ";$DownloadPath"
}
 
# Verify the download
Invoke-Expression -Command "terraform version"
