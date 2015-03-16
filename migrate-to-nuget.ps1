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

    $Replacements = $Xml.SelectNodes("//x:HintPath", $NsMgr) | 
        Where-Object { $_.InnerText -like "$RelativePathToReferences*" } |% {			
			$BaseName = $_.InnerText.Substring("$RelativePathToReferences\".Length, $_.InnerText.IndexOf("\", "$RelativePathToReferences\".Length) - "$RelativePathToReferences\".Length)
			$PackageName = "$PackageNamePrefix$BaseName$PackageNameSuffix"
			
			$From = $_.InnerText
			$To = $_.InnerText.Replace("$RelativePathToReferences\$BaseName","$RelativePathToPackages\$PackageName\lib")
			$_.InnerText = $To
			New-Object PSObject -Property @{From=$From;To=$To;CsProjFile=$CsProjFile}
        }
		
	if($Replacements.Length -ne 0) {
		if($WhatIf) {
			Write-Host "Would replace the following hintpaths in $CsProjFile"
			$Replacements |% { 
				$From = $_.From
				$To = $_.To
				Write-Host "From: $From To: $To" }
		} else {
			$Xml.Save("$CsProjFile") 
		}
	}
}

$BasePath = 'c:\src\trunk\'
Get-ChildItem $BasePath -Name '*.csproj' -Recurse |% { "$BasePath\$_" } |% { 
	MigrateToNuget -WhatIf -CsProjFile "$_"
}
