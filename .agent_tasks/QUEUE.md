# Task queue

The master ordered list. One line per task. This answers "what next"; the
task's own `STATE.md` answers "where in it".

Status is one of `next`, `in progress`, `blocked`, `paused`, `done`. Keep the
order meaningful, but see rule 3 in `README.md`: finishing something early is
fine, it just has to be ticked where it lives.

Conventions for `STATE.md` are in `README.md`; the template is in `_template/`.

| # | Task | Status | Folder | Waits on |
|---|---|---|---|---|

## Not yet filed as tasks

Open work that exists but has no folder, so nobody has to go looking for it.
`ROADMAP.md`'s unchecked items are the default source of the next task when
this table is empty.

- Phase 2 items in `ROADMAP.md` (log tail in UI, hub-started tracking, run-at-login)

A task gets a folder here when it is going to be worked on across more than
one session. Until then the roadmap is enough, and duplicating it would only
create two places to update.
