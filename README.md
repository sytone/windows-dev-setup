# windows-dev-setup
scripts to quickly get a win 10 machine ready for development


```PowerShell
START http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/sytone/windows-dev-setup/master/boxstarterinvm
```


Manual install process

1.  Install box starter

```PowerShell
. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force
```

2.  Open the boxstarter console and run the following. If it reboots, log back in and it will continue.

```PowerShell
$package = "https://raw.githubusercontent.com/sytone/windows-dev-setup/master/boxstarterworkdesktop"
Install-BoxstarterPackage -PackageName $package
```
