Set-ExecutionPolicy -ExecutionPolicy Unrestricted
$latestPowerShellCore = (Invoke-WebRequest -UseBasicParsing -Uri https://api.github.com/repos/PowerShell/PowerShell/releases/latest).Content | ConvertFrom-Json
$downloadUrl = ($latestPowerShellCore.assets | ? {$_.name.Contains("win-x64.msi")}).browser_download_url
$downloadName = ($latestPowerShellCore.assets | ? {$_.name.Contains("win-x64.msi")}).name
Invoke-WebRequest -UseBasicParsing -Uri $downloadUrl -OutFile "./$downloadName"
msiexec /i $downloadName /qb ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1

# Run in pwsh and powershell
# iex ((new-object net.webclient).DownloadString(('https://raw.github.com/sytone/PowerShellFrame/master/install.ps1?x={0}' -f (Get-Random))))


$ScriptsRoot = (Join-Path $env:USERPROFILE "Scripts")
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


