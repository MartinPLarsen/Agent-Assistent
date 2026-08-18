# Telegram on your phone — the short version

For the person setting this up on their own Mac. Fifteen minutes, mostly waiting.

## Two kinds of window, and it matters

Everything below happens in one of two places. Putting a command in the wrong one is the
most common way this goes wrong.

- **A normal terminal** — the black window you opened yourself. Commands here start with a
  program name: `bun`, `claude`, `cd`.
- **Inside the assistant** — after the assistant has started and is waiting for you.
  Commands here start with a slash: `/plugin`, `/telegram:configure`.

Each step below says which one. If you are unsure which you are in: a normal terminal shows
your username and a `%` sign. The assistant shows a `>` and a blinking cursor.

## Step 1 — Install Bun (normal terminal)

The Telegram connection runs on a small program called Bun. Without it, nothing happens and
nothing tells you why — the bot simply never answers.

```bash
curl -fsSL https://bun.sh/install | bash
```

**Then close the terminal window completely and open a new one.** The new window is the
only one that knows Bun exists.

Check it worked:

```bash
bun --version
```

A number means yes. `command not found` means the new window did not pick it up — close it
and open one more.

## Step 2 — Create your bot (in Telegram, on your phone or desktop)

1. Search for **@BotFather** and open the chat.
2. Send `/newbot`.
3. It asks for a display name. Anything you like.
4. It asks for a username. It must end in `bot`, for example `annas_assistant_bot`.
5. It replies with a token that looks like `123456789:AAHfiq...`

Copy the whole thing, including the numbers before the colon. Keep it somewhere for the
next two minutes. Treat it like a password — anyone who has it can control your bot.

## Step 3 — Start the assistant (normal terminal)

```bash
cd ~/Downloads/Agent-Assistent-main
bash setup.sh
```

If your folder is somewhere else, type `cd ` with a space and then drag the folder into the
terminal window — it fills in the path for you.

## Step 4 — Install the plugin (inside the assistant)

Wait until the assistant is running and waiting for you, then send these two, one at a time:

```
/plugin install telegram@claude-plugins-official
```

```
/reload-plugins
```

## Step 5 — Hand over the token (inside the assistant)

```
/telegram:configure PASTE-YOUR-TOKEN-HERE
```

Then leave:

```
/exit
```

## Step 6 — Start it again, with the phone connection on (normal terminal)

This is the step everyone misses. Started without this flag, the assistant can send messages
but never hears you.

```bash
cd ~/Downloads/Agent-Assistent-main
claude --channels plugin:telegram@claude-plugins-official
```

Look for this line as it starts:

```
Listening for channel messages from: plugin:telegram@claude-plugins-official
```

No line means it is not connected. Do not continue — go to the troubleshooting list.

## Step 7 — Introduce yourself (Telegram, then the assistant)

1. In Telegram, find your own bot and send it anything. `hej` is fine.
2. It answers with a six-character code. That is not a mistake — it does not know you yet.
3. Back in the assistant:

```
/telegram:access pair PASTE-THE-CODE
```

Send your bot another message. This one reaches the assistant, and it answers.

## Every day after this

One command, in a normal terminal:

```bash
cd ~/Downloads/Agent-Assistent-main && ./scripts/open-agent.sh
```

The assistant only hears you while that window is open. Close it and the bot goes quiet —
messages sent meanwhile are not saved.

Want it shorter? Add this line to the bottom of `~/.zshrc` once:

```bash
alias assistant="cd ~/Downloads/Agent-Assistent-main && ./scripts/open-agent.sh"
```

Open a new terminal and from then on it is one word: `assistant`.

## When the bot stays silent

Work down the list and stop at the first thing that is wrong. All of these run in a normal
terminal unless the line starts with a slash.

| Check | What it means |
|---|---|
| `bun --version` gives a number | No Bun, no connection, and nothing says so |
| `claude --version` gives a number | If not: `echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc`, then open a new terminal |
| The `Listening for channel messages` line appeared at startup | If not, you started without `--channels` |
| `/plugin list` shows telegram | If not, step 4 did not take |
| Your bot answered with a six-character code | If not, the connection is not up — the fault is above this line, not in the pairing |

If the bot never sends a code, do not keep retrying the pairing. Nothing is listening yet;
go back to the first row.

Still stuck? Ask the assistant itself: *"Min Telegram-bot svarer ikke. Tjek bun, pluginnet
og om denne session blev startet med --channels. Giv mig én kommando ad gangen."*
