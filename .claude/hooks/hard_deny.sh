#!/bin/bash
# claude-code-guardian: Tier 1 Hard Deny
# Instantly blocks catastrophic commands regardless of context.
# Reads JSON from stdin per Claude Code hook spec.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
  fi

  # System destruction
  if echo "$COMMAND" | grep -qE 'rm\s+.*-[a-z]*r[a-z]*\s+(/\s*$|/usr|/etc|/bin|/boot|/lib|~\s*$|\$HOME\s*$)'; then
    echo "Blocked: system destruction command" >&2; exit 2
    fi

    # Fork bombs
    if echo "$COMMAND" | grep -qE ':\(\)\s*\{.*:\|:'; then
      echo "Blocked: fork bomb detected" >&2; exit 2
      fi

      # Raw disk operations
      if echo "$COMMAND" | grep -qE '\bmkfs\b|\bdd\b.*of=/dev/[sh]d'; then
        echo "Blocked: raw disk operation" >&2; exit 2
        fi

        # Reverse shells / remote code execution
        if echo "$COMMAND" | grep -qE 'bash\s+-i\s+>&\s*/dev/tcp|(curl|wget).*\|\s*(ba)?sh'; then
          echo "Blocked: reverse shell / remote code execution" >&2; exit 2
          fi

          # Credential exfiltration
          if echo "$COMMAND" | grep -qE 'cat\s+.*\.ssh/id_|\.aws/credentials|(env|printenv).*\|.*curl'; then
            echo "Blocked: credential exfiltration" >&2; exit 2
            fi

            # Force push to protected branches
            if echo "$COMMAND" | grep -qE 'git\s+push\s+.*(--force|-f)\s+.*(main|master|production|staging|develop)'; then
              echo "Blocked: force push to protected branch" >&2; exit 2
              fi

              exit 0
