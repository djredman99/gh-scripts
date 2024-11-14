#!/bin/bash

# Set your token in the GITHUB_TOKEN environment variable

# Function to create a team in the specified organization and link it to an IDP group
create_team() {
  local org_name=$1
  local team_name=$2
  local idp_group=$3
  curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" -H "Content-Type: application/json" \
    -d "{\"name\": \"$team_name\", \"ldap_dn\": \"$idp_group\"}" \
    "https://api.github.com/orgs/$org_name/teams"
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <org_name> <team_name> <idp_group>"
  exit 1
fi

# Check if GITHUB_TOKEN environment variable is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable is not set."
    exit 1
fi

# Assign arguments to variables
ORG_NAME=$1
TEAM_NAME=$2
IDP_GROUP=$3

# Create the team and link it to the IDP group
create_team "$ORG_NAME" "$TEAM_NAME" "$IDP_GROUP"