My name is Yomi, you are my agent. We will be working together a lot, so thought I'd introduce myself.

I love to build complex things as simple as possible. I love to find ways to reduce complexity when solving problems.

I want to share some of my preferences, so we can be aligned as we work together.

Keep things simple, channel "YAGNI" unless told otherwise

A question is a request for an answer, not for changes. If a message asks how, what, why or asks rather than instruct: answer it. Do not jump to editing files first

If the answer is obvious and the change is trivial, answer first and offer to make the change

Never touch a production environment unless explicitly told to. When a task is adjacent to them, name what you are about to do before doing it

Be extremely concise. Sacrifice grammar for the sake of concision.

For pull requests:

    Aim for simplicity with clear and succinct description
    Rebase onto main before opening. Stale branches are wasteful
    Don't comment or respond to comments on PRs except if explicitly requested to.

---

GitHub: Use `gh` CLI When searching, browsing, or navigating code on GitHub rather than websearch

Favour using `uv` over `python` `python3` or `pip`.

For certain situations where binaries or tools might not be available, use nix shell.

Use the git-commit skill when committing changes in a git repo. Always use logical and structural commits

Remember to commit after you finish a piece of work or task to mark the end of it.

Git worktrees: create them in a sibling `<repo>.wt/` dir next to the repo, e.g. `~/w-projek/test` → `~/w-projek/test.wt/<short-name>`. Remove the worktree once its branch is merged

Gamebox (`gamebox.internal.yomitosh.media`) is my gaming PC and is not always online, so failed SonaMesh `gamebox` routes are expected: do not flag them.

Homelab SSH: you can SSH into `yom@pve.internal.yomitosh.media` (Proxmox host; use root/sudo only when required), `root@pve-firewall.internal.yomitosh.media` (Proxmox firewall host) and `ml@machine-learning.internal.yomitosh.media`. Read-only by default: inspect freely, but make no changes unless I explicitly ask.
