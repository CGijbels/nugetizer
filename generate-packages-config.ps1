function GeneratePackagesConfig {
    param(
        [string] $CsProjFile = 'C:\src\Solution\Project\Project.csproj',
		[string] $RelativePathToPackagesFolder = '..\packages\',
        [string] $OutputFile = (Split-Path $CsProjFile) + '\packages.config',
        [switch] $WhatIf
    )

    [xml] $Xml = Get-Content $CsProjFile
    $NsMgr = New-Object System.Xml.XmlNamespaceManager($Xml.NameTable)
    $NsMgr.AddNamespace("ns", "http://schemas.microsoft.com/developer/msbuild/2003")

    $PackageReferences = $Xml.SelectNodes("//ns:HintPath", $NsMgr) | 
        Where-Object { $_.InnerText -like "$RelativePathToPackagesFolder*" } |% {
            $Entry = $_.InnerText
            $RelativePathToPackagesFolder = '..\packages\'
            $RelativePathToPackagesFolderRegex = $RelativePathToPackagesFolder.Replace("\", "\\")
            $Pattern = "$RelativePathToPackagesFolderRegex(?<PackageName>.+?)\.(?<PackageVersion>\d+\.\d+.*?)\\lib\\(?<NetFramework>.*?)\\"
            $Result = $Entry -match $Pattern
            if($Result) {
                $PackageName = $Matches.PackageName
                $PackageVersion = $Matches.PackageVersion
                $NetFramework = $Matches.NetFramework
                New-Object PSObject -Property @{PackageName="$PackageName";PackageVersion="$PackageVersion";NetFramework="$NetFramework";CsProjFile="$CsProjFile";HintPath=$_.InnerText}
            }
        }

    $DistinctPackageReferences = $PackageReferences | Sort-Object -Property PackageName -Unique
    		
    $CsProjDir = Split-Path "$CsProjFile"
    $PackagesConfigLocation = "$CsProjDir\packages.config"

    [xml] $PackagesConfigXml = '<?xml version="1.0" encoding="utf-8"?><packages></packages>'
    if(Test-Path "$PackagesConfigLocation") {
        [xml] $PackagesConfigXml = Get-Content "$PackagesConfigLocation"
    }
   
    $DistinctPackageReferences |% {
        $PackageName = $_.PackageName
        $PackageVersion = $_.PackageVersion
        $NetFramework = $_.NetFramework
        
        # ignore those that exist already...
        $Xpath = "//package[@id='$PackageName']"
        if($PackagesConfigXml.SelectNodes($Xpath).Count -eq 0)
        {
            $PackageNode = $PackagesConfigXml.CreateElement("package")
            $PackageNode.SetAttribute("id", $PackageName)
            $PackageNode.SetAttribute("version", $PackageVersion)
            $PackageNode.SetAttribute("targetFramework", $NetFramework)
            $PackagesConfigXml.DocumentElement.AppendChild($PackageNode) | Out-Null
        }
    }
    
    if($WhatIf) {
        Write-Host "Would write the following to $OutputFile"
        $PackagesConfigXml.InnerXml
    } else {
        $PackagesConfigXml.Save("$OutputFile");
    }
}

#$BasePath = 'C:\src\trunk\'
#$CsProjFiles =  Get-ChildItem $BasePath -Name "*.csproj" -Recurse |% { "$BasePath\$_" }
#$CsProjFiles |% { GeneratePackagesConfig -CsProjFile "$_" }







