#!/bin/sh

on_exit() {
  trap - INT HUP QUIT TERM ALRM USR1
  echo "terminating..."
  exit 1
}

trap 'on_exit' INT HUP QUIT TERM ALRM USR1

while true; do
  sleep 1
  echo "tick"
done
