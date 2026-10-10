## 0. Setup

![Setup flow: use this template, your own repo, allow Actions, git clone](assets/step0-setup.svg)

1. Click **Use this template → Create a new repository** (top right of this page).
   Choose **your account** as the owner, give it a name, and click **Create repository**.
2. In **your new repository**, go to **Settings → Actions → General → Workflow permissions** and:
   - select **Read and write permissions**
   - tick **Allow GitHub Actions to create and approve pull requests**
   - click **Save**

   GitHub Actions uses these permissions to update this page and to create the branches and
   Pull Requests for exercises 3 and 4.
3. Tell Git who you are (only once per computer):

   ```bash
   git config --global user.name "<Your Name>"
   git config --global user.email "<you@example.com>"
   ```

4. Clone your repository and move into it:

   ```bash
   git clone https://github.com/<your-username>/<your-repo>.git
   cd <your-repo>
   ```

> **How to read the commands:** text in `<angle brackets>` is a placeholder. Replace it, and
> the brackets, with your own value.

---

## 1. Your first commit and push

You'll work directly on `main`, the default branch.

![Working directory to staging area (git add) to local repository (git commit) to GitHub (git push)](assets/step1-commit.svg)

1. Open `exercise-1/hello.md` and fill in your information.
2. See what changed, then **stage**, **commit** and **push** it:

   ```bash
   git status                      # hello.md shows as modified (red)
   git diff                        # the exact lines you changed
   git add exercise-1/hello.md     # stage it (green in git status)
   git commit -m "Add my info to hello.md"
   git push origin main
   ```

3. Refresh your repository on GitHub. Your commit appears at the top of the file list.

✅ **Done when:** `exercise-1/hello.md` on GitHub shows your info. Wait about 30 seconds and this
page changes to Exercise 2.

### Stuck?

| What you see | What to do |
| --- | --- |
| `git push` asks for a password | GitHub needs a token or SSH key, not your password. Easiest: install the [GitHub CLI](https://cli.github.com) and run `gh auth login` |
| This page didn't change after your push | Check step 0.2, then go to **Actions → Course progress → Run workflow** |
