# Local Playbook Resolution

The installed `meta-quest-workflow` skill is a portable router. Repository-
level playbooks remain in this repository rather than being duplicated into
every local skill installation.

An installer may generate the local-only file
`references/local-meta-quest-playbooks.json`. The locator records the exact
repository root, commit, Git tree, clean status fingerprint, README, docs root,
and playbook index that were inspected when the skill was installed. The file
is installation metadata and must never be tracked in this repository.
Its identity fields include `repository_root`, `source_commit`, `source_tree`,
`source_worktree_dirty`, and `source_status_fingerprint`.

Use `skills/meta-quest-workflow/scripts/Resolve-PlaybookSource.ps1` from an
installed skill to resolve the playbooks. The resolver first verifies the
installed managed files against `.morphospace-skill-source.json`. It then uses
the local checkout only when all of these properties still match:

- canonical repository identity;
- full source commit and Git tree;
- clean working tree, including untracked files;
- status fingerprint;
- exact README, docs root, and playbook-index paths.

If the locator is missing, damaged, dirty, moved, or stale, the resolver
returns raw public URLs pinned to the installed provenance commit. It never
falls back to floating `main`. Invalid or dirty installation provenance fails
closed because a public commit cannot reproduce uncommitted installed bytes.

The resolver only chooses documentation bytes. It does not select a headset,
repository, executable, package, endpoint, credential, permission, or command,
and it grants no mutation authority.

Example:

```powershell
$source = pwsh -NoProfile -File `
  .\scripts\Resolve-PlaybookSource.ps1 -Json | ConvertFrom-Json
$source.mode
$source.playbook_index
```

Canonical repository checkouts already contain `README.md` and `docs/` beside
the skill source. Use those files directly while working in such a clean,
explicitly selected checkout.
