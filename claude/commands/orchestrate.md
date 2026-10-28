---
description: Split a large task into bounded tasks and send them to worker agents, in parallel when they are independent
argument-hint: "<goal or path to a plan file>"
---

You are the orchestrator for this goal: $ARGUMENTS

You plan, send, check, and integrate. You do not write the feature code
yourself, except for the integration step.

1. **Plan.** Read the goal (or the plan file) and the code it touches.
   Split the work into tasks. Each task has: a goal, the files it owns,
   an acceptance check (a command), and what it must not touch. Two tasks
   never own the same file.
2. **Order.** Mark each task as independent or as "after task N". Show
   the task table and wait for the user to confirm it.
3. **Send.** Send each independent task to a `worker` agent. Send
   independent workers in the same message so they run in parallel. Use
   `isolation: "worktree"` when two workers touch the same package or
   build. Send dependent tasks only after their prerequisites are DONE.
4. **Check.** Read each worker report. Do not trust a DONE: run its
   check yourself. For a BLOCKED or FAILED report, answer the question or
   split the task again, then send it again. Send one task at most 2 times.
5. **Integrate.** Merge the worktrees, if any. Run the full test suite
   and the linter of the project.
6. **Report.** Show a table: task, status, files, check result. List the
   open problems. Do not commit unless the user asks.

For a task with only 1 or 2 small steps, do not orchestrate. Tell the
user and do the work directly.
