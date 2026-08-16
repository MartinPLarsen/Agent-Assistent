#!/usr/bin/env node
// Second-brain engine. Four commands, no dependencies, no network.
//
//   node scripts/brain.mjs check
//   node scripts/brain.mjs recall "<question>"
//   node scripts/brain.mjs store  "<text>" --name <slug> [--title "..."] [--desc "..."]
//   node scripts/brain.mjs ask    "<question>"
//   node scripts/brain.mjs selftest
//
// Why this exists: retrieval should cost zero tokens. The assistant should not read a
// hundred pages to find one. `recall` scores the index — one line per page — opens only
// the best match, and returns the section that actually answers, so the model starts from
// evidence instead of from a folder.

import { readFileSync, writeFileSync, existsSync, readdirSync, mkdirSync, mkdtempSync, appendFileSync } from 'node:fs';
import { join, dirname, resolve, basename } from 'node:path';
import { fileURLToPath } from 'node:url';
import { tmpdir } from 'node:os';

const KIT = resolve(dirname(fileURLToPath(import.meta.url)), '..');

// ---------------------------------------------------------------- brain location

// The brain path lives in agent.json, written by setup phase 7. Nothing else knows it.
function brainRoot(override) {
  if (override) return resolve(override);
  const cfg = join(KIT, 'agent.json');
  if (!existsSync(cfg)) die('agent.json not found — run the setup wizard first');
  const brain = JSON.parse(readFileSync(cfg, 'utf8')).brain;
  if (!brain?.path) die('agent.json has no brain.path — run setup phase 7');
  if (!existsSync(brain.path)) die(`brain.path does not exist: ${brain.path}`);
  return brain.path;
}

const paths = (root) => ({
  root,
  pages: join(root, 'knowledge-base', 'raw', 'pages'),
  notes: join(root, 'knowledge-base', 'raw', 'session-notes'),
  index: join(root, 'knowledge-base', 'wiki', 'index.md'),
  log: join(root, 'knowledge-base', 'wiki', 'log.md'),
});

// ---------------------------------------------------------------- index parsing

// Index lines are `- [Title](../raw/pages/slug.md) — description`. Markdown links, not
// wikilinks, precisely so this regex can find the target without resolving anything.
const INDEX_LINE = /^-\s*\[([^\]]+)\]\(([^)]+)\)\s*(?:[—-]\s*(.*))?$/;

function readIndex(p) {
  if (!existsSync(p.index)) return [];
  return readFileSync(p.index, 'utf8').split('\n').flatMap((line, i) => {
    const m = line.match(INDEX_LINE);
    if (!m) return [];
    return [{ lineNo: i + 1, title: m[1], target: m[2], desc: (m[3] || '').trim(),
              file: resolve(dirname(p.index), m[2]) }];
  });
}

// ---------------------------------------------------------------- scoring
//
// Deliberately boring: term overlap, weighted so a hit in the title counts for more than
// one in the description. No stemming, no embeddings. At the scale one person generates
// this is enough, and being able to explain why a page ranked first matters more than
// squeezing out the last few points of recall.

const STOP = new Set(['the','a','an','and','or','of','to','in','is','are','was','were','it',
  'og','er','en','et','den','det','som','til','for','på','af','med','vi','jeg','hvad','hvordan','hvorfor']);

const terms = (s) => s.toLowerCase().match(/[\p{L}\p{N}]{2,}/gu)?.filter(t => !STOP.has(t)) ?? [];

function score(entry, qTerms) {
  const title = terms(entry.title), desc = terms(entry.desc), slug = terms(basename(entry.target, '.md'));
  let n = 0;
  for (const t of qTerms) {
    if (title.includes(t)) n += 3;
    if (slug.includes(t)) n += 2;
    if (desc.includes(t)) n += 1;
  }
  return n;
}

