# Claude YOLO Container

Docker container for Claude Code with autonomous permissions in isolated environment.

## Setup

1. **Required**: Copy `.env.example` to `.env` and configure:
   ```bash
   cp .env.example .env
   # Edit .env with your git config, branch prefix, and public projects path
   ```

## Quick Start

```bash
docker compose run --rm claude-yolo
```

Runs Claude with bypassed permissions, mounts public projects (read-only) and workspaces (read-write).

## Commands

```bash
# Interactive mode
docker compose run --rm claude-yolo

# Shell access
docker compose run --rm --entrypoint bash claude-yolo

# Continue previous session
docker compose run --rm claude-yolo -c
```

## Shell Function

Add this function to your `.zshrc` or `.bashrc`:

```bash
yolo () {
        (
                cd ~/Projects/oss/claude-yolo && docker compose run --rm claude-yolo "$@"
        )
}
```

This function:
- Changes to the claude-yolo directory in a subshell
- Runs docker compose from the correct location
- Passes all arguments (`"$@"`) to the container
- Returns to your original directory when done

## Mounts

- `$PUBLIC_PROJECTS_PATH` → `/workspace/projects` (read-only)
- `$PUBLIC_PROJECTS_PATH/claude-workspaces` → `/workspace/claude` (read-write)
