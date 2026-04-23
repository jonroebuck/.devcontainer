#!/usr/bin/env bash
set -euo pipefail

mkdir -p agent-output

if ! grep -q '^agent-output/$' .gitignore 2>/dev/null; then
	{
		echo ""
		echo "# Local agent-team output"
		echo "agent-output/"
	} >> .gitignore
fi

if ! grep -q '^mutants\.out\*$' .gitignore 2>/dev/null; then
	{
		echo "mutants.out*"
	} >> .gitignore
fi

echo "Bootstrap complete."
