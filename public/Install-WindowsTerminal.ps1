# iex ((Invoke-WebRequest -UseBasicParsing -Uri ('https://raw.githubusercontent.com/sytone/windows-dev-setup/master/post-install.ps1?x={0}' -f (Get-Random)) -Headers @{"Pragma"="no-cache";"Cache-Control"="no-cache";}).Content)



Write-Host "Installing the Windows Terminal with profile updates..."
$latestGit = (Invoke-WebRequest -UseBasicParsing -Uri https://api.github.com/repos/microsoft/terminal/releases).Content | ConvertFrom-Json
$downloadUrl = ($latestGit[0].assets | Where-Object { $_.name.Contains("msixbundle") }).browser_download_url
$downloadName = ($latestGit[0].assets | Where-Object { $_.name.Contains("msixbundle") }).name
Invoke-WebRequest -UseBasicParsing -Uri $downloadUrl -OutFile "$PSScriptRoot/$downloadName"
Add-AppxPackage "$PSScriptRoot/$downloadName" -ForceApplicationShutdown -ForceUpdateFromAnyVersion
Remove-Item "$PSScriptRoot/$downloadName" -Force -Recurse

$env:PSModulePath += ";$env:USERPROFILE\OneDrive - Microsoft\Documents\WindowsPowerShell\Modules"
Install-Module MSTerminalSettings -Scope CurrentUser -Repository PSGallery -Force

$terminalFolder = Find-MSTerminalFolder
Invoke-WebRequest -UseBasicParsing -Uri https://raw.githubusercontent.com/sytone/windows-dev-setup/master/cloud.png -OutFile "$terminalFolder\azure.png"
Invoke-WebRequest -UseBasicParsing -Uri https://raw.githubusercontent.com/sytone/windows-dev-setup/master/vs_2017_logo.png -OutFile "$terminalFolder\vs2017.png"
Invoke-WebRequest -UseBasicParsing -Uri https://raw.githubusercontent.com/sytone/windows-dev-setup/master/vs_2019_logo.png -OutFile "$terminalFolder\vs2019.png"

$vs2019 = @{
    Name              = "VS2019 Powershell"
    CommandLine       = 'C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoLogo -NoExit -File "C:\PROGRA~2\MIB055~1\2019\Preview\Common7\Tools\VsDevPs.ps1\"'
    Icon              = 'ms-appdata:///roaming/vs2019.png'
    ColorScheme       = 'Campbell'
    FontFace          = 'Fira Code'
    StartingDirectory = '%USERPROFILE%'
}
if(!(Get-MSTerminalProfile "VS2019 Powershell")) {
    New-MSTerminalProfile @vs2019
}

$vs2017 = @{
    Name              = "VS2017 Powershell"
    CommandLine       = 'C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoLogo -NoExit -File "C:\PROGRA~2\MIB055~1\2019\Preview\Common7\Tools\VsDevPs.ps1\"'
    Icon              = 'ms-appdata:///roaming/vs2017.png'
    ColorScheme       = 'Campbell'
    FontFace          = 'Fira Code'
    StartingDirectory = '%USERPROFILE%'
}
if(!(Get-MSTerminalProfile "VS2017 Powershell")) {
    New-MSTerminalProfile @vs2017
}

$azshell = @{
    Name              = "Azure Cloud Shell"
    CommandLine       = 'c:\tools\azshell.exe'
    Icon              = 'ms-appdata:///roaming/azure.png'
    ColorScheme       = 'Ubuntu'
    FontFace          = 'Fira Code'
    StartingDirectory = '%USERPROFILE%'
}
if(!(Get-MSTerminalProfile "Azure Cloud Shell")) {
    New-MSTerminalProfile @azshell
}

$Ubuntu = @{
    name = "Ubuntu"
    background  = "#2C001E"
    black       = "#EEEEEC"
    blue        = "#268BD2"
    brightBlack = "#002B36"
    brightBlue  = "#839496"
    purple      = "#D33682"
    red         = "#16C60C"
    white       = "#EEE8D5"
    yellow      = "#B58900"
}
if(!(Get-MSTerminalColorScheme "Ubuntu")) {
    New-MSTerminalColorScheme @Ubuntu
}

$UbuntuLegit = @{
    name = "UbuntuLegit"
    background   = "#2C001E"
    black        = "#4E9A06"
    blue         = "#3465A4"
    brightBlack  = "#555753"
    brightBlue   = "#729FCF"
    brightCyan   = "#34E2E2"
    brightGreen  = "#8AE234"
    brightPurple = "#AD7FA8"
    brightRed    = "#EF2929"
    brightWhite  = "#EEEEEE"
    brightYellow = "#FCE94F"
    cyan         = "#06989A"
    foreground   = "#EEEEEE"
    green        = "#300A24"
    purple       = "#75507B"
    red          = "#CC0000"
    white        = "#D3D7CF"
    yellow       = "#C4A000"
}
if(!(Get-MSTerminalColorScheme "UbuntuLegit")) {
    New-MSTerminalColorScheme @UbuntuLegit
}

Get-MSTerminalProfile | Set-MSTerminalProfile -FontFace "Fira Code"
