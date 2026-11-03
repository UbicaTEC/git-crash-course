## 5. MCPs

An **MCP server** (Model Context Protocol) gives an AI assistant tools it can call, such as
"list branches" or "create an issue". Here you connect the **GitHub MCP server** to Claude Code
and use it on this repository.

![MCP flow: you ask Claude Code, it calls tools on the GitHub MCP server, which opens a pull request on GitHub](assets/step5-mcp.svg)

### 5.1 Connect the GitHub MCP server

1. Create a GitHub token: **Settings → Developer settings → Personal access tokens**, with read
   access to your repository. Never commit it.
2. Add the server and check that it's connected:

   ```bash
   claude mcp add --transport http github https://api.githubcopilot.com/mcp/      --header "Authorization: Bearer <your-token>"
   claude mcp list                  # github should show as connected (or type /mcp inside Claude Code)
   ```

### 5.2 Open a PR through the MCP server

First read the Instagram profile [@ubicatec_mty](https://www.instagram.com/ubicatec_mty/) to
learn what **UbicaTEC** is. Then edit `exercise-5/mcp-notes.md` on a new branch (don't commit to
`main`) and let Claude do the GitHub part. Start `claude` in your repository folder and ask, in
plain English, something like:

> "Create a branch `mcp-ubicatec`, commit my changes to `exercise-5/mcp-notes.md`, push it, and
> open a pull request to `main` on GitHub. In the PR description, explain what UbicaTEC is
> (<what you learned from the profile>)."

Replace the placeholders in `exercise-5/mcp-notes.md` first (the tool names Claude used, and
one thing an MCP server could do for your own work).

### 5.3 Merge it

Check the PR on GitHub: its description must say what UbicaTEC is. Then merge it.

✅ **Done when:** the PR is merged into `main`. This page then shows the finish screen.

### Stuck?

| What you see | What to do |
| --- | --- |
| `claude: command not found` | Install [Claude Code](https://claude.com/claude-code) first |
| `github` shows as failed in `/mcp` | Check the token (not expired, correct scopes) and re-run `claude mcp add` |
