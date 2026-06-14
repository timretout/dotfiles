#!/usr/bin/env bash

BLOG_DIR="$HOME/src/retout.co.uk"
cd "$BLOG_DIR" || exit 1

# 1. Get the Unix timestamp of the absolute latest commit affecting your blog posts
LAST_POST_TIME=$(git log -1 --format="%at" -- content/blog 2>/dev/null)

if [ -z "$LAST_POST_TIME" ]; then
    DAYS=0
    CLASS="fresh"
else
    # 2. Calculate the difference in integer days
    NOW=$(date +%s)
    DIFF=$((NOW - LAST_POST_TIME))
    DAYS=$((DIFF / 86400))
fi

# 3. Define your "Freshness" thresholds and assign Catppuccin classes
if [ "$DAYS" -le 7 ]; then
    CLASS="fresh"       # Posted within a week
elif [ "$DAYS" -le 21 ]; then
    CLASS="stale"       # Posted 1-3 weeks ago
else
    CLASS="ancient"     # It's been over 3 weeks
fi

# 5. Output raw JSON for Waybar
printf '{"text": "%dd 📝", "tooltip": "%d days since last publish.", "class": "%s"}\n' \
       "$DAYS" "$DAYS" "$CLASS"
