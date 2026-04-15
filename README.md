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
alias pi-once='docker run -it --rm \
  -v "$(pwd):/workspace" \
  -v "${HOME}/.pi:/root/.pi" \
  -e OPENROUTER_API_KEY="${OPENROUTER_API_KEY}" \
  --name pi-agent-oneshot \
  pi-agent:root'

# builds, attaches/starts/creates same container 
alias pi-c=${HOME}/workspace/pi-docker/pi-agent.sh 

# in container run
pi
```

Optionally copy settings over:
```bash 
cp -r ./pi/* ${HOME}/.pi

```
