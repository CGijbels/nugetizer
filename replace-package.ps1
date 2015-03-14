function ReplacePackage {
    param(
        [string] $CsProjFile = 'C:\src\trunk\ICTEAM.Solution\ICTEAM.Project1\ICTEAM.Project1.csproj',
		[string] $OriginalPackageName = 'ICTEAM.References.AutoMapper',
		[string] $OriginalPackageVersion = '1.0.0',
		[string] $NewPackageName = 'AutoMapper',
		[string] $NewPackageVersion = '3.3.0',		
		[string] $RelativePathToPackages = '..\packages'
    )

    [xml] $Xml = Get-Content "$CsProjFile"
    $NsMgr = New-Object System.Xml.XmlNamespaceManager($Xml.NameTable)
    $NsMgr.AddNamespace("x", "http://schemas.microsoft.com/developer/msbuild/2003")

    $Xml.SelectNodes("//x:HintPath", $NsMgr) | 
        Where-Object { $_.InnerText -like "$RelativePathToPackages\$OriginalPackageName.$OriginalPackageVersion\*" } |% {
			$NewHintPath = $_.InnerText.Replace("$RelativePathToPackages\$OriginalPackageName.$OriginalPackageVersion", "$RelativePathToPackages\$NewPackageName.$NewPackageVersion")
			$_.InnerText = $NewHintPath
        }
	
	$Xml.Save("$CsProjFile")    
}

#ReplacePackage -CsProjFile 'C:\src\trunk\ICTEAM.Solution\ICTEAM.Project1\ICTEAM.Project1.csproj'
