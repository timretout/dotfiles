#!/usr/bin/env bash

WORKSPACE="blog"

# 1. ALWAYS switch to the workspace first
swaymsg workspace "$WORKSPACE"

# 2. SMART CHECK: If the workspace does NOT have any windows, launch Emacs
if ! swaymsg -t get_tree | jq -e ".. | select(.type? == \"workspace\" and .name == \"$WORKSPACE\") | (.nodes + .floating_nodes)[]" > /dev/null; then
    swaymsg exec "emacsclient -c -a '' --eval '(run-at-time 0 nil (quote my/hugo-new-post))'"
fi

# 3. ALWAYS ensure Emacs has active focus
swaymsg "[workspace=\"$WORKSPACE\" app_id=\"(?i)emacs\"] focus" 2>/dev/null || \
    swaymsg "[workspace=\"$WORKSPACE\" class=\"(?i)emacs\"] focus"
