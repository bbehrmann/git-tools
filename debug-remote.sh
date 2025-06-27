#!/bin/bash

# Debug script to test remote branch scanning
set -x

GITHUB_TOKEN="${1:-}"
REPO_PATH="${2:-.}"

if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "Usage: $0 <github_token> [repo_path]"
    exit 1
fi

# Extract repo info
get_repo_info() {
    local repo_path="$1"
    local remote_url
    remote_url=$(git -C "$repo_path" remote get-url origin 2>/dev/null || echo "")
    
    if [[ -z "$remote_url" ]]; then
        echo "No remote URL found" >&2
        return 1
    fi
    
    echo "Remote URL: $remote_url" >&2
    
    # Parse GitHub repo from URL
    if [[ "$remote_url" =~ github.com[:/]([^/]+)/([^/.]+) ]]; then
        echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
        return 0
    fi
    
    echo "Not a GitHub repo" >&2
    return 1
}

repo_info=$(get_repo_info "$REPO_PATH")
echo "Repo info: $repo_info"

if [[ -z "$repo_info" ]]; then
    echo "Failed to get repo info"
    exit 1
fi

echo "Testing GitHub API call..."
api_url="https://api.github.com/repos/$repo_info/branches?per_page=10"
echo "API URL: $api_url"

response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$api_url")
echo "API Response:"
echo "$response" | jq . 2>/dev/null || echo "$response"

echo ""
echo "Parsing branch data..."
echo "$response" | jq -r '.[] | "\(.name)|\(.commit.commit.committer.date)|\(.commit.commit.committer.name)"' 2>/dev/null | head -5

echo ""
echo "Date comparison test..."
STALE_DAYS=30
cutoff_date=$(date -d "$STALE_DAYS days ago" +%Y-%m-%d 2>/dev/null || date -v-${STALE_DAYS}d +%Y-%m-%d 2>/dev/null)
echo "Cutoff date: $cutoff_date"

# Test with a sample date from API
test_date="2024-01-01T12:00:00Z"
branch_date=$(date -d "$test_date" +%Y-%m-%d 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$test_date" +%Y-%m-%d 2>/dev/null)
echo "Test date conversion: $test_date -> $branch_date"
echo "Is stale? $([[ "$branch_date" < "$cutoff_date" ]] && echo "YES" || echo "NO")"