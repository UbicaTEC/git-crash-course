## 3. Merge conflicts in Markdown tables

A **merge conflict** happens when two branches change the **same lines** of a file. Git can't
decide which version wins, so it asks you.

### 3.0 GitHub Actions creates the conflict for you

When you finished Exercise 2, the **Course progress** workflow set this exercise up by itself
(about 1 minute). Check that the branch `ex3/your-changes` exists on GitHub (**Branches**). No PR
is opened: that part is yours. If the branch isn't there, go to **Actions → Exercise 3 · Create
merge conflicts → Run workflow**.

What happened: the workflow created `exercise-3/hackathon-plan.md`, then made **two branches**.
Your teammate **Alex**'s branch was merged into `main` first. Your branch, `ex3/your-changes`,
edited the **same 4 places**, so merging `main` into it will conflict.

![Alex's branch is merged first; your branch edited the same lines, so it has 4 conflicts. Example conflict block and its resolution.](assets/step3-conflict.svg)

### 3.1 Resolve the 4 conflicts so the tables render

```bash
git fetch origin
git switch ex3/your-changes
git merge origin/main          # CONFLICT (content): Merge conflict in exercise-3/hackathon-plan.md
git status                     # "both modified: exercise-3/hackathon-plan.md"
```

Open `exercise-3/hackathon-plan.md`. Each conflict looks like this:

```text
<<<<<<< HEAD
(your version: ex3/your-changes)
=======
(Alex's version: from main)
>>>>>>> origin/main
```

For each of the 4 conflicts, write the final content you want, then **delete the three marker
lines**. The team agreed on this:

| Table | What Alex did (main) | What you did (your branch) | Correct result |
| --- | --- | --- | --- |
| Schedule | Added `11:00 Git workshop` | Added `11:30 Hacking starts` | Keep **both** rows, in time order |
| Teams | Added a `Room` column | Added the `Rebasers` team | Keep both. Rebasers' room is `TBD` |
| Budget | Snacks = 100 | Snacks = 150 | Exactly **one** Snacks row, pick 100 or 150 |
| Tasks | `Order food` status → Done | `Order food` owner → Marta | **One** row that has both changes |

![Anatomy of a Markdown table: header row, separator row, and rows that all have the same number of cells](assets/step3-tables.svg)

**Table rules that GitHub needs in order to render a table:**

- Row 1 is the header, and row 2 is the separator (`| --- | --- |`). Every row starts and ends with `|`.
- **Every row has the same number of cells as the header.** This is the most common mistake
  when someone adds a column on one branch and a row on another.
- No leftover `<<<<<<<`, `=======` or `>>>>>>>` lines.

Tip: VS Code shows **Accept Current / Accept Incoming / Accept Both** buttons above each conflict.
They're a good start, but you'll still need to fix the result by hand.

Check your work locally (optional, needs Python), then finish the merge:

```bash
python .github/course/check_tables.py --ex3     # "All tables ... look good."
git add exercise-3/hackathon-plan.md
git commit                                      # accept the default merge message
git push
```

### 3.2 Open a Pull Request and merge it

The workflow created the branch, but **you** open the PR. **Check tables** runs automatically
after your push (see the **Actions** tab).

1. On GitHub click **Compare & pull request** for `ex3/your-changes` (or **Pull requests → New
   pull request**, base `main`, compare `ex3/your-changes`).
2. Give it a title, then click **Create pull request**. GitHub must say **"This branch has no
   conflicts with the base branch"**. If not, go back to 3.1.
3. When **Check tables** is green, click **Merge pull request → Confirm merge**, then
   **Delete branch**.
4. Clean your workspace:

```bash
git switch main && git pull
git branch -d ex3/your-changes && git fetch --prune
```

✅ **Done when:** your PR is merged into `main`, **Check tables** is green, and the hackathon plan on
`main` renders 4 tables. This page then changes to Exercise 4.

> Want to try again? Re-run the workflow. It resets the file and the branch.

### Stuck?

| What you see | What to do |
| --- | --- |
| Workflow fails with **403** | **Settings → Actions → General**: select **Read and write permissions**. Then re-run the workflow |
| **Check tables**: "Row has 2 cell(s) but the header has 3" | A row is missing a cell. Count the `\|` pipes |
| **Check tables**: "duplicate row(s)" | **Accept Both** copied a line twice. Delete one copy |
| **Check tables**: "Leftover merge-conflict marker" | Delete every `<<<<<<<`, `=======` and `>>>>>>>` line |
| Lost in the middle of the merge | `git merge --abort`, then start over from 3.1 |
| Merge went wrong, or you want to start over | Go to **Actions → Restart exercise 3 or 4 → Run workflow**, pick `3`, tick the confirm box. Then on your computer: `git merge --abort` (if a merge is in progress), `git fetch origin`, `git switch ex3/your-changes`, `git reset --hard origin/ex3/your-changes`, and start again from 3.1 |
