#!/bin/bash

# Define the direction: "next" or "prev"
DIRECTION=$1

# Create the OPEN_WORKSPACES arrray and get a list of the active workspaces
OPEN_WORKSPACES=()
mapfile -t OPEN_WORKSPACES < <(hyprctl workspaces -j | jq -r '.[].name')

# Get the current workspace
current_workspace=$(hyprctl activeworkspace -j | jq -r '.name')

# Only the numbered workspaces, represented as numbers
NUMERICAL_WORKSPACES=()

# Use regular expressions to only extract the numbered workspaces
for element in "${OPEN_WORKSPACES[@]}"; do
  if [[ "$element" =~ ^[0-9]+$ ]]; then
    NUMERICAL_WORKSPACES+=("$element")
  fi
done

# Decide what to do depending on if moving to next workspace, or previous workspace
if [ "$DIRECTION" = "next" ]; then
  # This checks to see if the current workspace is the last workspace in the numberical
  # workspaces.
  if [ "$current_workspace" -eq "${NUMERICAL_WORKSPACES[-1]}" ]; then
    # If the current workspace is the last numerical workspace, then
    # only move to next workspace if the current workspace has at least 1 window
    # If the user tries to move to the right again on an empty workspace, they
    # will just cycle back to the beginning
    WINDOW_COUNT=$(hyprctl activeworkspace -j | jq -r '.windows')
    if [ "$WINDOW_COUNT" -ne 0 ]; then
      hyprctl dispatch workspace $((current_workspace + 1))
    else
      hyprctl dispatch workspace e+1
    fi
  # If the current workspace is not at the end, then cycle as normal
  else
    hyprctl dispatch workspace e+1
  fi
# If the intent is to go back to previous workspace, then normal back cycling is
# perfectly fine
elif [ "$DIRECTION" = "prev" ]; then
  hyprctl dispatch workspace e-1
fi
