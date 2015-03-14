# nugetizer

The last couple of years I have had the pleasure of helping a couple of organisations moving to NuGet.

In my experience the following plan has prooven itself to be succesful:

1. Build packages for each folder in libraries\references (Use build-package.ps1)
2. Update all csproj files to replace all hintpaths pointing to ..\..\references with ..\packages (Use migrate-to-nuget.ps1)
3. Repeatedly build or find a more suitable package and switch to that new package (Use replace-package.ps1)
4. Maintain your packages.config files (Use generate-packages-config.ps1)

