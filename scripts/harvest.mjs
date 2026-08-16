#!/usr/bin/env node
// Prepares the day's material for the harvest. It does NOT decide what is worth keeping —
// that needs judgement and lives in skills/daily-harvest/SKILL.md. This half is the part
// that should never be done by a model: reading a queue, grouping it, and refusing to
// hand back work that was already harvested.
//
//   node scripts/harvest.mjs plan            what to harvest for today
//   node scripts/harvest.mjs plan --day 2026-08-15
//   node scripts/harvest.mjs done --day <d>  mark the day harvested, truncate the queue
//   node scripts/harvest.mjs selftest
//
// The split matters. A script that tried to summarise would produce the thing nobody
// reads; a model that tried to track state would re-harvest Tuesday every day.

import { readFileSync, writeFileSync, existsSync, appendFileSync, mkdtempSync, mkdirSync } from 'node:fs';
import { join, dirname, resolve, basename } from 'node:path';
import { fileURLToPath } from 'node:url';
import { tmpdir } from 'node:os';

const KIT = resolve(dirname(fileURLToPath(import.meta.url)), '..');

function brainRoot(override) {
  if (override) return resolve(override);
  const cfg = join(KIT, 'agent.json');
  if (!existsSync(cfg)) die('agent.json not found — run the setup wizard first');
  const brain = JSON.parse(readFileSync(cfg, 'utf8')).brain;
  if (!brain?.path) die('agent.json has no brain.path — run setup phase 7');
  return brain.path;
}

const paths = (root) => ({
  root,
  queue: join(root, '.harvest-queue.jsonl'),
  notes: join(root, 'knowledge-base', 'raw', 'session-notes'),
  processed: join(root, 'knowledge-base', 'wiki', 'processed.md'),
});

function readQueue(p) {
  if (!existsSync(p.queue)) return [];
  return readFileSync(p.queue, 'utf8').split('\n').flatMap(line => {
    if (!line.trim()) return [];
    try { return [JSON.parse(line)] } catch { return [] }   // a torn line is not a reason to lose the day
  });
}

// A day is harvested once. Without this the same Tuesday gets folded into the pages every
// morning, and pages that accrete the same paragraph repeatedly are how a brain rots.
function alreadyHarvested(p, day) {
  if (!existsSync(p.processed)) return false;
  return readFileSync(p.processed, 'utf8').includes(`daily-harvest-${day}`);
}

function localDay(iso) {
  // The queue stores UTC; the user thinks in their own day. Anything after midnight local
  // belongs to the day they would call it, which is what a "yesterday" harvest must mean.
  return new Date(iso).toLocaleDateString('en-CA');   // en-CA is ISO-shaped: YYYY-MM-DD
}

function cmdPlan(opts) {
  const p = paths(brainRoot(opts.brain));
  const day = opts.day || localDay(new Date(Date.now() - 864e5).toISOString());
  const rows = readQueue(p).filter(r => r.ts && localDay(r.ts) === day);

  if (rows.length === 0) {
    // An empty result has two different meanings and the caller must be able to tell them
    // apart: nothing happened that day, or the day was harvested and its rows removed.
    // Reporting false for both would make the harvest re-ask about a day it already did.
    console.log(JSON.stringify({
      day, sessions: 0, repos: [], note_path: null,
      already_harvested: alreadyHarvested(p, day),
    }, null, 2));
    return 0;
  }

  // Group by repo. One line per repo with its session count is what the harvester needs to
  // decide where to look; the raw queue is noise at this level.
  const byRepo = new Map();
  for (const r of rows) {
    const key = r.cwd || 'unknown';
    if (!byRepo.has(key)) byRepo.set(key, { cwd: key, name: basename(key), sessions: 0, transcripts: [] });
    const e = byRepo.get(key);
    e.sessions++;
    if (r.transcript_path && !e.transcripts.includes(r.transcript_path)) e.transcripts.push(r.transcript_path);
  }

  const plan = {
    day,
    sessions: rows.length,
    already_harvested: alreadyHarvested(p, day),
    note_path: join(p.notes, `${day}-daily-harvest.md`),
    repos: [...byRepo.values()].sort((a, b) => b.sessions - a.sessions),
  };
  console.log(JSON.stringify(plan, null, 2));
  return 0;
}

