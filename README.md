# nugetizer

The last couple of years I have had the pleasure of helping a couple of organisations moving to NuGet.

In my experience the following plan has prooven itself to be succesful:

1. Build packages for each folder in libraries\references
2. Update all csproj files to replace all hintpaths pointing to ..\..\references with ..\packages
3. Build or find a more suitable package, migrate to that new package (Rinse and repeat)

The following scripts will be made available:
* build-package.ps1
* migrate-to-nuget.ps1
* replace-package.ps1
* generate-packages-config.ps1
