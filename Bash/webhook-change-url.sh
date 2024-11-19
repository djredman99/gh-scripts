#!/bin/bash

# Set your token in the GITHUB_TOKEN environment variable

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GITHUB_TOKEN is not set."
  exit 1
fi

# Variables
WEBHOOK_ID="your_webhook_id"
ORG_OR_REPO="org_or_repo" # Set to "org" for organization or "repo" for repository
OWNER="owner_name"
REPO="repo_name" # Only needed if ORG_OR_REPO is "repo"

# Function to get current webhook URL
get_current_webhook_url() {
  local url
  if [ "$ORG_OR_REPO" == "org" ]; then
    url="https://api.github.com/orgs/$OWNER/hooks/$WEBHOOK_ID"
  else
    url="https://api.github.com/repos/$OWNER/$REPO/hooks/$WEBHOOK_ID"
  fi

  curl -s \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "$url" | jq -r '.config.url'
}

# Function to update webhook URL
update_webhook() {
  local current_url new_url
  current_url=$(get_current_webhook_url)
  appogee_url="https://appogee.com"
  # TODO: Replace "old_part" and "new_part" with the old and new parts of the URL
  new_url="${current_url/old_part/new_part}" # Modify this line to change the URL as needed

  local url
  if [ "$ORG_OR_REPO" == "org" ]; then
    url="https://api.github.com/orgs/$OWNER/hooks/$WEBHOOK_ID"
  else
    url="https://api.github.com/repos/$OWNER/$REPO/hooks/$WEBHOOK_ID"
  fi

  curl -X PATCH \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "$url" \
    -d "{\"config\": {\"url\": \"$new_url\"}}"
}

# Run the function
update_webhook