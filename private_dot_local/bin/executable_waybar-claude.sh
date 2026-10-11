#!/usr/bin/env bash

# Claude plan usage: 5-hour window and weekly limits.
# Uses the OAuth token Claude Code keeps in ~/.claude/.credentials.json;
# running `claude` in a terminal refreshes it.

CREDS="$HOME/.claude/.credentials.json"

error() {
    printf '{"text": "?", "alt": "error", "class": "error", "tooltip": "%s"}\n' "$1"
    exit 0
}

[ -r "$CREDS" ] || error "No Claude credentials found"

TOKEN=$(jq -r '.claudeAiOauth.accessToken // empty' "$CREDS")
EXPIRES_MS=$(jq -r '.claudeAiOauth.expiresAt // 0' "$CREDS")
[ -n "$TOKEN" ] || error "No Claude access token"

# Don't bother the API with a token we know has expired
if [ "$(( EXPIRES_MS / 1000 ))" -le "$(date +%s)" ]; then
    error "Token expired - run claude in a terminal to refresh"
fi

RESPONSE=$(curl -s -m 10 -f \
    -H "Authorization: Bearer $TOKEN" \
    -H "anthropic-beta: oauth-2025-04-20" \
    https://api.anthropic.com/api/oauth/usage) || error "Usage request failed"

echo "$RESPONSE" | jq -c '
    def ts: sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | fromdateiso8601;
    def left: (ts - now) | if . < 0 then 0 else . end
        | if . >= 86400 then "\(. / 86400 | floor)d\(. % 86400 / 3600 | floor)h"
          else "\(. / 3600 | floor)h\(. % 3600 / 60 | floor | tostring | if length < 2 then "0" + . else . end)m" end;
    def pct: (.utilization // 0) | round;
    def line($name): if . == null then empty
        else "\($name): \(pct)%" + (if .resets_at then ", resets in \(.resets_at | left)" else "" end) end;

    .five_hour as $h | .seven_day as $w
    | ([$h, $w, .seven_day_opus] | map(select(. != null) | .utilization // 0) | max) as $peak
    | {
        text: ("\($h | pct)%" + (if $h.resets_at then " \($h.resets_at | left)" else "" end) + " · wk \($w | pct)%"),
        tooltip: ([($h | line("5-hour")), ($w | line("Weekly")), (.seven_day_opus | line("Weekly Opus"))] | join("\n")),
        class: (if $peak >= 90 then "crit" elif $peak >= 75 then "warn" else "ok" end),
        percentage: ($peak | round)
      }
' 2>/dev/null || error "Unexpected usage response"
