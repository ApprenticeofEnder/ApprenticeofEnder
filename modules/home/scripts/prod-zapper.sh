#!/usr/bin/env bash

function find_and_kill() {
  local TERM
  TERM="$1"
  PID=$(ps -aux | rg "$TERM" | rg -v rg | tail -n 1 | awk '{print $2}')
  [[ -n "$PID" ]] || return 0
  kill "$PID"
}

find_and_kill deadlock.exe
