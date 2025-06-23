# Claude YOLO Container Guide

Instructions for working in the Claude YOLO containerized environment.

## Directories

- `/workspace/projects/` - Reference repos (read-only)
- `/workspace/claude/` - Active workspaces (read-write)

**Rule**: Never modify `/workspace/projects/` repos.

## Workflow

1. Check if repo exists locally first: `ls /workspace/projects/` or `ls /workspace/claude/`
2. Work only in `/workspace/claude/`
3. Use git worktrees for parallel work

## Git Worktree Workflow

```bash
# Check if repo exists
cd /workspace/claude
ls -la | grep REPO_NAME

# If exists, update and create worktree
cd REPO_NAME
git checkout main && git pull
git worktree add ../REPO_NAME-feature -b $GIT_BRANCH_PREFIX/feature-name

# If not exists, clone from projects or GitHub
ls /workspace/projects/ | grep REPO_NAME
git clone ../projects/REPO_NAME/ REPO_NAME  # or from GitHub
cd REPO_NAME
git remote set-url origin https://github.com/OWNER/REPO_NAME.git  # fix remote
```

### Fix Git Remotes

```bash
# After cloning from projects/, fix the remote
git remote set-url origin https://github.com/OWNER/REPO_NAME.git
git remote -v  # verify
```

### Worktree Commands

```bash
git worktree list
git worktree add ../repo-feature -b $GIT_BRANCH_PREFIX/feature-name
git worktree remove ../repo-feature
git worktree prune
```

### Fix Worktree Paths (Required)

Worktrees use absolute paths that break in containers. Fix immediately:

```bash
# After creating worktree
find .git/worktrees -name "gitdir" -exec sed -i 's|/workspace/claude/|../|g' {} \;
git worktree list  # verify
```

### Cleanup

```bash
# Clean Rust builds
cargo clean
du -sh /workspace/claude/*/target

# Remove worktree
git worktree remove ../repo-feature
```

## Git Workflow

- Use `$GIT_BRANCH_PREFIX/` branch prefix
- Work stays local (no auto-push)
- Commit with clear messages

## Useful Commands

```bash
# Check available repos
ls /workspace/projects/
ls /workspace/claude/

# Monitor resources
df -h /workspace
free -h
```

## Code Guidelines

- Follow existing patterns
- Check dependencies exist
- Use project conventions
- Work only in `/workspace/claude/`

## Rules

**Don't:**
- Modify `/workspace/projects/`
- Create files outside `/workspace/claude/`
- Make up performance numbers

**Do:**
- Use `$GIT_BRANCH_PREFIX/` branch prefix
- Fix worktree paths after creating
- Test and measure changes
- Follow project conventions