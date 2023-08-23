# NOTE **** THIS SCRIPT IS UNTESTED ****
# This script will download all versions of a package from Artifactory 
# and push them to GitHub Packages using Maven

# This was GENERATED using CoPilot

# Set the Artifactory URL and repository path
$artifactoryUrl = "https://example.com/artifactory"
$repositoryPath = "libs-release-local"

# Set the GitHub Packages repository and package name
$githubPackagesRepository = "OWNER/REPOSITORY"
$packageName = "example-package"

# Set the Maven coordinates for the package
$groupId = "com.example"
$artifactId = "example-package"

# Get a list of all package versions from Artifactory
$versions = (Invoke-RestMethod -Method Get -Uri "$artifactoryUrl/api/search/versions?repos=$repositoryPath&g=$groupId&a=$artifactId" -Credential (Get-Credential)).results.version

# Loop through each package version and download it from Artifactory
foreach ($version in $versions) {
  Write-Host "Downloading ${artifactId}-${version}.jar from Artifactory..."
  Invoke-WebRequest -Uri "$artifactoryUrl/$repositoryPath/$($groupId.Replace('.', '/'))/$artifactId/$version/$artifactId-$version.jar" -Credential (Get-Credential) -OutFile "$artifactId-$version.jar"

  # Push the package to GitHub Packages using Maven
  Write-Host "Pushing ${artifactId}-${version}.jar to GitHub Packages..."
  mvn deploy:deploy-file `
    -DgroupId="$groupId" `
    -DartifactId="$artifactId" `
    -Dversion="$version" `
    -Dpackaging="jar" `
    -Dfile="$artifactId-$version.jar" `
    -DrepositoryId="github" `
    -Durl="https://maven.pkg.github.com/$githubPackagesRepository" `
    --settings "/path/to/settings.xml"
}