#!/bin/bash

# Fetch both counts from notmuch
UNREAD_COUNT=$(notmuch count tag:inbox and tag:unread)
TOTAL_COUNT=$(notmuch count tag:inbox)

if [ "$UNREAD_COUNT" -gt 0 ]; then
    # State 1: You have unread mail (Red state)
    # Displays the UNREAD count
    printf '{"text": "%s", "alt": "unread", "class": "unread", "tooltip": "%s unread messages"}\n' "$UNREAD_COUNT" "$UNREAD_COUNT"

elif [ "$TOTAL_COUNT" -gt 0 ]; then
    # State 2: Mail exists, but it's all read (White state)
    # Displays the TOTAL count sitting in the inbox
    printf '{"text": "%s", "alt": "read", "class": "read-has-mail", "tooltip": "%s read messages in inbox"}\n' "$TOTAL_COUNT" "$TOTAL_COUNT"

else
    # State 3: Inbox is completely empty (Grey zero state)
    printf '{"text": "0", "alt": "empty", "class": "empty", "tooltip": "Inbox empty"}\n'
fi
