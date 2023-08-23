# NOTE **** THIS SCRIPT IS UNTESTESTED ****
# This script will download all versions of a package from Artifactory 
# and push them to GitHub Packages using Maven

# This was GENERATED using CoPilot

# Set the Artifactory URL and repository path
ARTIFACTORY_URL="https://example.com/artifactory"
REPOSITORY_PATH="libs-release-local"

# Set the GitHub Packages repository and package name
GITHUB_PACKAGES_REPOSITORY="OWNER/REPOSITORY"
PACKAGE_NAME="example-package"

# Set the Maven coordinates for the package
GROUP_ID="com.example"
ARTIFACT_ID="example-package"

# Get a list of all package versions from Artifactory
VERSIONS=$(curl -s -u USERNAME:API_KEY "${ARTIFACTORY_URL}/api/search/versions?repos=${REPOSITORY_PATH}&g=${GROUP_ID}&a=${ARTIFACT_ID}" | jq -r '.results[].version')

# Loop through each package version and download it from Artifactory
for VERSION in $VERSIONS; do
  echo "Downloading ${ARTIFACT_ID}-${VERSION}.jar from Artifactory..."
  curl -s -u USERNAME:API_KEY -o "${ARTIFACT_ID}-${VERSION}.jar" "${ARTIFACTORY_URL}/${REPOSITORY_PATH}/${GROUP_ID//.//}/${ARTIFACT_ID}/${VERSION}/${ARTIFACT_ID}-${VERSION}.jar"

  # Push the package to GitHub Packages using Maven
  echo "Pushing ${ARTIFACT_ID}-${VERSION}.jar to GitHub Packages..."
  mvn deploy:deploy-file \
    -DgroupId="${GROUP_ID}" \
    -DartifactId="${ARTIFACT_ID}" \
    -Dversion="${VERSION}" \
    -Dpackaging="jar" \
    -Dfile="${ARTIFACT_ID}-${VERSION}.jar" \
    -DrepositoryId="github" \
    -Durl="https://maven.pkg.github.com/${GITHUB_PACKAGES_REPOSITORY}" \
    -s "/path/to/settings.xml"
done

# Clean up the downloaded package files
rm "${ARTIFACT_ID}"-*.jar