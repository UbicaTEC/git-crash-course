## 3. Merge conflicts in Markdown tables

A **merge conflict** happens when two branches change the **same lines** of a file. Git can't
decide which version wins, so it asks you.

### 3.0 Let GitHub Actions create the conflict

1. On GitHub go to **Actions → Exercise 3 · Create merge conflicts → Run workflow → Run workflow**.
2. When it finishes (green check, about 30 s), open the **Pull requests** tab. There is a new PR,
   **Exercise 3: update the hackathon plan**, from `ex3/your-changes` into `main`.

What happened: the workflow created `exercise-3/hackathon-plan.md`, then made **two branches**.
Your teammate **Alex**'s branch was merged into `main` first. Your branch, `ex3/your-changes`,
edited the **same 4 places**, so the PR says **This branch has conflicts that must be resolved**.

![Alex's branch is merged first; your branch edited the same lines, so its PR has 4 conflicts. Example conflict block and its resolution.](assets/step3-conflict.svg)

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

*(GitHub also has a **Resolve conflicts** button in the PR that you can use as an alternative.
Try the terminal first: that's what you'll have in real projects.)*

### 3.2 Merge into `main`

Back in the PR, the conflict warning is gone, and **Check tables** runs automatically after your
push. When it's green, click **Merge pull request**, then **Delete branch**, and clean your
workspace like in Exercise 2:

```bash
git switch main && git pull && git branch -d ex3/your-changes && git fetch --prune
```

✅ **Done when:** the PR is merged with a green **Check tables** check, and the hackathon plan on
`main` renders 4 tables. This page then changes to Exercise 4.

> Want to try again? Re-run the workflow. It resets the file and the branch.

### Stuck?

| What you see | What to do |
| --- | --- |
| Workflow fails with **403** or **not permitted to create pull requests** | **Settings → Actions → General**: select **Read and write permissions** and tick **Allow GitHub Actions to create and approve pull requests**. Then re-run the workflow |
| The PR shows **no checks** | Normal: checks start after **you** push your resolution |
| **Check tables**: "Row has 2 cell(s) but the header has 3" | A row is missing a cell. Count the `\|` pipes |
| **Check tables**: "duplicate row(s)" | **Accept Both** copied a line twice. Delete one copy |
| **Check tables**: "Leftover merge-conflict marker" | Delete every `<<<<<<<`, `=======` and `>>>>>>>` line |
| Lost in the middle of the merge | `git merge --abort`, then start over from 3.1 |
| Anything else | Re-run the Exercise 3 workflow: it resets everything |
