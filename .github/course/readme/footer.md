<details>
<summary><b>Cheat sheet</b></summary>

| Command | What it does |
| --- | --- |
| `git status` | What changed? What's staged? Which branch am I on? |
| `git add <file>` | Stage a change for the next commit |
| `git commit -m "<msg>"` | Save staged changes as a commit |
| `git push` / `git pull` | Upload / download commits |
| `git switch -c <branch>` | Create a branch and switch to it |
| `git switch <branch>` | Switch to an existing branch |
| `git branch -d <branch>` | Delete a merged local branch |
| `git fetch --prune` | Update remote branches, and forget the deleted ones |
| `git merge <branch>` | Bring another branch's commits into yours |
| `git rebase <branch>` | Replay your commits on top of another branch |
| `git rebase --abort` / `git merge --abort` | Get out of a half-finished rebase or merge |
| `git log --oneline --graph --all` | Draw the commit history |
| `git push --force-with-lease` | Overwrite your remote branch safely (after a rebase) |

</details>

<sub>Icons: [GitHub Octicons](https://primer.style/octicons) (MIT, see `assets/OCTICONS-LICENSE.txt`).</sub>
