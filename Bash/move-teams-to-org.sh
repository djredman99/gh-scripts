#!/bin/bash

# Set your variables
SOURCE_ORG="djredman99-org"
TARGET_ORG="djredman99-test-org"
#GITHUB_TOKEN="xx"

# Function to get all teams from the source organization
get_teams() {
  curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/orgs/$SOURCE_ORG/teams"
}

# Function to get all members of a team
get_team_members() {
  local team_slug=$1
  curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/orgs/$SOURCE_ORG/teams/$team_slug/members"
}

# Function to create a team in the target organization
create_team() {
  local team_name=$1
  local team_slug=$2
  curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" -H "Content-Type: application/json" \
    -d "{\"name\": \"$team_name\", \"slug\": \"$team_slug\"}" \
    "https://api.github.com/orgs/$TARGET_ORG/teams"
}

# Function to add a member to a team in the target organization
add_team_member() {
  local team_slug=$1
  local username=$2
  curl -s -X PUT -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/orgs/$TARGET_ORG/teams/$team_slug/memberships/$username"
}

# Get all teams from the source organization
teams=$(get_teams)

# Loop through each team and recreate it in the target organization
echo "$teams" | jq -c '.[]' | while read -r team; do
  team_name=$(echo "$team" | jq -r '.name')
  team_slug=$(echo "$team" | jq -r '.slug')

  echo "Creating team $team_name in target organization..."
  create_team "$team_name" "$team_slug"

  # Get all members of the team
  members=$(get_team_members "$team_slug")

  # Loop through each member and add them to the new team in the target organization
  echo "$members" | jq -c '.[]' | while read -r member; do
    username=$(echo "$member" | jq -r '.login')
    echo "Adding member $username to team $team_name in target organization..."
    add_team_member "$team_slug" "$username"
  done
done