#!/bin/bash
# Replace with your GitHub personal access token
GITHUB_TOKEN="<token>"

# Log in to GitHub CLI non-interactively
echo $GITHUB_TOKEN | gh auth login --with-token

# Replace with your organization name
ORG_NAME="<your org name>"

# List all repositories in the organization
#echo "-===== GET ORG REPOS =====-"
repos=$(gh repo list $ORG_NAME --json name --jq '.[].name')

# Loop through each repository
for repo in $repos; do
  # Fetch the CodeQL scan data using GitHub API
  #echo "-===== GET SCAN DATA FOR $repo =====-"
  scan_data=$(gh api repos/$ORG_NAME/$repo/code-scanning/analyses --jq '.[0]' 2>/dev/null)

  # Check if scan data is empty
  if [ -z "$scan_data" ]; then
    echo "Repository: $repo, No CodeQL Scan Data Available"
  else
    # Extract the last scan date
    last_scan_date=$(echo $scan_data | jq -r '.created_at')
    echo "Repository: $repo, Last CodeQL Scan Date: $last_scan_date"
  fi
done