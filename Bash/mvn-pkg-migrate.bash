
#!/bin/bash

# Set your variables
GITLAB_PROJECT_ID=""
GITLAB_TOKEN=""
GITHUB_USERNAME=""
GITHUB_TOKEN=""
GITHUB_REPO_NAME=""
SETTINGS_XML_PATH="./settings.xml"

# Set the initial page and per_page variables
page=1
per_page=100

while :
do
# Get the list of packages from GitLab
  response=$(curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "https://gitlab.com/api/v4/projects/$GITLAB_PROJECT_ID/packages?per_page=$per_page&page=$page")
    
  echo $response

  packages=$(echo "$response" | jq -r '.[] | @base64')
    
    
      # If no packages are returned, break the loop
    if [ -z "$packages" ]; then
          break
    fi

      # Loop over the packages
    for package in $packages; do
          # Decode the base64 string into a JSON object
          package_json=$(echo "$package" | base64 --decode | jq '.')

          #####echo "package_json: $package_json"

          # Now you can access the properties of the JSON object. For example:
          package_name=$(echo "$package_json" | jq -r '.name')
          echo "package_name: $package_name"

          # Get the versions of the package
          version=$(echo "${package_json}" | jq -r '.version')
          echo "version: $version"

          package_file_name="$package_name-$version.jar"
          
		  
         # converting / to . to put it as a group Id on pom.xml
          group_id=${package_name//\//.}
          group_id=${group_id%.*}
          echo "group id name is $group_id"

          ## taking only base name to put it as artifact_id in pom.xml
          id_name=$(basename "$package_name")

          ## conver to lower case since artifact id takes all lower case only 
          id_name="${id_name,,}"

          ## save the file name
          file_name="$id_name-${version}.jar"
          echo "file name is $file_name"
          echo "artifact id name is $id_name"

          echo "Downloading $file_name..."

          echo "command: https://gitlab.com/api/v4/projects/$GITLAB_PROJECT_ID/packages/maven/$package_name/$version --output $file_name"

           #Download the package from GitLab
          curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "https://gitlab.com/api/v4/projects/$GITLAB_PROJECT_ID/packages/maven/$package_name/$version" --output "$file_name"

          ##Create a pom.xml file
          cat << EOF > pom.xml
            <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
            <modelVersion>4.0.0</modelVersion>
            <groupId>$group_id</groupId>
            <artifactId>$id_name</artifactId>
            <version>$version</version>
            <packaging>jar</packaging>
            <distributionManagement>
              <repository>
                <id>github</id>
                <name>GitHub Packages</name>
                <url>https://maven.pkg.github.com/QDXDSOSandboxOrg/$GITHUB_REPO_NAME</url>
              </repository>
            </distributionManagement>
          </project>
EOF
          cat pom.xml

          # Publish the package to GitHub
          mvn deploy -DpomFile=pom.xml  -s $SETTINGS_XML_PATH

          # Remove the downloaded package and file
          rm "$file_name"
        
    done
      ((page++))
done