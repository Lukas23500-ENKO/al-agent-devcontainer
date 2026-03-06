# al-agent-devcontainer

> VS Code Dev Container for BC AL development with Claude Code.  
> Linux (Ubuntu) container + Claude Code agent + AL tooling.  
> Connects to BC SaaS Sandbox per project via `launch.json`.

---

## What's inside

| Tool | Purpose |
|---|---|
| Ubuntu 22.04 (LTS) | Base Linux environment |
| Claude Code v2+ | AI agent layer |
| PowerShell Core 7 | AL tooling scripts |
| AL Language extension | Installed automatically in container |
| Git | Version control |
| Node.js LTS | Required by Claude Code |

---

## Prerequisites

| Requirement | Notes |
|---|---|
| Windows 11 | Host OS |
| Docker Desktop | WSL2 backend enabled |
| VS Code Stable | With Dev Containers extension installed |
| Claude Code | Installed and authenticated on host |
| BC SaaS Sandbox | Configured per project in `launch.json` |

---

## Setup

### 1. Clone this repo

```bash
git clone https://github.com/{your-account}/al-agent-devcontainer.git
```

### 2. Clone your AL project repo

```bash
git clone https://github.com/{your-account}/{al-project}.git
```

### 3. Copy Dev Container config into your AL project

```bash
cp -r al-agent-devcontainer/.devcontainer {al-project}/.devcontainer
```

Or reference this repo directly — see "Shared config" below.

### 4. Open AL project in Dev Container

```
VS Code → Open Folder → {al-project}
Ctrl+Shift+P → Dev Containers: Reopen in Container
```

First build takes 3–5 minutes. Subsequent starts are fast (cached image).

### 5. Authenticate Claude Code inside the container

```bash
claude login
```

### 6. Verify AL tooling

```bash
pwsh scripts/validate-launch-config.ps1
```

---

## Shared config approach

Instead of copying `.devcontainer/` into every AL project, you can reference this repo as a git submodule:

```bash
cd {al-project}
git submodule add https://github.com/{your-account}/al-agent-devcontainer .devcontainer-shared
```

Then symlink or copy the `.devcontainer/` folder as needed.  
Full submodule setup documented in `docs/submodule-setup.md` (coming in a future update).

---

## Folder structure

```
al-agent-devcontainer/
├── .devcontainer/
│   ├── devcontainer.json        # VS Code Dev Container config
│   ├── Dockerfile               # Container image definition
│   └── docker-compose.yml       # Container orchestration
├── scripts/
│   ├── install-al-tools.sh      # AL tooling setup (runs on container build)
│   └── validate-launch-config.ps1  # Validates launch.json before development
└── README.md
```

---

## BC environment connection

This container does **not** run a local BC instance.  
All BC connectivity goes through the BC SaaS Sandbox defined in each project's `launch.json`.

The container includes the AL Language extension which handles authentication  
and publishing to the sandbox directly from VS Code.

---

## Updating the container

When `Dockerfile` or `devcontainer.json` changes:

```
Ctrl+Shift+P → Dev Containers: Rebuild Container
```
