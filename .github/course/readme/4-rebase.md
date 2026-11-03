## 4. Rebase

`git rebase` takes your commits and **replays them on top of** the latest `main`, as if you'd
started your branch today. You get a straight-line history with no merge commits.

### 4.0 GitHub Actions creates the scenario for you

When you finished Exercise 3, the **Course progress** workflow created branch `ex4/feature`
(about 1 minute), which is **10 commits behind** `main` and **9 commits ahead** of it. If the
branch isn't there, go to **Actions → Exercise 4 · Create rebase scenario → Run workflow**.

![Before: ex4/feature branches off old main. After git rebase origin/main: the same commits are replayed on top of main with new hashes, followed by your commit.](assets/step4-rebase.svg)

Look at it yourself:

```bash
git fetch origin
git switch ex4/feature
git log --oneline --graph --all -25
git rev-list --left-right --count origin/main...HEAD    # prints: 10   9   (behind, ahead)
```

### 4.1 Rebase and commit

```bash
git rebase origin/main
git rev-list --left-right --count origin/main...HEAD    # now: 0   9
git log --oneline --graph -15                           # one straight line
```

Your 9 commits now sit on top of main's 10. Note that they have **new hashes**,
because rebase rewrites commits. Now add one commit of your own (run it in **Git Bash**, or add the
line with your editor: Windows PowerShell's `echo >>` writes the file in the wrong encoding):

```bash
echo "- Rebased onto main by <your-name>" >> exercise-4/feature-notes.md
git commit -am "feature: note that the branch was rebased"
git push --force-with-lease
```

**Why force?** The commits on GitHub are the *old* ones (before the rebase), and your branch
replaced them. `--force-with-lease` overwrites the remote branch, but only if nobody else pushed
to it in the meantime. Never force-push a shared branch like `main`.

> If a rebase ever goes wrong: `git rebase --abort` puts everything back the way it was.

### 4.2 Open a Pull Request and merge it

The workflow created the branch, but **you** open the PR.

1. The **Check rebase** check runs on your push (see the **Actions** tab). It verifies that your
   branch is 0 commits behind, has no merge commits, and kept all 10 commits.
2. On GitHub click **Compare & pull request** for `ex4/feature` (base `main`) and click
   **Create pull request**.
3. When the check is green, click **Merge pull request → Confirm merge** (keep **Create a merge
   commit**, not squash), then **Delete branch**.
4. Clean your workspace:

```bash
git switch main && git pull
git branch -d ex4/feature && git fetch --prune
```

✅ **Done when:** your PR is merged into `main` and **Check rebase** is green.

> Want to try again? Re-run the workflow. It rebuilds `ex4/feature` from scratch.

### Stuck?

| What you see | What to do |
| --- | --- |
| **Check rebase**: "merge commit(s)" | You merged instead of rebasing. Run `git reset --hard origin/ex4/feature`, or re-run the Exercise 4 workflow, and rebase again |
| `git push` rejected after a rebase | Use `git push --force-with-lease` |
| Lost in the middle of the rebase | `git rebase --abort`, then start over from 4.1 |
| Rebase went wrong, or you want to start over | Go to **Actions → Restart exercise 3 or 4 → Run workflow**, pick `4`, tick the confirm box. Then on your computer: `git rebase --abort` (if a rebase is in progress), `git fetch origin`, `git switch ex4/feature`, `git reset --hard origin/ex4/feature`, and start again from 4.1 |
