# claude-code-guardian

Intelligent permission hook for Claude Code. Uses Claude itself with full session context to decide what is safe — no regex hacks, no extra API keys.

## How it works

Every bash command Claude attempts passes through two tiers:

**Tier 1 — Hard Deny (instant, no AI)**
Catastrophic patterns blocked immediately: rm -rf on system paths, fork bombs, reverse shells, raw disk ops, credential theft, force pushes to protected branches.

**Tier 2 — Agent Evaluation (context-aware)**
A Claude subagent reads your session transcript, understands what task you asked for, and decides if the command makes sense. Allow if yes. Deny with reason if no.

## Install

One command, works globally across all your projects:

```bash
curl -fsSL https://raw.githubusercontent.com/pulkit004/claude-code-guardian/main/install.sh | bash
```

Requirements: Claude Code (`npm install -g @anthropic-ai/claude-code`) and jq (`brew install jq`).

## Usage

Nothing changes. Just run Claude Code normally:

```bash
cd your-project
claude
```

The guardian runs silently in the background. You only notice it when something is blocked.

## No extra API key needed

Uses Claude Code native `type: "agent"` hooks — runs within your existing Claude Code session. Same model, same subscription, no OpenRouter or separate Anthropic API key required.

## Per-project install

```bash
mkdir -p .claude/hooks
curl -fsSL https://raw.githubusercontent.com/pulkit004/claude-code-guardian/main/.claude/hooks/hard_deny.sh -o .claude/hooks/hard_deny.sh
chmod +x .claude/hooks/hard_deny.sh
curl -fsSL https://raw.githubusercontent.com/pulkit004/claude-code-guardian/main/.claude/settings.json -o .claude/settings.json
```

Commit `.claude/` and your whole team gets the guardian automatically.

## Uninstall

```bash
jq 'del(.hooks)' ~/.claude/settings.json > /tmp/s.json && mv /tmp/s.json ~/.claude/settings.json
rm ~/.claude/hooks/hard_deny.sh
```

## Credits

Built on ideas from liberzon/claude-hooks, kornysietsma/claude-code-permissions-hook, and the Anthropic Claude Code Hooks reference.


MIT License
