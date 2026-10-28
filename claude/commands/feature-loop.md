---
description: Build a feature, test it as a user in the browser, and fix it in a loop until it passes
argument-hint: "<feature description> [--rounds N, default 3] [--url http://localhost:PORT]"
---

Build and test this feature: $ARGUMENTS

Do these steps in order. Show "round N of M" in each status update.

1. **Criteria.** Write 3 to 7 acceptance criteria. Each criterion is a
   result a user can see in the browser. Show them and wait for the user
   to confirm. If the feature is vague, offer the `grilling` skill first.
2. **Build.** Implement the feature. Use test-driven development for the
   logic. Run the unit tests and make sure they pass.
3. **Run.** Start the app in the background if it is not running. Find
   the URL from `--url`, the project scripts, or the server output.
4. **Test.** Send the `user-tester` agent the URL and the criteria. Do not
   send it hints about the code.
5. **Fix.** If the verdict is FAIL, find the root cause of each failure,
   fix it, run the unit tests again, and go back to step 4.
6. **Stop.** Stop when the verdict is PASS, or after the round limit
   (default 3). After the limit, do not try again. Report which criteria
   still fail and what you think the cause is.

Final report: the criteria with their last result, the files changed, the
number of rounds, and the open problems. Do not commit unless the user
asks.
