function MigrateToNuget {
    param(
        [string] $CsProjFile = 'C:\src\trunk\ICTEAM.Solution\ICTEAM.Project1\ICTEAM.Project1.csproj',
		[string] $RelativePathToReferences = '..\..\References',
		[string] $PackageNamePrefix = 'ICTEAM.References.',
        [string] $PackageNameSuffix = '',
        [string] $PackageVersion = '1.0.0',
		[string] $NetFramework = 'net40',
		[string] $RelativePathToPackages = '..\packages'
    )

    [xml] $Xml = Get-Content "$CsProjFile"
    $NsMgr = New-Object System.Xml.XmlNamespaceManager($Xml.NameTable)
    $NsMgr.AddNamespace("x", "http://schemas.microsoft.com/developer/msbuild/2003")

    $Xml.SelectNodes("//x:HintPath", $NsMgr) | 
        Where-Object { $_.InnerText -like "$RelativePathToReferences*" } |% {
		
			$BaseName = $_.InnerText.Substring("$RelativePathToReferences\".Length, $_.InnerText.IndexOf("\", "$RelativePathToReferences\".Length) - "$RelativePathToReferences\".Length)
			$PackageName = "$PackageNamePrefix$BaseName$PackageNameSuffix"
			
			$To = $_.InnerText.Replace("$RelativePathToReferences\$BaseName","$RelativePathToPackages\$PackageName.$PackageVersion\lib\$NetFramework")
			$_.InnerText = $To
        }
	
	$Xml.Save("$CsProjFile")    
}
