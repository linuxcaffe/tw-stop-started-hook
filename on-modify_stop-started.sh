#!/usr/bin/env bash
# on-modify_stop-started.sh — stop other active tasks when a new task is started
#
# Ensures only one task runs at a time. The task being started is excluded.
# Stopped tasks still fire on-modify_timelog.py (no rc.hooks=off here).
#
# Install: ~/.task/hooks/on-modify_stop-started.sh
# Version: 1.1.0

IFS= read -r _old_json
IFS= read -r _new_json

# Must echo new task JSON back to TW on stdout
printf '%s\n' "$_new_json"

command -v jq &>/dev/null || exit 0

_old_start=$(printf '%s' "$_old_json" | jq -r '.start // ""')
_new_start=$(printf '%s' "$_new_json" | jq -r '.start // ""')

# Only act when start is being added (task being started)
[[ -z "$_old_start" && -n "$_new_start" ]] || exit 0

_this_uuid=$(printf '%s' "$_new_json" | jq -r '.uuid // ""')
[[ -n "$_this_uuid" ]] || exit 0

for _uuid in $(task rc.confirmation=off rc.verbose=nothing status:pending +ACTIVE _uuids 2>/dev/null); do
    [[ "$_uuid" == "$_this_uuid" ]] && continue
    task rc.confirmation=off rc.verbose=nothing "$_uuid" stop
done

exit 0
