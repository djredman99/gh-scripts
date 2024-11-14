##!/bin/bash

# Function to create a team in the specified organization using GitHub CLI
create_team() {
  local org_name=$1
  local team_name=$2
  gh api -X POST "orgs/$org_name/teams" -f name="$team_name"
}

# Check if the user is authenticated with GitHub CLI
if ! gh auth status > /dev/null 2>&1; then
  echo "You are not authenticated with GitHub CLI. Please run 'gh auth login' to authenticate."
  exit 1
fi

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <org_name> <team_name>"
  exit 1
fi

# Assign arguments to variables
ORG_NAME=$1
TEAM_NAME=$2

# Create the team
create_team $ORG_NAME $TEAM_NAME