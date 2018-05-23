# windows-dev-setup
scripts to quickly get a win 10 machine ready for development


```PowerShell
START http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/sytone/windows-dev-setup/master/boxstarterinvm
```


Manual install process

```PowerShell
. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force
Install-BoxstarterPackage -PackageName http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/sytone/windows-dev-set
up/master/boxstarterworkdesktop
```
