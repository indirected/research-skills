#!/usr/bin/env bash
set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/skills" && pwd)"

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Install research skills to Claude Code.

Options:
  --project, -p   Install to project space (.claude/skills/) instead of user space (~/.claude/skills/)
  --force, -f     Overwrite existing skills with the same name
  --help, -h      Show this help message

By default, installs to user space (~/.claude/skills/).
EOF
}

# Parse arguments
TARGET="user"
FORCE=false

for arg in "$@"; do
    case "$arg" in
        --project|-p) TARGET="project" ;;
        --force|-f)   FORCE=true ;;
        --help|-h)    usage; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; usage >&2; exit 1 ;;
    esac
done

# Determine destination
if [[ "$TARGET" == "project" ]]; then
    DEST=".claude/skills"
else
    DEST="$HOME/.claude/skills"
fi

mkdir -p "$DEST"

# Install each skill
installed=0
skipped=0
errors=0

for skill_path in "$SKILLS_DIR"/*/; do
    [[ -d "$skill_path" ]] || continue
    skill_name="$(basename "$skill_path")"
    dest_skill="$DEST/$skill_name"

    if [[ -e "$dest_skill" ]] && [[ "$FORCE" != true ]]; then
        echo "  skip  $skill_name (already exists; use --force to overwrite)"
        ((skipped++)) || true
        continue
    fi

    # Remove existing destination before copying so cp -r doesn't nest the
    # directory inside itself (cp -r src/ existing-dest/ copies INTO dest/).
    [[ -e "$dest_skill" ]] && rm -rf "$dest_skill"

    if cp -r "$skill_path" "$dest_skill" 2>/dev/null; then
        if [[ -e "$DEST/$skill_name" ]] && [[ "$FORCE" == true ]] && [[ "$skipped" -eq 0 ]]; then
            echo "  update $skill_name"
        else
            echo "  install $skill_name"
        fi
        ((installed++)) || true
    else
        echo "  ERROR  failed to install $skill_name" >&2
        ((errors++)) || true
    fi
done

echo ""
echo "Done. Installed: $installed  Skipped: $skipped  Errors: $errors"
echo "Skills destination: $DEST"
