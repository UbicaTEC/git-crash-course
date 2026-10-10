## 2. Branches and Pull Requests

In real teams, nobody pushes straight to `main`. You work on a **branch** and ask for it to be
merged with a **Pull Request (PR)**.

![Branch lifecycle: create branch, commit, push, open PR, merge, delete branch, pull and clean up](assets/step2-branch-pr.svg)

### 2.0 Download this page

GitHub Actions just added a commit to `main` (it changed this README). Bring it to your computer
first:

```bash
git pull
```

### 2.1 Create a branch and commit on it

```bash
git switch -c add-favorites          # create the branch AND switch to it
```

Fill in the table in `exercise-2/favorites.md`, then:

```bash
git add exercise-2/favorites.md
git commit -m "Fill in my favorites"
```

### 2.2 Push the branch

```bash
git push -u origin add-favorites     # -u links your local branch to the remote one
```

### 2.3 Open a Pull Request into `main`

On GitHub you'll see a yellow banner, **add-favorites had recent pushes → Compare & pull request**.
Click it, check that it says **base: main ← compare: add-favorites**, and click **Create pull request**.

*(Or, with the GitHub CLI: `gh pr create --base main --fill`.)*

Wait for the **Check tables** check to turn green. If it's red, your table is broken. Fix it,
commit and push again, and the PR updates automatically.

### 2.4 Merge it

Click **Merge pull request → Confirm merge**.

### 2.5 Delete the branch

Click **Delete branch** on the PR page. *(Or from the terminal: `git push origin --delete add-favorites`.)*

### 2.6 Clean your workspace

Your computer still has the old branch, and your local `main` doesn't have the merge yet:

```bash
git switch main                # go back to main
git pull                       # download the merge
git branch -d add-favorites    # delete the local branch (safe: it's merged)
git fetch --prune              # forget remote branches that were deleted on GitHub
git status                     # "nothing to commit, working tree clean"
git branch -a                  # add-favorites is gone everywhere
```

✅ **Done when:** `git branch -a` shows no `add-favorites`, and `git status` is clean. This page
changes to Exercise 3 once the PR is merged.

### Stuck?

| What you see | What to do |
| --- | --- |
| **Check tables**: "Row has 1 cell(s) but the header has 2" | A row is missing a cell. Count the `\|` pipes |
| `git push` rejected: "fetch first" / "non-fast-forward" | Run `git pull`, then push again |
| `git branch -d` says "not fully merged" | You haven't pulled the merge yet. Run `git switch main && git pull` first |
