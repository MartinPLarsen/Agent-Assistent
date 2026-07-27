# Tools

> Written during setup phase 4. Update it when something is added or stops working.

## Services

| Service | Reached via | Live | Used for |
|---------|-------------|------|----------|
| {{SERVICE}} | {{connector \| CLI \| API \| MCP}} | yes/no | {{what it is for}} |

## Watcher sources

Which proactive checks have what they need. A watcher without its source never fires; that
is not an error, but it should not be a surprise either.

| Watcher | Needs | Available |
|---------|-------|-----------|
| stale-work | issue tracker | {{yes/no}} |
| unpaid-bills | mail | {{yes/no}} |
| calendar-invites | calendar | {{yes/no}} |
| unanswered | mail | {{yes/no}} |
| commitment-drift | nothing | yes |
| daily-digest | whatever else is live | yes |

## Secrets

Keys are never stored in this repo. Where each one actually lives:

| Key | Lives in | Needed by |
|-----|----------|-----------|
| {{KEY_NAME}} | {{keychain \| dashboard \| env outside repo}} | {{what breaks without it}} |

## Command-line tools

Found on this machine during the harvest.

| Tool | Present | Used for |
|------|---------|----------|
| {{tool}} | yes/no | {{purpose}} |
