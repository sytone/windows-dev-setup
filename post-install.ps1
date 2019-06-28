<#
iex ((Invoke-WebRequest -UseBasicParsing -Uri ('https://raw.githubusercontent.com/sytone/windows-dev-setup/master/post-install.ps1?x={0}' -f (Get-Random)) -Headers @{"Pragma"="no-cache";"Cache-Control"="no-cache";}).Content)
#>

function Install-Font($url, $name, $family) {
    if (Test-Path "c:\windows\fonts\$name") {
        Write-Host "Font already installed"
    } else {
        Write-Host "c:\windows\fonts\$name is not found"
        Write-Host "Installing font $name from $url"
        New-Item "$($env:userprofile)\fontinstall" -ItemType Directory -Force | Out-Null
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile "$($env:userprofile)\fontinstall\$name" -UseDefaultCredentials
        $FONTS = 0x14
        $objShell = New-Object -ComObject Shell.Application
        $objFolder = $objShell.Namespace($FONTS)
        $objFolder.CopyHere("$($env:userprofile)\fontinstall\$name",0x10)
        remove-item "$($env:userprofile)\fontinstall" -Force -Recurse
    }
}
  
Set-ExecutionPolicy -ExecutionPolicy Unrestricted

$toolsPath = "c:\tools\"
$version = "1.0.4"

if((Test-Path "$toolsPath\$version.log")) {
    Write-Host "Current version ($version) already run, polling for update."
    Start-Sleep -Seconds 10 
    iex ((Invoke-WebRequest -UseBasicParsing -Uri ('https://raw.githubusercontent.com/sytone/windows-dev-setup/master/post-install.ps1?x={0}' -f (Get-Random)) -Headers @{"Pragma"="no-cache";"Cache-Control"="no-cache";}).Content)
    return
}

Write-Host "Version: $version"
Read-Host "Press enter when ready to start"

if((Test-Path $toolsPath)) {
    Write-Host "Tools folder already exists"
} else {
    New-Item -Path $toolsPath -ItemType Directory -Force | Out-Null
}

New-Item -Path "$toolsPath\$version.log" -Force | Out-Null

$installed = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" | foreach-object { $_.GetValue("DisplayName") }
if($installed.Contains("PowerShell 6-x64")) {
    Write-Host "PowerShell 6 already installed"
} else {
    $latestPowerShellCore = (Invoke-WebRequest -UseBasicParsing -Uri https://api.github.com/repos/PowerShell/PowerShell/releases/latest).Content | ConvertFrom-Json
    $downloadUrl = ($latestPowerShellCore.assets | ? {$_.name.Contains("win-x64.msi")}).browser_download_url
    $downloadName = ($latestPowerShellCore.assets | ? {$_.name.Contains("win-x64.msi")}).name
    Invoke-WebRequest -UseBasicParsing -Uri $downloadUrl -OutFile "./$downloadName"
    msiexec /i $downloadName /qb ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1
}
  
Install-Font "https://github.com/adobe-fonts/source-code-pro/releases/download/variable-fonts/SourceCodeVariable-Italic.ttf" "SourceCodeVariable-Italic.ttf" "Source Code Variable"
Install-Font "https://github.com/adobe-fonts/source-code-pro/releases/download/variable-fonts/SourceCodeVariable-Roman.ttf" "SourceCodeVariable-Roman.ttf" "Source Code Variable"
Install-Font "https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Bold.ttf?raw=true" "FiraCode-Bold.ttf" "Fira Code"
Install-Font "https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Light.ttf?raw=true" "FiraCode-Light.ttf" "Fira Code"
Install-Font "https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Medium.ttf?raw=true" "FiraCode-Medium.ttf" "Fira Code"
Install-Font "https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Regular.ttf?raw=true" "FiraCode-Regular.ttf" "Fira Code"
Install-Font "https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Retina.ttf?raw=true" "FiraCode-Retina.ttf" "Fira Code"
    
Invoke-WebRequest -UseBasicParsing -Uri ((((Invoke-WebRequest -UseBasicParsing -Uri https://api.github.com/repos/yangl900/azshell/releases/latest).Content | ConvertFrom-Json).assets | ? {$_.name.Contains("windows")}).browser_download_url) -OutFile "$($env:tmp)/azshell_windows_64-bit.zip"
Expand-Archive -Path "$($env:tmp)/azshell_windows_64-bit.zip" -DestinationPath "$($env:tmp)/azshell_windows_64-bit" -Force
Copy-Item -Path "$($env:tmp)/azshell_windows_64-bit/azshell.exe" -Destination "c:/tools/azshell.exe" -Force

if(Test-Path "$env:USERPROFILE\psf") {
    Write-Host "PSF Installed" 
} else {
    # Run in pwsh and powershell
    iex ((new-object net.webclient).DownloadString(('https://raw.github.com/sytone/PowerShellFrame/master/install.ps1?x={0}' -f (Get-Random))))
    . "$env:USERPROFILE\psf\localenv.ps1"
    iex ((Invoke-WebRequest -UseBasicParsing -Uri ('https://raw.githubusercontent.com/sytone/windows-dev-setup/master/post-install.ps1?x={0}' -f (Get-Random)) -Headers @{"Pragma"="no-cache";"Cache-Control"="no-cache";}).Content)
}

Add-DirectoryToPath -Directory $toolsPath

$ScriptsRoot = (Join-Path $env:USERPROFILE "Scripts")
if(((Test-Path $ScriptsRoot) -and ($env:OneDriveConsumer))) {
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


