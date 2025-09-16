#!/bin/bash

CMD=$1

case "$CMD" in
  status)
    RUNNING=$(docker ps -q | wc -l)
    if [ "$RUNNING" -gt 0 ]; then
      echo "{\"text\": \"󰡨 $RUNNING\", \"tooltip\": \"Running containers: $RUNNING\"}"
    else
      echo "{\"text\": \"󰡧\", \"tooltip\": \"No containers running\"}"
    fi
    ;;
  
  list)
    docker ps --format '{{.Names}}' | jq -R -s -c 'split("\n")[:-1] | map({name: .}) | {items: .}'
    ;;

  toggle)
    CONTAINER="$2"
    if [ -z "$CONTAINER" ]; then
      echo "No container specified"
      exit 1
    fi

    STATUS=$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null)
    if [ "$STATUS" = "true" ]; then
      docker stop "$CONTAINER"
    else
      docker start "$CONTAINER"
    fi
    ;;
esac
