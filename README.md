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

## Alias

```bash
alias yolo='docker compose -f $PUBLIC_PROJECTS_PATH/claude-workspaces/claude-yolo/docker-compose.yml run --rm claude-yolo'
```

## Mounts

- `$PUBLIC_PROJECTS_PATH` → `/workspace/projects` (read-only)
- `$PUBLIC_PROJECTS_PATH/claude-workspaces` → `/workspace/claude` (read-write)
