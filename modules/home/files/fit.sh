#!/usr/bin/env bash

if ! [ -x "$(command -v docker)" ] && ! [ -x "$(command -v podman)" ]; then
  echo -e "Docker or Podman is not installed. Please install docker or podman and try again.\nDocker install guide: https://docs.docker.com/engine/install/\nPodman install guide: https://podman.io/getting-started/installation"
  exit 1
fi

# determine which docker command to use
if [ -x "$(command -v docker)" ]; then
  DOCKER_CMD="docker"
elif [ -x "$(command -v podman)" ]; then
  DOCKER_CMD="podman"
fi

if ! $DOCKER_CMD info > /dev/null 2>&1; then
  echo "$DOCKER_CMD daemon is not running. Please start $DOCKER_CMD and try again."
  exit 1
fi

TTY_FLAG=""

if [ -n $USE_TTY ]; then
  TTY_FLAG="-t"
fi

$DOCKER_CMD run \
  --rm -i \
  $TTY_FLAG \
  -v fit_vol:/app/Feenics \
  -v $(pwd):/app/scripts \
  -v "$HOME/Library/Application Support/Code/User:/app/vscode" \
  feenics/fit $@
