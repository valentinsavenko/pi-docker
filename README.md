# Pi Agent Docker Container

- https://pi.dev/ 

Pre-configured container with pi-coding-agent and recommended extensions/skills from awesome-pi-agent.

Simple container that mounts .pi settings and the current folder with a simple command. 
Pi agent has root and can install and play around safely - still can destroy your project, so git push everything! 

## Quick Start

```bash
# Build
docker build -t pi-agent:root .

# ------------------------------
# add commands to .bash_profile
# ------------------------------

# kills the container each time. all tools etc must be re-downloaded
alias pi='docker run -it -rm \
  -v "$(pwd):/workspace" \
  -v "${HOME}/.pi:/root/.pi" \
  -e OPENROUTER_API_KEY="${OPENROUTER_API_KEY}" \
  --name pi-agent \
  pi-agent:root'

# attaches/ starts / creates same container 
alias pipi=${HOME}/workspace/pi-docker/pi-agent.sh 
```

Optionally copy settings over:
```bash 
cp -r agent/* ${HOME}/.pi/agent

```
