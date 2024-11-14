#!/bin/bash

# Set your token in the GITHUB_TOKEN environment variable

# Variables
ORG="your_organization"
TEAM_SLUG="your_team_slug"
REPO="your_repo"
ACCESS_LEVEL="push"  # Change this to the desired access level (e.g., pull, push, admin)

# Check if curl is installed
if ! command -v curl &> /dev/null
then
    echo "curl could not be found, please install it."
    exit
fi

# Add repository to team
response=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/orgs/$ORG/teams/$TEAM_SLUG/repos/$ORG/$REPO" \
    -d "{\"permission\":\"$ACCESS_LEVEL\"}")

if [ "$response" -eq 204 ]; then
    echo "Repository successfully added to the team."
else
    echo "Failed to add repository to the team. HTTP status code: $response"
fi