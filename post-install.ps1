
function Install-Font($url, $name) {
  Write-Host "Installing font $name from $url"
  New-Item "$($env:userprofile)\fontinstall" -ItemType Directory -Force | Out-Null
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile "$($env:userprofile)\fontinstall\$name" -UseDefaultCredentials
  $FONTS = 0x14
  $objShell = New-Object -ComObject Shell.Application
  $objFolder = $objShell.Namespace($FONTS)
  $objFolder.CopyHere("$($env:userprofile)\fontinstall\$name")
  remove-item "$($env:userprofile)\fontinstall" -Force -Recurse
}


Set-ExecutionPolicy -ExecutionPolicy Unrestricted
$latestPowerShellCore = (Invoke-WebRequest -UseBasicParsing -Uri https://api.github.com/repos/PowerShell/PowerShell/releases/latest).Content | ConvertFrom-Json
$downloadUrl = ($latestPowerShellCore.assets | ? {$_.name.Contains("win-x64.msi")}).browser_download_url
$downloadName = ($latestPowerShellCore.assets | ? {$_.name.Contains("win-x64.msi")}).name
Invoke-WebRequest -UseBasicParsing -Uri $downloadUrl -OutFile "./$downloadName"
msiexec /i $downloadName /qb ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1

Install-Font "https://github.com/adobe-fonts/source-code-pro/releases/download/variable-fonts/SourceCodeVariable-Italic.ttf" "SourceCodeVariable-Italic.ttf"
Install-Font "https://github.com/adobe-fonts/source-code-pro/releases/download/variable-fonts/SourceCodeVariable-Roman.ttf" "SourceCodeVariable-Roman.ttf"
Install-Font "https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Bold.ttf?raw=true" "FiraCode-Bold.ttf"
Install-Font "https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Light.ttf?raw=true" "FiraCode-Light.ttf"
Install-Font "https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Medium.ttf?raw=true" "FiraCode-Medium.ttf"
Install-Font "https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Regular.ttf?raw=true" "FiraCode-Regular.ttf"
Install-Font "https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Retina.ttf?raw=true" "FiraCode-Retina.ttf"

# Run in pwsh and powershell
# iex ((new-object net.webclient).DownloadString(('https://raw.github.com/sytone/PowerShellFrame/master/install.ps1?x={0}' -f (Get-Random))))


$ScriptsRoot = (Join-Path $env:USERPROFILE "Scripts")
if(((Test-Path $ScriptsRoot))) {
  if((get-item -Path "$ScriptsRoot\AHK").LinkType -eq "SymbolicLink" -or (get-item -Path "$ScriptsRoot\powershell").LinkType -eq "SymbolicLink") {
    Write-Host "Already Linked, skipping Symbolic Link creation to Onedrive for Consumer"
  } else {
    Write-Host "Making the powershell and AHK script locations a symbolic link to onedrive consumer"
    Remove-Item -Path $ScriptsRoot -Recurse -Force
    if(-not (Test-Path $ScriptsRoot)) {
      New-Item $ScriptsRoot -ItemType Directory | Out-Null
    }
    New-Item -Path "$ScriptsRoot\powershell" -ItemType SymbolicLink -Value "$env:OneDriveConsumer\scripts\powershell"
    New-Item -Path "$ScriptsRoot\AHK" -ItemType SymbolicLink -Value "$env:OneDriveConsumer\scripts\AHK"
  }
}


