#!/bin/bash

# NVM setup script for VS Code MCP
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Ensure nvm default node is used
nvm use default

# Export the updated PATH for VS Code
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"
echo "npx location: $(which npx)"
echo "PATH includes nvm: $(echo $PATH | grep -o '/home/[^:]*/.nvm/[^:]*' | head -1)"
