---
name: accountability-heartbeat
description: "Dynamic accountability heartbeat for {{AGENT_NAME}}. Fires on a cron schedule while the session is open, reads Linear + Calendar + session.log + open_commitments as ground truth, and nudges {{USER_NAME}} only when drift is detected."
---

# {{AGENT_NAME}} Heartbeat — Dynamic Accountability

Fires on the cron entry `heartbeat-every-2h` in `cron-registry.json`. Does NOT automatically send Telegram messages. First applies silence rules, then gathers state, then detects drift, then MAY compose one nudge.

## Silence Rules (Check First — Short Circuit)

If ANY of these are true, exit silently with a one-line terminal log. Do NOT send a Telegram message.

1. Current time in {{TIMEZONE}} is before 08:00 or after 20:00
2. Today is Saturday or Sunday
3. {{USER_NAME}} has an active calendar event right now (check via `mcp__claude_ai_Google_Calendar__list_events`, filter to events where start ≤ now ≤ end). Skip this rule if Google Calendar is not configured.
4. {{USER_NAME}} has sent {{AGENT_NAME}} a Telegram message in the last 15 minutes (check the newest entry in `{{MEMORY_PATH}}/session.log.md` — if its timestamp is less than 15 minutes old, exit)
5. `{{MEMORY_PATH}}/session.log.md` is empty or contains only header comments (no signal to work with)

**Timezone handling:** `session.log.md` timestamps are written in UTC with trailing `Z`. Before comparing against "15 minutes ago" or "08:00 {{TIMEZONE}}", convert to {{TIMEZONE}}. Check the current date's DST status dynamically — do not hardcode a UTC offset.

## State Gathering (If No Silence Rule Matched)

Gather the following in parallel (skip any source that is not configured for this agent):

### A. Linear in-progress issues

Use `mcp__linear-*__list_issues` with filter:
- assignee: me
- state: "In Progress"
- updatedAt: sort descending
- limit: 10

Capture for each issue: identifier, title, updatedAt timestamp, state.

### B. Calendar — current event only

Silence Rule 3 already checks if {{USER_NAME}} is in a meeting right now. No additional Calendar data is needed for drift detection. Skip extra Calendar queries to save MCP calls.

### C. Session log — last 2 hours

Read `{{MEMORY_PATH}}/session.log.md`. Parse all entries with timestamps within the last 2 hours. Concatenate their summaries into a single lowercase string for substring-matching.

### D. Session log — last 24 hours (for orphan commitment rule)

From the same file, parse all entries with timestamps within the last 24 hours. Keep as one lowercase string.

### E. Open commitments

Read `{{MEMORY_PATH}}/open_commitments.md`. Extract all lines under `## Active` that start with `- **` (the bullet items). Capture their summary text.

## Drift Detection

Apply rules in order. Stop at the first match. At most ONE nudge per fire.

### Rule A: Stale In-Progress Issue

For each in-progress issue from state-gathering:

- Compute hours since `updatedAt`. If less than 4, skip this issue.
- Lowercase the issue identifier and title. Check if EITHER appears as a substring in the last-2-hours session-log string.
- If issue has NOT been mentioned in the last 2 hours AND its age is > 4 hours, that issue is a drift candidate.

If multiple candidates, pick the one with the oldest `updatedAt`. Compose a nudge (see Nudge Format below) using that issue. Exit after sending.

### Rule B: Orphan Commitment

If Rule A produced no candidate:

For each open commitment from state-gathering:

- **Normalize the commitment text first:** strip leading `- **`, trailing `**`, collapse whitespace, lowercase.
- Take the first ~40 characters of the normalized text as the search key.
- **Normalize the session-log-last-24h string the same way** before comparing (strip `**`, lowercase, collapse whitespace).
- Check if the search key appears as a substring in the normalized 24h session log.
- If it has NOT been mentioned in 24 hours, that commitment is a drift candidate.

If multiple candidates, pick the first one listed. Compose a nudge. Exit after sending.

### No Drift Detected

If neither rule matches, exit with a one-line terminal log saying "heartbeat: no drift". Do NOT send a Telegram message.

## Nudge Format

Use `mcp__plugin_telegram_telegram__reply` with chat_id `{{CHAT_ID}}` and this template. Plain text, matches the agent's Telegram-formatting rules (no bold, no inline commands, section breaks via blank lines).

### Rule A template

```
Hey {{USER_NAME}} — kort check-in.

{IDENTIFIER} har været in-progress siden {HUMAN_READABLE_TIME} og jeg kan ikke se den i vores chat.

Er du stadig i gang, eller skal den enten lukkes eller skubbes?

Sig til hvis den skal lukkes, så opdaterer jeg Linear.
```

Replace `{IDENTIFIER}` with e.g. `LUS-127` and `{HUMAN_READABLE_TIME}` with e.g. `06:12 i morges` or `2 dage siden`.

### Rule B template

```
Hey {{USER_NAME}} — kort check-in.

Jeg kan se "{COMMITMENT_SUMMARY}" har stået i open_commitments uden at du har rørt den det sidste døgn.

Skal den ud af listen, udskydes, eller er det den vi tager nu?
```

Replace `{COMMITMENT_SUMMARY}` with a ~40-character extract of the commitment bullet text.

## Error Handling

If any MCP call fails (Linear rate limit, Calendar timeout, etc), catch the error, log a one-liner to terminal ("heartbeat: mcp error, exiting"), and exit silently. Do NOT send a Telegram message reporting the error — that defeats the purpose of silent operation.

## How This Skill Is Invoked

The cron entry `heartbeat-every-2h` in `cron-registry.json` fires a prompt like:

```
Run the accountability-heartbeat skill. Apply silence rules first, then check drift rules against Linear, Calendar, session log, and open commitments. Send at most one nudge on Telegram if drift is detected. Do not send a message otherwise.
```

{{AGENT_NAME}} loads this skill and follows it end to end.
