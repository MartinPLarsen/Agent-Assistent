# Crons (Trigger.dev)

The wizard's phase 4 sets up Trigger.dev cloud crons that survive your laptop being asleep. This folder holds example task definitions you can adapt.

## First-time setup
1. Run from the kit root:
   ```bash
   npx trigger.dev@latest init
   ```
   This walks you through creating a Trigger.dev project and writes `trigger.config.ts`.

2. Copy an example into the generated `trigger/` folder:
   ```bash
   cp crons/examples/morning-briefing.ts trigger/
   ```

3. Edit the prompt inside the task to match your agent's voice.

4. Deploy:
   ```bash
   npx trigger.dev@latest deploy
   ```

## How crons reach the agent

Trigger.dev runs in the cloud. To reach your local agent, the task either:
- Calls a webhook on a small HTTP server you run locally (see `discord-bridge/` — can be extended), OR
- Posts directly to Discord via the bot's webhook URL, and your agent picks it up next time it reads the channel.

For an MVP, posting directly to Discord is simplest — no extra server needed.
