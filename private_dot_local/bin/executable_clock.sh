#!/bin/bash

# Set how you want the time to look
DISPLAY_TIME=$(date +"%F %H:%M")

# 1. Grab the raw calendar output
CALENDAR_OUTPUT=$(ncal -b -h)

# 2. Build the tooltip text.
# We add the current date as a header, some spacing, and wrap the calendar in a monospace span.
TOOLTIP_TEXT="$(date +"%A, %B %d, %Y")

<span font_family='monospace'>${CALENDAR_OUTPUT}</span>"

# 3. JSON requires newlines to be escaped as "\n", so we replace literal newlines here
TOOLTIP_ESCAPED="${TOOLTIP_TEXT//$'\n'/\\n}"

# Get the current hour (0-23)
HOUR=$(date +"%-H")

# Check if the hour is 23 (11 PM) or in the early morning (0 to 4 AM)
if [ "$HOUR" -ge 23 ] || [ "$HOUR" -lt 5 ]; then
    CLASS="late"
else
    CLASS=""
fi

# Print the final JSON object
printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "$DISPLAY_TIME" "$TOOLTIP_ESCAPED" "$CLASS"
