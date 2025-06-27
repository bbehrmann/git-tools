# Git Tools

A collection of useful Git utilities for repository management and workflow automation.

## Tools

### git-branch-cleaner

A bash script that helps you identify and clean up stale branches across one or multiple Git repositories, including both local and remote branches on GitHub.

#### Features

- 🔍 **Smart Detection**: Finds branches older than a configurable number of days
- 🌐 **Remote Branch Scanning**: Scan and delete stale branches directly on GitHub server
- 🔄 **Pull Request Awareness**: Optional GitHub API integration to skip branches with active PRs
- 🎯 **Interactive Selection**: Choose which branches to delete with flexible input options
- 🛡️ **Safe Deletion**: Confirmation prompts and dry-run mode to prevent accidents
- 📁 **Multi-Repository**: Scan multiple repositories in a single run
- ⚙️ **Configurable**: Customizable settings via command-line options or config file

#### Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd git-tools
   ```

2. Make the script executable (if not already):
   ```bash
   chmod +x git-branch-cleaner
   ```

3. Optionally, add to your PATH for global access:
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   export PATH="$PATH:/path/to/git-tools"
   ```

#### Quick Start

```bash
# Scan current repository for branches older than 30 days
./git-branch-cleaner

# Scan with custom staleness period
./git-branch-cleaner --days 14

# Check for active pull requests (requires GitHub token)
./git-branch-cleaner --check-prs --token ghp_your_token_here

# Scan both local and remote branches on GitHub
./git-branch-cleaner --remote --token ghp_your_token_here

# Comprehensive scan with PR checking and remote branches
./git-branch-cleaner --check-prs --remote --token ghp_your_token_here

# Dry run to see what would be deleted
./git-branch-cleaner --dry-run

# Scan multiple repositories
./git-branch-cleaner /path/to/repo1 /path/to/repo2
```

#### Usage

```
Git Branch Cleaner - Find and delete stale branches

USAGE:
    git-branch-cleaner [OPTIONS] [REPO_PATHS...]

OPTIONS:
    -d, --days DAYS         Number of days to consider a branch stale (default: 30)
    -p, --check-prs         Check for active pull requests (requires GitHub token)
    -r, --remote            Also scan remote branches on GitHub server
    -t, --token TOKEN       GitHub token for PR checking and remote scanning
    -n, --dry-run          Show what would be deleted without actually deleting
    -e, --exclude PATTERN   Regex pattern for branches to exclude (default: main|master|develop|dev)
    -c, --config FILE       Use config file (default: ~/.git-branch-cleaner.conf)
    -h, --help             Show help message

EXAMPLES:
    # Scan current repo for branches older than 30 days
    git-branch-cleaner

    # Scan multiple repos with custom staleness period
    git-branch-cleaner -d 14 /path/to/repo1 /path/to/repo2

    # Check for active PRs before suggesting deletion
    git-branch-cleaner -p -t ghp_your_token_here

    # Scan both local and remote branches
    git-branch-cleaner -r -t ghp_your_token_here

    # Dry run to see what would be deleted
    git-branch-cleaner -n
```

#### Branch Selection

When stale branches are found, you can select which ones to delete using various input formats:

- **Individual branches**: `1,3,5`
- **Range**: `1-3` (selects branches 1, 2, and 3)
- **All branches**: `all`
- **No branches**: `none` or just press Enter

**Branch Types:**
- **Local branches**: Regular branch names (e.g., `feature/new-ui`)
- **Remote branches**: Marked with `[REMOTE]` prefix (e.g., `[REMOTE] feature/old-api`)

You can mix and match local and remote branches in your selection.

#### GitHub Token Setup

For pull request checking and remote branch scanning, you'll need a GitHub personal access token:

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate a new token with `repo` scope (required for both PR checking and remote branch operations)
3. Use the token with the `--token` option or set it in your config file

**Token Permissions Required:**
- `repo` scope for accessing repository information
- `delete_repo` scope for deleting remote branches (if you plan to delete remote branches)

#### Configuration File

Create `~/.git-branch-cleaner.conf` to set default options:

```bash
# Default staleness in days
STALE_DAYS=21

# GitHub token for PR checking and remote scanning
GITHUB_TOKEN="ghp_your_token_here"
CHECK_PRS=true
SCAN_REMOTE=true

# Custom branch exclusion pattern
EXCLUDE_BRANCHES="main|master|develop|dev|staging"
```

#### Requirements

- **bash** (version 4.0+)
- **git** (any recent version)
- **jq** (for GitHub API integration, required for remote scanning and PR checking)
- **curl** (for GitHub API integration, required for remote scanning and PR checking)

Install missing dependencies:

```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt install jq curl

# CentOS/RHEL
sudo yum install jq curl
```

#### Safety Features

- **Protected Branches**: Automatically excludes main/master/develop/dev branches (both local and remote)
- **PR Protection**: Skips branches with open pull requests (when enabled)
- **Confirmation Prompts**: Requires explicit confirmation before deletion
- **Dry Run Mode**: Preview changes without making them
- **Separate Handling**: Local and remote branches are handled separately with clear labeling
- **Error Handling**: Graceful handling of git command failures and API errors

#### Troubleshooting

**Q: Script says "Not a git repository"**
A: Make sure you're running the script from within a git repository or specify the correct path.

**Q: GitHub API requests are failing**
A: Verify your token has the correct permissions (`repo` scope) and isn't expired. For remote branch deletion, ensure you have sufficient permissions on the repository.

**Q: Branch deletion fails**
A: For local branches, check if the branch is currently checked out or has uncommitted changes. For remote branches, verify you have push permissions to the repository.

**Q: Remote branches aren't showing up**
A: Make sure you're using the `-r` flag and have provided a valid GitHub token. The repository must be hosted on GitHub.

**Q: Date calculation fails**
A: The script supports both GNU and BSD date formats. Make sure you have a standard date command available.

## Advanced Usage

### Remote Branch Management

The tool can now manage branches that exist only on the GitHub server:

```bash
# Scan only remote branches (useful for cleaning up the server)
./git-branch-cleaner -r -t ghp_your_token_here

# Full cleanup: local branches, remote branches, and PR checking
./git-branch-cleaner -p -r -t ghp_your_token_here -d 21
```

### Batch Operations

```bash
# Clean multiple repositories with remote scanning
for repo in ~/projects/*/; do
    echo "Processing $repo"
    ./git-branch-cleaner -r -p -t ghp_your_token_here "$repo"
done
```

## Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

## License

MIT License - see LICENSE file for details.