#!/bin/bash

# Set your token in the GITHUB_TOKEN environment variable

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <org> <team> <user>"
    exit 1
fi

# Variables from command-line arguments
ORG=$1
TEAM_SLUG=$2
USERNAME=$3

# Check if GITHUB_TOKEN environment variable is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable is not set."
    exit 1
fi

# API request to add user to team
curl -X PUT -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/orgs/$ORG/teams/$TEAM_SLUG/memberships/$USERNAME

echo "User $USERNAME has been added to the team $TEAM_SLUG in the organization $ORG."