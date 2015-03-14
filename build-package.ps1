function BuildPackage {
    param(
        [string] $ReferenceFolder = 'C:\src\References\AppFabric',
        [string] $PackageNamePrefix = 'ICTEAM.References.',
        [string] $PackageNameSuffix = '',
        [string] $PackageVersion = '1.0.0',
		[string] $PackageDescription = "Generated package to replace $ReferenceFolder",
		[string] $PackageAuthors = 'ICTEAM',
		[string] $NetFramework = 'net40',
        [string] $TargetFolder = 'C:\packages',
		[string] $NuGet = 'NuGet.exe'
    )

    $BaseName = (Get-Item $ReferenceFolder).BaseName.Replace(" ", "")
    $MetadataId = "$PackageNamePrefix$BaseName$PackageNameSuffix"
	
    [xml] $NuSpecXml = '<?xml version="1.0"?><package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd"><metadata><id/><version/><description/><authors/></metadata><files><file src="" target="lib"/><file src="" target="lib"/></files></package>'
    $NuSpecXml.package.metadata.id = "$MetadataId"
    $NuSpecXml.package.metadata.version = "$PackageVersion"
	$NuSpecXml.package.metadata.description = "$PackageDescription"
	$NuSpecXml.package.metadata.authors = "$PackageAuthors"
    $NuSpecXml.package.files.file[0].src = "$ReferenceFolder\*.*"
	$NuSpecXml.package.files.file[0].target = "$NetFramework"
    $NuSpecXml.package.files.file[1].src = "$ReferenceFolder\**\*.*"
	$NuSpecXml.package.files.file[1].target = "$NetFramework"
	
	$NuSpecFile = [System.IO.Path]::GetTempFileName() + '.nuspec'

    $NuSpecXml.Save("$NuSpecFile")
    & "$NuGet" pack "$NuSpecfile" -NoPackageAnalysis -OutputDirectory "$TargetFolder" | Out-Null
	Remove-Item $NuSpecFile
}

#BuildPackage -ReferenceFolder 'C:\src\trunk\References\AppFabric'

#$ReferencesFolder = 'C:\src\trunk\References'
#Get-ChildItem "$ReferencesFolder" -Directory |% { "$ReferencesFolder\$_"} |% { BuildPackage -ReferenceFolder "$_" }





