# Windows Development Machine Setup

Scripts to quickly get a win 10 machine ready for development

## Manual install process

1.  Install box starter

```PowerShell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted; . { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force
```

2.  Open the boxstarter console and run the following. If it reboots, log back in and it will continue.

```PowerShell
$package = "https://raw.githubusercontent.com/sytone/windows-dev-setup/master/boxstarterworkdesktop"
Install-BoxstarterPackage -PackageName $package
```

## More automated approach

Take this code and update username and password. It will run through the password and will allow auto login on a reboot. 

```
Write-Host "* Installing chocolatey"
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Write-Host "* Completed installing chocolatey"
$env:path += ";C:\ProgramData\chocolatey\bin"
Write-Host "Path: $env:path"

Write-Host "* Setting up the auto log in."
$DefaultUsername = "DOMAIN\ACCOUNT"
$DefaultPassword = "PASSWORD"
$AutoLogonCount = "50"
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String  
Set-ItemProperty $RegPath "DefaultUsername" -Value "$DefaultUsername" -type String  
Set-ItemProperty $RegPath "DefaultPassword" -Value "$DefaultPassword" -type String
Set-ItemProperty $RegPath "AutoLogonCount" -Value "$AutoLogonCount" -type DWord
Get-ItemProperty $RegPath "AutoAdminLogon"
Get-ItemProperty $RegPath "DefaultUsername"
Get-ItemProperty $RegPath "AutoLogonCount"

Write-Host "* Installing boxstarter"
choco install boxstarter --confirm
Write-Host "* Completed installing boxstarter"
$env:PSModulePath += ";C:\ProgramData\Boxstarter"

$package = "https://raw.githubusercontent.com/sytone/windows-dev-setup/master/boxstarterworkdesktop"
Install-BoxstarterPackage -PackageName $package
```

Once completed run the following command to clear the auto log in. 

```
Write-Host "* Cleaning up the auto log in."
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty $RegPath "AutoAdminLogon" -Value "0" -type String  
Set-ItemProperty $RegPath "DefaultUsername" -Value "" -type String  
Set-ItemProperty $RegPath "DefaultPassword" -Value "" -type String
Set-ItemProperty $RegPath "AutoLogonCount" -Value "0" -type DWord
Get-ItemProperty $RegPath "AutoAdminLogon"
Get-ItemProperty $RegPath "DefaultUsername"
Get-ItemProperty $RegPath "AutoLogonCount"
```

## Web

> Note: This does not work all the time in Windows 10.
```PowerShell
START http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/sytone/windows-dev-setup/master/boxstarterinvm
```

