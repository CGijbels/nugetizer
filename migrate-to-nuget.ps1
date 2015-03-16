function MigrateToNuget {
    param(
        [string] $CsProjFile = 'C:\src\trunk\ICTEAM.Solution\ICTEAM.Project1\ICTEAM.Project1.csproj',
		[string] $RelativePathToReferences = '..\..\References',
		[string] $PackageNamePrefix = 'ICTEAM.References.',
        [string] $PackageNameSuffix = '',
        [string] $PackageVersion = '1.0.0',
		[string] $NetFramework = 'net40',
		[string] $RelativePathToPackages = '..\packages',
		[switch] $WhatIf
    )

    [xml] $Xml = Get-Content "$CsProjFile"
    $NsMgr = New-Object System.Xml.XmlNamespaceManager($Xml.NameTable)
    $NsMgr.AddNamespace("x", "http://schemas.microsoft.com/developer/msbuild/2003")

    $Xml.SelectNodes("//x:HintPath", $NsMgr) | 
        Where-Object { $_.InnerText -like "$RelativePathToReferences*" } |% {			
			$BaseName = $_.InnerText.Substring("$RelativePathToReferences\".Length, $_.InnerText.IndexOf("\", "$RelativePathToReferences\".Length) - "$RelativePathToReferences\".Length)
			$PackageName = "$PackageNamePrefix$BaseName$PackageNameSuffix"
			
			$From = $_.InnerText
			$To = $_.InnerText.Replace("$RelativePathToReferences\$BaseName","$RelativePathToPackages\$PackageName.$PackageVersion\lib\$NetFramework")
			$_.InnerText = $To
			
			if($WhatIf) {
				Write-Host "Replace from: $From to: $To " #in $CsProjFile"
			}
        }
	
	if(!($WhatIf)) {
		$Xml.Save("$CsProjFile")  
	}	
}

#$BasePath = 'c:\src\trunk'
#Get-ChildItem $BasePath -Name '*.csproj' -Recurse |% { "$BasePath\$_" } |% { 
#	MigrateToNuget -CsProjFile "$_" -WhatIf -PackageNamePrefix '' -PackageNameSuffix '' -PackageVersion '1.0.0' -NetFramework 'net45' #-RelativePathToReferences '..\..\References' -$RelativePathToPackages '..\packages'
#}
