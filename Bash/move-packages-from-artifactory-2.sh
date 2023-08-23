# NOTE **** THIS SCRIPT IS UNTESTESTED ****
# This script will download all versions of a package from Artifactory 
# and push them to GitHub Packages using Maven

# This was GENERATED using CoPilot

#!/bin/bash

# Set variables
ARTIFACTORY_URL="https://artifactory.example.com"
ARTIFACTORY_REPO_KEY="my-repo"
ARTIFACTORY_PACKAGE_NAME="my-package"
GITHUB_USERNAME="my-username"
GITHUB_TOKEN="my-token"
GITHUB_REPO_URL="https://maven.pkg.github.com/my-username/my-repo"
MAVEN_SETTINGS_FILE="/path/to/settings.xml"

# Get list of package versions from Artifactory
PACKAGE_VERSIONS=$(curl -s -u $ARTIFACTORY_USERNAME:$ARTIFACTORY_API_KEY "$ARTIFACTORY_URL/api/search/versions?repos=$ARTIFACTORY_REPO_KEY&name=$ARTIFACTORY_PACKAGE_NAME" | jq -r '.results[].version')

# Loop through each package version and push to GitHub Packages
for VERSION in $PACKAGE_VERSIONS
do
  mvn deploy:deploy-file \
    -DgroupId=com.example \
    -DartifactId=my-package \
    -Dversion=$VERSION \
    -Dpackaging=jar \
    -Dfile=$ARTIFACTORY_URL/$ARTIFACTORY_REPO_KEY/com/example/my-package/$VERSION/my-package-$VERSION.jar \
    -DrepositoryId=github \
    -Durl=$GITHUB_REPO_URL \
    --settings $MAVEN_SETTINGS_FILE
done