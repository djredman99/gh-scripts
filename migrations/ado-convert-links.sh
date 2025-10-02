#!/bin/bash
# filepath: /Users/djredman99/Source/gh-scripts/migrations/ado-convert-links.sh
# This script is intended to add AB#123 links to PRs in GitHub.  When using the ado2gh migration tool, the
# links it generates are in the form of "AzureDevOps/#12345" which is just a 1-way link to the work item URL.
# The Azure Boards integration uses AB#12345 links which will create a two-way link between the PR and the work item.

set -e

# Check if GH_TOKEN is set
if [ -z "$GH_TOKEN" ]; then
    echo "Error: GH_TOKEN environment variable is not set"
    exit 1
fi

# Check if repository is provided as argument
if [ -z "$1" ]; then
    echo "Usage: $0 "
    echo "Example: $0 microsoft/vscode"
    exit 1
fi

REPO=$1
echo "Processing repository: $REPO"

# Export GH_TOKEN for gh CLI
export GH_TOKEN

# Function to process a single PR
process_pr() {
    local pr_number=$1
    echo "Processing PR #$pr_number..."
    
    # Get current PR body
    local current_body=$(gh pr view $pr_number --repo $REPO --json body --jq '.body')
    
    # Check if PR body contains AzureDevOps links
    if echo "$current_body" | grep -q "AzureDevOps/#[0-9]"; then
        echo "  Found AzureDevOps links in PR #$pr_number"
        
        # Create new body with AB# links added
        local new_body=$(echo "$current_body" | sed 's/AzureDevOps\/#\([0-9][0-9]*\)/&\nAB#\1/g')
        
        # Check if AB# links were already present to avoid duplicates
        if echo "$current_body" | grep -q "AB#[0-9]"; then
            echo "  AB# links already exist in PR #$pr_number, skipping..."
            return
        fi
        
        # Update the PR body
        echo "$new_body" | gh pr edit $pr_number --repo $REPO --body-file -
        echo "  Successfully updated PR #$pr_number"
    else
        echo "  No AzureDevOps links found in PR #$pr_number"
    fi
}

# Get all PRs (both open and closed) and process them
echo "Fetching all PRs from $REPO..."
gh pr list --repo $REPO --state all --limit 1000 --json number --jq '.[].number' | while read pr_number; do
    process_pr $pr_number
    sleep 0.5  # Rate limiting to be respectful to GitHub API
done

echo "Script completed!"

