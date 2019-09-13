<#
iex ((Invoke-WebRequest -UseBasicParsing -Uri ('https://raw.githubusercontent.com/sytone/windows-dev-setup/master/post-install.ps1?x={0}' -f (Get-Random)) -Headers @{"Pragma"="no-cache";"Cache-Control"="no-cache";}).Content)
#>

function Install-Font() {
    param($url, $name, $family)
    if ((Test-Path "c:\windows\fonts\$name") -or (Test-Path "$($env:userprofile)\AppData\Local\Microsoft\Windows\Fonts\$name")) {
        Write-Host "$name already installed"
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

$installTemp = "$env:TMP/installtemp"
if(-not (Test-Path $installTemp)) {
    New-Item -Type Directory -Path $installTemp -ErrorAction SilentlyContinue | Out-Null
    Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/noseratio/choco/blob/master/wsudo/bin/wasudo.cmd?raw=true" -OutFile "$installTemp/wasudo.cmd"
    Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/noseratio/choco/blob/master/wsudo/bin/wasudox.cmd?raw=true" -OutFile "$installTemp/wasudox.cmd"
    Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/noseratio/choco/blob/master/wsudo/bin/wsudo.cmd?raw=true" -OutFile "$installTemp/wsudo.cmd"
    Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/noseratio/choco/blob/master/wsudo/bin/wsudoexec.ps1?raw=true" -OutFile "$installTemp/wsudoexec.ps1"
    Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/noseratio/choco/blob/master/wsudo/bin/wsudox.cmd?raw=true" -OutFile "$installTemp/wsudox.cmd"
    (get-item Function:\Install-Font).Definition | Set-Content "$installTemp/Install-Font.ps1"
}

$env:Path += ";$installTemp"

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$isUnrestricted = (Get-ExecutionPolicy) -eq "Unrestricted"
$toolsPath = "c:\tools\"
$version = "1.0.27"

if(-not $isUnrestricted) {
    wsudox powershell -NoProfile -Command "& {Set-ExecutionPolicy -ExecutionPolicy Unrestricted}"
}

if((Test-Path "$toolsPath\$version.log")) {
    Write-Host "Current version ($version) already run, polling for update."
    Start-Sleep -Seconds 10 
    iex ((Invoke-WebRequest -UseBasicParsing -Uri ('https://raw.githubusercontent.com/sytone/windows-dev-setup/master/post-install.ps1?x={0}' -f (Get-Random)) -Headers @{"Pragma"="no-cache";"Cache-Control"="no-cache";}).Content)
    return
}

Write-Host "Version: $version"

if((Test-Path $toolsPath)) {
    Write-Host "Tools folder already exists"
} else {
    Write-Host "Creating Tools folder"
    New-Item -Path $toolsPath -ItemType Directory -Force | Out-Null
}

New-Item -Path "$toolsPath\$version.log" -Force | Out-Null

$installed = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" | foreach-object { $_.GetValue("DisplayName") }
if($installed.Contains("PowerShell 6-x64")) {
    Write-Host "PowerShell 6 already installed"
} else {
    Write-Host "PowerShell 6 is being installed"
    $latestPowerShellCore = (Invoke-WebRequest -UseBasicParsing -Uri https://api.github.com/repos/PowerShell/PowerShell/releases/latest).Content | ConvertFrom-Json
    $downloadUrl = ($latestPowerShellCore.assets | ? {$_.name.Contains("win-x64.msi")}).browser_download_url
    $downloadName = ($latestPowerShellCore.assets | ? {$_.name.Contains("win-x64.msi")}).name
    Invoke-WebRequest -UseBasicParsing -Uri $downloadUrl -OutFile "c:\tools\$downloadName"
    wsudo msiexec /i c:\tools\$downloadName /qb ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1
}

if(Test-Path "C:\Program Files (x86)\Microsoft\Edge Dev\Application") {
    Write-Host "EdgeInsider already installed"
} else {
    Write-Host "EdgeInsider is being installed"
    Invoke-WebRequest -UseBasicParsing -Uri "https://c2rsetup.officeapps.live.com/c2r/downloadEdge.aspx?ProductreleaseID=Edge&platform=Default&version=Edge&Channel=Dev&language=en-us&Consent=1" -OutFile "c:\tools\MicrosoftEdgeSetup.exe"
    wsudo c:\tools\MicrosoftEdgeSetup.exe
    Remove-Item "c:\tools\MicrosoftEdgeSetup.exe" -Force -Recurse
}

if(Test-Path "C:\Program Files\Microsoft VS Code") {
    Write-Host "Visual Studio Code already installed"
} else {
    Write-Host "Visual Studio Code is being installed"
    $vscodeInf = @"
[Setup]
Lang=english
Dir=C:\Program Files\Microsoft VS Code
Group=Visual Studio Code
NoIcons=0
Tasks=addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath
"@
    $vscodeInf | Set-Content "c:\tools\vsinstall.inf"
    Invoke-WebRequest -UseBasicParsing -Uri "https://update.code.visualstudio.com/latest/win32-x64-user/stable" -OutFile "c:\tools\VSCodeSetup-x64.exe"
    wsudox c:\tools\VSCodeSetup-x64.exe /SP- /VERYSILENT /SUPPRESSMSGBOXES /FORCECLOSEAPPLICATIONS /LOADINF=./vsinstall.inf
    Remove-Item "c:\tools\VSCodeSetup-x64.exe" -Force -Recurse
    Remove-Item "c:\tools\vsinstall.inf" -Force -Recurse
}

if(Test-Path "C:\Program Files\Git") {
    Write-Host "GIT already installed"
} else {
    Write-Host "GIT is being installed"
    $gitInf = @"
[Setup]
Lang=default
Dir=C:\Program Files\Git
Group=Git
NoIcons=0
SetupType=default
Components=ext,ext\shellhere,ext\guihere,gitlfs,assoc,assoc_sh
Tasks=
EditorOption=VisualStudioCode
CustomEditorPath=
PathOption=Cmd
SSHOption=OpenSSH
CURLOption=OpenSSL
CRLFOption=CRLFAlways
BashTerminalOption=MinTTY
PerformanceTweaksFSCache=Enabled
UseCredentialManager=Enabled
EnableSymlinks=Disabled
EnableBuiltinInteractiveAdd=Disabled
"@
    $gitInf | Set-Content "$($env:tmp)/gitinstall.inf"
    $latestGit = (Invoke-WebRequest -UseBasicParsing -Uri https://api.github.com/repos/git-for-windows/git/releases/latest).Content | ConvertFrom-Json
    $downloadUrl = ($latestGit.assets | ? {$_.name.Contains("64-bit.exe")}).browser_download_url
    $downloadName = ($latestGit.assets | ? {$_.name.Contains("64-bit.exe")}).name
    Invoke-WebRequest -Verbose -UseBasicParsing -Uri $downloadUrl -OutFile "$($env:tmp)/$downloadName"
    if((Test-PAth "$($env:tmp)/$downloadName")) { Write-Host "Downloaded file exists" }
    wsudo $($env:tmp)/$downloadName /SP- /VERYSILENT /SUPPRESSMSGBOXES /FORCECLOSEAPPLICATIONS /LOADINF=$($env:tmp)/gitinstall.inf
    Remove-Item "$($env:tmp)/$downloadName" -Force -Recurse
    Remove-Item "$($env:tmp)/gitinstall.inf" -Force -Recurse
}

wsudo powershell -NoProfile -Command "& {$installTemp/Install-Font.ps1 'https://github.com/adobe-fonts/source-code-pro/releases/download/variable-fonts/SourceCodeVariable-Italic.ttf' 'SourceCodeVariable-Italic.ttf' 'Source Code Variable'; $installTemp/Install-Font.ps1 'https://github.com/adobe-fonts/source-code-pro/releases/download/variable-fonts/SourceCodeVariable-Roman.ttf' 'SourceCodeVariable-Roman.ttf' 'Source Code Variable'; $installTemp/Install-Font.ps1 'https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Bold.ttf?raw=true' 'FiraCode-Bold.ttf' 'Fira Code'; $installTemp/Install-Font.ps1 'https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Light.ttf?raw=true' 'FiraCode-Light.ttf' 'Fira Code'; $installTemp/Install-Font.ps1 'https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Medium.ttf?raw=true' 'FiraCode-Medium.ttf' 'Fira Code'; $installTemp/Install-Font.ps1 'https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Regular.ttf?raw=true' 'FiraCode-Regular.ttf' 'Fira Code'; $installTemp/Install-Font.ps1 'https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Retina.ttf?raw=true' 'FiraCode-Retina.ttf' 'Fira Code'; }"

if(Test-Path "c:/tools/azshell.exe") {
    Write-Host "azshell Installed" 
} else {
    Write-Host "AZShell is being installed"
    Invoke-WebRequest -UseBasicParsing -Uri ((((Invoke-WebRequest -UseBasicParsing -Uri https://api.github.com/repos/yangl900/azshell/releases/latest).Content | ConvertFrom-Json).assets | ? {$_.name.Contains("windows")}).browser_download_url) -OutFile "$($env:tmp)/azshell_windows_64-bit.zip"
    Expand-Archive -Path "$($env:tmp)/azshell_windows_64-bit.zip" -DestinationPath "$($env:tmp)/azshell_windows_64-bit" -Force
    Copy-Item -Path "$($env:tmp)/azshell_windows_64-bit/azshell.exe" -Destination "c:/tools/azshell.exe" -Force
}

if(Test-Path "$env:USERPROFILE\psf") {
  Write-Host "PSF Installed" 
} else {
  # Run in pwsh and powershell
  iex ((new-object net.webclient).DownloadString(('https://raw.github.com/sytone/PowerShellFrame/master/install.ps1?x={0}' -f (Get-Random))))
  . "$env:USERPROFILE\psf\localenv.ps1"
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

$installed = Get-AppxPackage | ? {$_.name -eq "Microsoft.WindowsTerminal"}
if($installed) {
  Write-Host "Windows Terminal is installed"
} else {
  start "ms-windows-store://pdp?productId=9N0DX20HK701&ocid=&cid=&referrer=github.com&scenario=click&webig=47ad3ce1-6e0d-4707-95dc-3291d58c9785&muid=1EB714941F9B6E61097319811E286FD9&websession=96429624c66e40449d9ed705ea3f738e&tduid="
}