// Pick the section of a page that answers, rather than returning the whole file. Sections
// are markdown headings; the best one is scored the same way as the index.
function bestSection(text, qTerms, maxChars = 1200) {
  const lines = text.split('\n');
  const cuts = [];
  lines.forEach((l, i) => { if (/^#{1,6}\s/.test(l)) cuts.push(i); });
  if (cuts.length === 0) return text.slice(0, maxChars);
  cuts.push(lines.length);
  let best = null;
  for (let i = 0; i < cuts.length - 1; i++) {
    const chunk = lines.slice(cuts[i], cuts[i + 1]);
    // A heading with nothing under it is not an answer. The page's own H1 is the usual
    // offender: it repeats the title, so it ties on the query's title words and — being
    // first — used to win every tie and return a blank section.
    const hasProse = chunk.slice(1).some(l => l.trim() && !/^#{1,6}\s/.test(l));
    if (!hasProse) continue;
    const body = chunk.join('\n');
    const bTerms = new Set(terms(body));
    const n = qTerms.reduce((acc, t) => acc + (bTerms.has(t) ? 1 : 0), 0);
    if (!best || n > best.n) best = { n, body };
  }
  if (!best) return text.slice(0, maxChars);
  // A zero-scoring best section means the match was on the index line, not the body.
  // Returning the top of the page is more honest than returning an arbitrary heading.
  return (best.n === 0 ? text : best.body).slice(0, maxChars);
}

// ---------------------------------------------------------------- commands

// Index lines carry a title and one line of description. That is enough for most queries
// and it is why retrieval is cheap. It is not enough when the answer lives in the body and
// the question uses none of the indexer's words — "when am I most effective" against a page
// described as "peak 12-22". Returning nothing there is the failure that makes a brain feel
// broken, so fall back to scanning the bodies. At one person's scale that is a few dozen
// small files; the index still does the work whenever it can.
function bodyFallback(p, qTerms) {
  if (!existsSync(p.pages)) return [];
  return readdirSync(p.pages)
    .filter(f => f.endsWith('.md'))
    .map(f => {
      const file = join(p.pages, f);
      const text = readFileSync(file, 'utf8');
      const bTerms = new Set(terms(text));
      const s = qTerms.reduce((acc, t) => acc + (bTerms.has(t) ? 1 : 0), 0);
      return { title: basename(f, '.md').replace(/-/g, ' '), target: `../raw/pages/${f}`, desc: '', file, s, viaBody: true };
    })
    .filter(e => e.s > 0)
    .sort((a, b) => b.s - a.s);
}

function cmdRecall(question, opts) {
  const p = paths(brainRoot(opts.brain));
  const qTerms = terms(question);
  let ranked = readIndex(p).map(e => ({ ...e, s: score(e, qTerms) }))
                           .filter(e => e.s > 0)
                           .sort((a, b) => b.s - a.s);
  let viaBody = false;
  if (ranked.length === 0) {
    ranked = bodyFallback(p, qTerms);
    viaBody = ranked.length > 0;
  }
  if (ranked.length === 0) {
    console.log(`No match for: ${question}\n\nSay so plainly. Do not fill the gap with a guess.`);
    return 1;
  }
  if (viaBody) {
    console.log(`(no index line matched — found by scanning page bodies. The index line for`);
    console.log(`this page is too narrow; consider widening its description.)\n`);
  }
  const top = ranked[0];
  const out = [`# Evidence for: ${question}`, ''];
  if (existsSync(top.file)) {
    out.push(`## ${top.title}`, `source: ${top.target}`, '', bestSection(readFileSync(top.file, 'utf8'), qTerms));
  } else {
    out.push(`## ${top.title}`, `MISSING FILE: ${top.target} — index points at a page that does not exist.`);
  }
  const others = ranked.slice(1, 4);
  if (others.length) {
    out.push('', '## Also possibly relevant', ...others.map(e => `- ${e.title} — ${e.target}`));
  }
  console.log(out.join('\n'));
  return 0;
}

function cmdStore(text, opts) {
  if (!opts.name) die('store needs --name <slug>');
  const p = paths(brainRoot(opts.brain));
  mkdirSync(p.pages, { recursive: true });
  const slug = opts.name.toLowerCase().replace(/[^a-z0-9-]+/g, '-').replace(/^-|-$/g, '');
  const title = opts.title || slug.replace(/-/g, ' ');
  const desc = (opts.desc || text.split('\n')[0]).slice(0, 200);
  const file = join(p.pages, `${slug}.md`);

  const existed = existsSync(file);
  if (existed) {
    appendFileSync(file, `\n\n${text}\n`);
  } else {
    writeFileSync(file, `---\nname: ${slug}\ndescription: ${desc}\n---\n\n# ${title}\n\n${text}\n`);
  }

  // One index line per page, ever. Appending a second is how an index starts disagreeing
  // with itself, and a contradictory index is worse than no index.
  const line = `- [${title}](../raw/pages/${slug}.md) — ${desc}`;
  const idx = existsSync(p.index) ? readFileSync(p.index, 'utf8') : '# Index\n\n';
  if (!new RegExp(`\\(\\.\\./raw/pages/${slug}\\.md\\)`).test(idx)) {
    writeFileSync(p.index, idx.replace(/\n*$/, '\n') + line + '\n');
  }

  mkdirSync(dirname(p.log), { recursive: true });
  appendFileSync(p.log, `\n## [${new Date().toISOString().slice(0, 10)}] store — ${title}\n${existed ? 'Appended to' : 'Created'} ${slug}.md\n`);
  console.log(`${existed ? 'appended' : 'created'}: ${file}`);
  console.log('brain.mjs does not commit. Commit and push the brain repo yourself.');
  return 0;
}

function cmdAsk(question, opts) {
  console.log(`Answer this from the evidence below. Cite the source path for every claim.`);
  console.log(`If the evidence does not answer it, say so — do not fill the gap.\n`);
  console.log(`QUESTION: ${question}\n`);
  return cmdRecall(question, opts);
}

function cmdCheck(opts) {
  const p = paths(brainRoot(opts.brain));
  const problems = [];

  for (const d of [p.pages, p.notes, dirname(p.index)]) {
    if (!existsSync(d)) problems.push(`missing directory: ${d}`);
  }
  if (!existsSync(p.index)) problems.push(`missing index: ${p.index}`);

  const entries = readIndex(p);
  const indexed = new Set();
  for (const e of entries) {
    if (!existsSync(e.file)) problems.push(`index line ${e.lineNo} points at a missing page: ${e.target}`);
    else indexed.add(resolve(e.file));
    if (e.desc.length > 200) problems.push(`index line ${e.lineNo} is ${e.desc.length} chars, cap is 200`);
  }
  if (existsSync(p.pages)) {
    for (const f of readdirSync(p.pages).filter(f => f.endsWith('.md'))) {
      // An orphan page is invisible to recall, which reads to the user as the brain
      // having forgotten rather than as a missing line.
      if (!indexed.has(resolve(join(p.pages, f)))) problems.push(`page has no index line: ${f}`);
    }
  }

  console.log(`brain: ${p.root}`);
  console.log(`pages indexed: ${entries.length}`);
  if (problems.length === 0) { console.log('All checks passed.'); return 0; }
  problems.forEach(x => console.log(`FAIL — ${x}`));
  return 1;
}

// ---------------------------------------------------------------- selftest
//
// The smallest thing that fails if the logic breaks. No framework: build a brain in a temp
// dir, store into it, recall out of it, and assert the parts that are easy to get wrong.

function cmdSelftest() {
  const root = mkdtempSync(join(tmpdir(), 'brain-selftest-'));
  const p = paths(root);
  mkdirSync(p.pages, { recursive: true });
  mkdirSync(p.notes, { recursive: true });
  mkdirSync(dirname(p.index), { recursive: true });

  const assert = (cond, msg) => { if (!cond) { console.error(`SELFTEST FAIL — ${msg}`); process.exit(1); } };

  cmdStore('The deploy pipeline runs on Vercel and fails closed.', { brain: root, name: 'deploy-pipeline', title: 'Deploy pipeline', desc: 'runs on Vercel, fails closed' });
  assert(existsSync(join(p.pages, 'deploy-pipeline.md')), 'store did not create the page');

  const idx = readFileSync(p.index, 'utf8');
  assert(readIndex(p).length === 1, 'store did not write exactly one index line');

  // Storing the same slug twice must append to the page and NOT add a second index line.
  cmdStore('It also runs migrations.', { brain: root, name: 'deploy-pipeline' });
  assert(readIndex(p).length === 1, 'second store duplicated the index line');
  assert(readFileSync(join(p.pages, 'deploy-pipeline.md'), 'utf8').includes('migrations'), 'second store did not append');

  // Scoring: a title hit must outrank a description-only hit.
  const a = { title: 'Deploy pipeline', target: '../raw/pages/deploy-pipeline.md', desc: 'x' };
  const b = { title: 'Unrelated', target: '../raw/pages/unrelated.md', desc: 'deploy' };
  assert(score(a, terms('deploy')) > score(b, terms('deploy')), 'title hit did not outrank description hit');

  // Stop words must not create matches on their own.
  assert(score(a, terms('the and of')) === 0, 'stop words produced a score');

  // bestSection must return the section that answers, not the page's own H1. The H1
  // repeats the title, so it ties on title words and wins by being first unless empty
  // sections are excluded. This assertion is here because that bug shipped once.
  // The query must tie: one hit in the title, one in the answering section. That is the
  // shape the bug needed, and it is the common one — the user asks in Danish about a page
  // written in English, so only a word or two lands. A query that scores the right section
  // higher outright passes whether or not the guard is there, which is how the first
  // version of this assertion let the bug straight back in.
  const page = '# Deploy pipeline\n\n## Setup\nRuns on Vercel.\n\n## Failure mode\nFails closed when the token expires.\n';
  const sec = bestSection(page, terms('deploy token'));
  assert(sec.includes('Failure mode'), `bestSection returned the wrong section: ${JSON.stringify(sec)}`);
  assert(!sec.startsWith('# Deploy pipeline'), 'bestSection returned the empty H1 block');

  // The body fallback: a question whose words appear only in the page body, never in the
  // index line, must still find the page. Without this, recall answers "no match" to a
  // question the brain can answer — the failure that makes people stop trusting it.
  cmdStore('Bedst mellem 12 og 22. Morgen er til planlaegning.', { brain: root, name: 'work-rhythm', title: 'Work rhythm', desc: 'peak hours' });
  // Assert through cmdRecall, not through bodyFallback directly: the first version of this
  // test called the helper, so breaking the CALL SITE inside cmdRecall left it green. Test
  // the wiring, not the part you happen to have a handle on.
  assert(readIndex(p).every(e => score(e, terms('planlaegning')) === 0),
    'selftest premise broken: the index should NOT match this query');
  assert(cmdRecall('planlaegning', { brain: root }) === 0,
    'recall returned no match for a word that is in a page body');

  // check must catch an orphan page.
  writeFileSync(join(p.pages, 'orphan.md'), '# Orphan\n');
  assert(cmdCheck({ brain: root }) === 1, 'check passed despite an orphan page');

  console.log('selftest ok');
  return 0;
}

// ---------------------------------------------------------------- cli

function die(msg) { console.error(`brain: ${msg}`); process.exit(2); }

function parseArgs(argv) {
  const opts = {}; const positional = [];
  for (let i = 0; i < argv.length; i++) {
    if (argv[i].startsWith('--')) opts[argv[i].slice(2)] = argv[i + 1]?.startsWith('--') ? true : argv[++i];
    else positional.push(argv[i]);
  }
  return { opts, positional };
}

const { opts, positional } = parseArgs(process.argv.slice(2));
const [cmd, arg] = positional;
const need = (what) => arg ?? die(`${cmd} needs ${what}`);

const exit = {
  recall:   () => cmdRecall(need('a question'), opts),
  ask:      () => cmdAsk(need('a question'), opts),
  store:    () => cmdStore(need('some text'), opts),
  check:    () => cmdCheck(opts),
  selftest: () => cmdSelftest(),
}[cmd];

if (!exit) die(`unknown command: ${cmd ?? '(none)'}\nusage: brain.mjs recall|store|ask|check|selftest`);
process.exit(exit());
