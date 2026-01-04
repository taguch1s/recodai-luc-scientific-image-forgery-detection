#!/bin/bash

# MCP wrapper script for playwright with nvm support
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Use default node version if no version is specified
if ! command -v node &> /dev/null; then
    nvm use default
fi

# Execute playwright mcp with all arguments
exec npx @playwright/mcp@latest "$@"
