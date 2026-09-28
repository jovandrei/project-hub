# Working notes for agents

Read this first, then `.agent_tasks/QUEUE.md` for what to pick up next, then
`ROADMAP.md` for where the work stands.

## What this is

A single local page (`hub.py`, stdlib only) that lists every project in
`C:\Projects` which serves HTTP, shows whether it is up, and can start, stop or
restart them - individually or all at once. Built 2026-09-28.

`ROADMAP.md` owns the phase list and its status. `.agent_tasks/QUEUE.md` owns
which task is next, and each `.agent_tasks/<task>/STATE.md` owns the steps of
work in flight. This file owns the purpose, ground rules and traps. Do not
restate a phase's status here.

## Ground rules

1. **Loopback only.** Everything the hub exposes or starts is on 127.0.0.1;
   some of these dashboards map private data. Never bind 0.0.0.0.
2. **Kill by port, not by remembered PID.** Services outlive the hub, so
   `stop` looks up who is listening on the service's port via `netstat -ano`
   and kills those PIDs. A remembered PID is stale the moment the hub restarts.
3. **Never kill a foreign listener.** `stop` only taskkills images in
   `KILLABLE_IMAGES` (python/node/powershell/cmd). Anything else holding a
   managed port is reported back as refused, not killed.
4. **Start must be idempotent.** On Windows `SO_REUSEADDR` lets a second
   Python share a port instead of failing to bind, so "does the port answer"
   is the check - never spawn a second copy onto a live port.
5. **Do not restate service details here that live in `services.json`** -
   the JSON is the registry; this file holds only why and what bites.

## Running things

```
python hub.py                   http://127.0.0.1:8760, opens a browser
python hub.py --no-browser      same, no browser tab
start-hub.bat                   double-click entry point
```

Adding a service = one entry in `services.json` (`id`, `name`, `description`,
`port`, `url`, `start.command` + `start.cwd` relative to `C:\Projects`,
optional `start.env`). `"python"` as the first command word resolves to the
interpreter running the hub. Projects without a server go in `tools`.

## Traps

1. **SO_REUSEADDR is real on Windows.** Two `python -m http.server` style
   processes can listen on one port and split the requests. `netstat -ano`
   must report *every* listener (plural), and stop must kill all of them.
   `singing-practice-tools` documented this as its trap 11.
2. **`stop` on a port answers only after the socket closes** - poll it for a
   few seconds before declaring success; taskkill is asynchronous.
3. **Each service opens its own console window** (`CREATE_NEW_CONSOLE`) so
   its log stays visible and it survives the hub exiting. Output encoding is
   forced via `PYTHONIOENCODING=utf-8` because every service here can print
   non-cp1252 text.
4. **`wifi-network-monitor` needs `MONITOR_NO_BROWSER=1`** when spawned, or it
   opens a browser tab every time (`webbrowser.open` is unconditional
   otherwise). `disk-cleanup` and `VocalCoach` take `--no-browser` /
   `-NoBrowser` natively.
5. **VocalCoach must be started through `practice-server.ps1`**, not by
   running `web_app.py` directly - the launcher writes the instance-token
   metadata its own stop/status relies on, and refuses foreign ports.
   The hub still *stops* it by port-kill like everything else.
6. **`disk-cleanup` takes ~20 s to answer after spawn** (it warms whole-table
   aggregates first). `START_GRACE_SECONDS` exists for this - the UI shows
   "Starting" until the port answers.
7. **POSTs require `X-Hub-Request: 1`.** Without it a random browser page
   could drive the kill endpoints cross-origin; browsers cannot set a custom
   header cross-origin without a CORS preflight we never answer.

## The task workspace - read before starting work

`.agent_tasks/` holds the state of work in progress, so the plan does not die
with the session. The full contract is `.agent_tasks/README.md`, the template
`.agent_tasks/_template/STATE.md`. The short version:

1. **Read `.agent_tasks/QUEUE.md` first**, then the `STATE.md` of any task
   that is not `done`. If the queue is empty, fall back to `ROADMAP.md`. Do
   not open a second task while one is `in progress` unless the user asks.
2. **Progress is the checklist.** Tick a step only when it is finished *and
   verified*. Never delete a step: tick it, or move it to *Deferred or
   blocked* with the reason.
3. **Long output goes to `.agent_tasks/<task>/scratch/`**, which is
   gitignored, so any conclusion drawn from it must end up in `STATE.md`, or
   in `ROADMAP.md` if it is a measurement.
4. **Update `STATE.md` as state changes**, especially its *Where it stopped*
   line. Append a row to `.agent_tasks/efficiency_stats.md` before stopping.

A `STATE.md` step is a step of the work; a roadmap item is product state.
When a step lands and moves a roadmap item, tick both in the same commit.

## Assume this is the last prompt of the session

Sessions end without warning. Work accordingly:

- **Update `ROADMAP.md` when a phase item changes state**, in the same commit
  as the change.
- **When a measurement is taken, write the number down** where the roadmap
  keeps its findings. A superseded number is useful; a missing one is not.
- **Commit in coherent local groups** and never push without the user's
  explicit request.
- **If about to run low, stop and write rather than start something new.**
  Half-finished unverified code is worse than a documented gap. Say
  explicitly what was deferred.

## Verifying a change

```
python -m py_compile hub.py            syntax
python hub.py --no-browser &           then:
curl http://127.0.0.1:8760/api/ping    -> {"app": "project-hub"}
curl http://127.0.0.1:8760/api/status  -> per-service state + listener pids
```

The real gate is the cycle: POST a stop for one service, watch its row go
down, POST a start, watch it reach `up` and answer HTTP on its port.
