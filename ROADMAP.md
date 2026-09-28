# project-hub - workplan

One phase at a time, in order. Mark items `[x]` as they land.

## Decisions already made

| Question | Answer |
|---|---|
| How is a service "running" decided? | TCP connect to `127.0.0.1:<port>` - honest, survives hub restarts, no PID bookkeeping. |
| How does stop find the process? | `netstat -ano` listener PIDs on the port; images outside `KILLABLE_IMAGES` are refused, not killed. |
| Why does each service get a console window? | `CREATE_NEW_CONSOLE` keeps logs visible and the service alive if the hub exits. |
| Where does the service list live? | `services.json` - one file, edited when a project is added or removed. |
| Which port? | 8760, per the root port registry in `C:\Projects\AGENTS.md`. |

## Phase 1 - working index + launcher

- [x] `hub.py` serves a status page on 127.0.0.1:8760 (`GET /`, `GET /api/status`, `GET /api/ping`)
- [x] Per-service and all-service start / stop / restart over POST (header-guarded)
- [x] Status states: up / starting / down, with listener PID + image and up-since
- [x] `services.json` covers the four serving projects + self row; CLI-only projects listed as tools
- [x] `start-hub.bat` double-click entry; second launch reuses the running hub instead of double-binding
- [x] Verified end to end: stop-all stopped 4/4, start-all brought 4/4 back to HTTP 200

## Phase 2 - optional polish (pick up only if wanted)

- [ ] Surface a service's own log tail in the UI ( VocalCoach keeps one in `.runtime`; others print to their console windows )
- [ ] Remember "was started by hub" so stop could warn before killing a user-started instance
- [ ] Run-at-login entry if the hub should always be up

---

## Explicitly not doing

- No LAN exposure, no auth beyond the loopback + header guard - the rule in `C:\Projects\AGENTS.md` is loopback only.
- No start/stop for CLI-only tools (`chrome-bookmarks`, `nirvana-concert-images`) - they are listed, not managed.
