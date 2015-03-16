function ReplacePackage {
    param(
        [string] $CsProjFile = 'C:\src\trunk\ICTEAM.Solution\ICTEAM.Project1\ICTEAM.Project1.csproj',
		[string] $OriginalPackageName = 'ICTEAM.References.AutoMapper',
		[string] $OriginalPackageVersion = '1.0.0',
		[string] $NewPackageName = 'AutoMapper',
		[string] $NewPackageVersion = '3.3.0',		
		[string] $RelativePathToPackages = '..\packages',
		[switch] $WhatIf
    )

    [xml] $Xml = Get-Content "$CsProjFile"
    $NsMgr = New-Object System.Xml.XmlNamespaceManager($Xml.NameTable)
    $NsMgr.AddNamespace("x", "http://schemas.microsoft.com/developer/msbuild/2003")

	if($WhatIf)
	{
		Write-Host "running in demo mode... for $CsProjFile"
	}
	
    $Xml.SelectNodes("//x:HintPath", $NsMgr) | 
        Where-Object { $_.InnerText -like "$RelativePathToPackages\$OriginalPackageName.$OriginalPackageVersion\*" } |% {
			$OldHintPath = $_.InnerText
			$NewHintPath = $_.OldHintPath.Replace("$RelativePathToPackages\$OriginalPackageName.$OriginalPackageVersion", "$RelativePathToPackages\$NewPackageName.$NewPackageVersion")
			$_.InnerText = $NewHintPath
			
			if($WhatIf) {
				Write-Host "Would replace $OldHintPath with $NewHintPath in $CsProjFile"
			}
        }
	
	if(!($WhatIf)) {
		$Xml.Save("$CsProjFile") 
	}
}

#ReplacePackage -CsProjFile 'C:\src\trunk\ICTEAM.Solution\ICTEAM.Project1\ICTEAM.Project1.csproj'

#$BasePath = 'c:\src\trunk\'
#Get-ChildItem $BasePath -Name '*.csproj' -Recurse |% { "$BasePath\$_" } |% { 
#	ReplacePackage -CsProjFile "$_" -WhatIf
#}
