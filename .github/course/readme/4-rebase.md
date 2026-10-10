## 4. Rebase

`git rebase` takes your commits and **replays them on top of** the latest `main`, as if you'd
started your branch today. You get a straight-line history with no merge commits.

### 4.0 Let GitHub Actions create the scenario

Go to **Actions → Exercise 4 · Create rebase scenario → Run workflow**. It creates branch
`ex4/feature`, which is **10 commits behind** `main` and **9 commits ahead** of it:

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
because rebase rewrites commits. Now add one commit of your own:

```bash
echo "- Rebased onto main by <your-name>" >> exercise-4/feature-notes.md
git commit -am "feature: note that the branch was rebased"
git push --force-with-lease
```

**Why force?** The commits on GitHub are the *old* ones (before the rebase), and your branch
replaced them. `--force-with-lease` overwrites the remote branch, but only if nobody else pushed
to it in the meantime. Never force-push a shared branch like `main`.

> If a rebase ever goes wrong: `git rebase --abort` puts everything back the way it was.

### 4.2 Merge into `main`

1. Open a PR from `ex4/feature` into `main` (`gh pr create --base main --fill`, or use the GitHub UI).
2. The **Check rebase** check verifies that your branch is 0 commits behind, has no merge commits,
   and kept all 10 commits. **Don't** click **Update branch** on GitHub: that creates a
   merge commit, which is exactly what rebase avoids. The check will fail if you do.
3. When it's green, merge the PR, delete the branch, and clean your workspace.

✅ **Done when:** the PR is merged with a green **Check rebase** check.

> Want to try again? Re-run the workflow. It rebuilds `ex4/feature` from scratch.

### Stuck?

| What you see | What to do |
| --- | --- |
| **Check rebase**: "merge commit(s)" | You merged instead of rebasing. Run `git reset --hard origin/ex4/feature`, or re-run the Exercise 4 workflow, and rebase again |
| `git push` rejected after a rebase | Use `git push --force-with-lease` |
| Lost in the middle of the rebase | `git rebase --abort`, then start over from 4.1 |
| Anything else | Re-run the Exercise 4 workflow: it resets everything |