function cmdDone(opts) {
  const p = paths(brainRoot(opts.brain));
  const day = opts.day || die('done needs --day YYYY-MM-DD');
  const note = join(p.notes, `${day}-daily-harvest.md`);
  if (!existsSync(note)) die(`no note at ${note} — write the session note before marking the day done`);

  mkdirSync(dirname(p.processed), { recursive: true });
  if (!alreadyHarvested(p, day)) {
    appendFileSync(p.processed, `- session-notes/${day}-daily-harvest.md → daily-harvest-${day} (${day})\n`);
  }

  // Drop only this day's rows. Truncating the whole queue would silently discard a session
  // that ended while the harvest was running, and nobody would ever know it was lost.
  const kept = readQueue(p).filter(r => !r.ts || localDay(r.ts) !== day);
  writeFileSync(p.queue, kept.map(r => JSON.stringify(r)).join('\n') + (kept.length ? '\n' : ''));

  console.log(`marked ${day} harvested; ${kept.length} queue row(s) left for other days`);
  console.log('harvest.mjs does not commit. Commit and push the brain repo yourself.');
  return 0;
}

function cmdSelftest() {
  const root = mkdtempSync(join(tmpdir(), 'harvest-selftest-'));
  const p = paths(root);
  mkdirSync(p.notes, { recursive: true });
  mkdirSync(dirname(p.processed), { recursive: true });
  const assert = (c, m) => { if (!c) { console.error(`SELFTEST FAIL — ${m}`); process.exit(1) } };

  const day = '2026-08-15', other = '2026-08-14';
  const rows = [
    { ts: `${day}T09:00:00+00:00`, cwd: '/repos/alpha', transcript_path: '/t/a1.jsonl' },
    { ts: `${day}T15:00:00+00:00`, cwd: '/repos/alpha', transcript_path: '/t/a2.jsonl' },
    { ts: `${day}T16:00:00+00:00`, cwd: '/repos/beta', transcript_path: null },
    { ts: `${other}T10:00:00+00:00`, cwd: '/repos/gamma', transcript_path: null },
    'this line is torn and must not lose the day',
  ];
  writeFileSync(p.queue, rows.map(r => typeof r === 'string' ? r : JSON.stringify(r)).join('\n') + '\n');

  const capture = () => { const out = []; const log = console.log; console.log = (...a) => out.push(a.join(' ')); return { out, restore: () => (console.log = log) } };

  let c = capture(); cmdPlan({ brain: root, day }); c.restore();
  const plan = JSON.parse(c.out.join('\n'));
  assert(plan.sessions === 3, `torn line or wrong day leaked in: got ${plan.sessions} sessions`);
  assert(plan.repos.length === 2, `expected 2 repos, got ${plan.repos.length}`);
  assert(plan.repos[0].name === 'alpha', 'repos are not sorted by session count');
  assert(plan.repos[0].transcripts.length === 2, 'transcripts were not collected per repo');
  assert(plan.already_harvested === false, 'a fresh day claims to be harvested');

  writeFileSync(plan.note_path, '# note\n');
  c = capture(); cmdDone({ brain: root, day }); c.restore();

  // The other day must survive. Truncating the whole queue is the tempting shortcut and it
  // silently drops sessions the harvest never looked at.
  const left = readQueue(p);
  assert(left.length === 1 && left[0].cwd === '/repos/gamma', `done() ate another day: ${JSON.stringify(left)}`);

  c = capture(); cmdPlan({ brain: root, day }); c.restore();
  assert(JSON.parse(c.out.join('\n')).already_harvested === true, 'a harvested day is not marked harvested');

  console.log('selftest ok');
  return 0;
}

function die(msg) { console.error(`harvest: ${msg}`); process.exit(2) }

const argv = process.argv.slice(2);
const opts = {}; const positional = [];
for (let i = 0; i < argv.length; i++) {
  if (argv[i].startsWith('--')) opts[argv[i].slice(2)] = argv[i + 1]?.startsWith('--') ? true : argv[++i];
  else positional.push(argv[i]);
}

const exit = { plan: () => cmdPlan(opts), done: () => cmdDone(opts), selftest: () => cmdSelftest() }[positional[0]];
if (!exit) die(`unknown command: ${positional[0] ?? '(none)'}\nusage: harvest.mjs plan|done|selftest`);
process.exit(exit());
