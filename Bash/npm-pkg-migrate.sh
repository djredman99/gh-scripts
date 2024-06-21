#!/bin/bash
GITHUB_TOKEN=""
GITLAB_TOKEN=""
GITLAB_PROJECT_ID=""

GITHUB_REPO=""

# Set the initial page and per_page variables
page=1
per_page=100

# Create a .npmrc file
echo "@ORG:registry=https://npm.pkg.github.com" > .npmrc
echo "//npm.pkg.github.com/:_authToken=$GITHUB_TOKEN" >> .npmrc


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
		
		### changing gitlab package name that starts with @gitlab group to @github org. 
        new_name=$(sed 's/@gitlabgroup/@ORG/g' <<< $package_name)
        echo "new_name: $new_name"    

        # Get the versions of the package
        version=$(echo "${package_json}" | jq -r '.version')
        echo "version: $version"

        package_file_name="$package_name-$version.tgz"
		
        ### removing @groupname from package name and just taking package name to zip
        file_name=${package_name#"@gitlabgroup/"}
        file_name="$file_name-${version}.tgz"
        echo "file name is $file_name"

        echo "Downloading $file_name..."

        echo "command: https://gitlab.com/api/v4/projects/$GITLAB_PROJECT_ID/packages/npm/$package_name/-/$package_file_name --output $file_name"

        # Download the package version from GitLab
        curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "https://gitlab.com/api/v4/projects/$GITLAB_PROJECT_ID/packages/npm/$package_name/-/$package_file_name" --output "$file_name"
       
       # Extract the package.json file from the tar file
        tar -xzf "$file_name" package/package.json

        # Move the package.json file to the current directory
        mv package/package.json .

        # Update the package.json file
        jq --arg name "$new_name" \
        '.name = $name' package.json > package.json.tmp && mv package.json.tmp package.json

        # Add publishConfig to the package.json file to publish on github package registry
        jq '. + {publishConfig: {registry: "https://npm.pkg.github.com/"}}' package.json > package.json.tmp && mv package.json.tmp package.json

        cat package.json

        # Authenticate with npm for GitHub Packages
        echo "//npm.pkg.github.com/:_authToken=$GITHUB_TOKEN" > .npmrc

        # publish the package to GitHub
        npm publish 
        
        # Remove the package tar file
        rm "$file_name"
    done

    # Increment the page number
    ((page++))
done
