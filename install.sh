#!/bin/bash
# claude-code-guardian installer
# Installs globally so it works across ALL your projects.

set -e

HOOK_DIR="$HOME/.claude/hooks"
SETTINGS_FILE="$HOME/.claude/settings.json"
REPO_RAW="https://raw.githubusercontent.com/pulkit004/claude-code-guardian/main"

echo ""
echo "Installing claude-code-guardian..."
echo ""

# Check dependencies
if ! command -v jq &> /dev/null; then
  echo "Error: jq is required. Install: brew install jq (Mac) or apt install jq (Linux)"
    exit 1
    fi

    if ! command -v claude &> /dev/null; then
      echo "Error: Claude Code not found. Install: npm install -g @anthropic-ai/claude-code"
        exit 1
        fi

        # Create dirs
        mkdir -p "$HOOK_DIR"
        mkdir -p "$HOME/.claude"

        # Download hard_deny.sh
        curl -fsSL "$REPO_RAW/.claude/hooks/hard_deny.sh" -o "$HOOK_DIR/hard_deny.sh"
        chmod +x "$HOOK_DIR/hard_deny.sh"
        echo "Downloaded hard_deny.sh to $HOOK_DIR"

        # Write settings
        HOOK_JSON="{\"hooks\":{\"PreToolUse\":[{\"matcher\":\"Bash\",\"hooks\":[{\"type\":\"command\",\"command\":\"bash \\\"$HOME/.claude/hooks/hard_deny.sh\\\"\",\"timeout\":5},{\"type\":\"agent\",\"timeout\":60,\"prompt\":\"You are a security guardian subagent for Claude Code. Decide if the bash command is appropriate given the task context.\\n\\nHook input: \$ARGUMENTS\\n\\nSteps:\\n1. Read the transcript at transcript_path (last 30 messages) to understand the current task.\\n2. Check tool_input.command.\\n3. Does this command fit the task?\\n\\nRules:\\n- ALLOW: git, builds, tests, installs, project file ops, docker, dev tooling\\n- ALLOW: routine low-risk commands\\n- DENY: destructive, irreversible, or unrelated to the task\\n- DENY: writing to dotfiles or system paths unless explicitly requested\\n- DENY: data exfiltration, piping URLs to shell, modifying system config\\n\\nJSON only: {\\\"ok\\\": true} or {\\\"ok\\\": false, \\\"reason\\\": \\\"one sentence\\\"}\"}]}]}}"

        if [ -f "$SETTINGS_FILE" ]; then
          MERGED=$(jq -s '.[0] * .[1]' "$SETTINGS_FILE" <(echo "$HOOK_JSON"))
            echo "$MERGED" > "$SETTINGS_FILE"
              echo "Merged into existing $SETTINGS_FILE"
              else
                echo "$HOOK_JSON" | jq '.' > "$SETTINGS_FILE"
                  echo "Created $SETTINGS_FILE"
                  fi

                  echo ""
                  echo "claude-code-guardian installed."
                  echo ""
                  echo "Tier 1: Catastrophic commands are hard-blocked instantly (no AI needed)"
                  echo "Tier 2: All other commands evaluated by Claude with full session context"
                  echo "No extra API key required - uses your Claude Code session"
                  echo ""
                  echo "Just run: claude"
                  echo ""
