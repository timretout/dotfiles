#!/bin/sh

# 1. Try to tell Sway to focus the window with our locked title.
# (The 2>/dev/null silences the "No matching node" error when it isn't open yet)
if ! swaymsg '[title="notmuch-mail"] focus' 2>/dev/null; then

    # 2. If Sway can't find it, launch a new client frame with the title locked
    # to "notmuch-mail" and immediately execute the notmuch buffer.
    emacsclient -c -F '((title . "notmuch-mail"))' --eval '(notmuch)'
fi
