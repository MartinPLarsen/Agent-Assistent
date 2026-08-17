#!/bin/bash
# Launch Donna with the Telegram channel attached.
#
# The plugin only starts when Claude Code is launched with --channels; without the flag
# the bot sends but never receives. Look for this line on boot:
#   Listening for channel messages from: plugin:telegram@claude-plugins-official
cd "$(dirname "$(dirname "$(realpath "$0")")")" && claude --channels plugin:telegram@claude-plugins-official
