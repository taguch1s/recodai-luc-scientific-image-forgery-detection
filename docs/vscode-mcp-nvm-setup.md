# VS Code MCP with NVM Setup Guide

## 問題
nvmでインストールされたNode.js/npmを使用している場合、VS CodeのMCPサーバーがnpxを見つけられない場合があります。

## 解決方法

### 1. 公式設定形式の使用
`mcp.json` ファイルで公式の設定形式を使用：

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest"
      ]
    }
  }
}
```

### 2. VS Code環境設定

#### オプション A: ワークスペース設定 (推奨)
`.vscode/settings.json` に以下を追加：

```json
{
  "terminal.integrated.env.linux": {
    "NVM_DIR": "${env:HOME}/.nvm",
    "PATH": "${env:HOME}/.nvm/versions/node/v24.11.0/bin:${env:PATH}"
  }
}
```

#### オプション B: ユーザー設定
VS Codeのユーザー設定(`settings.json`)に以下を追加：

```json
{
  "terminal.integrated.env.linux": {
    "NVM_DIR": "${env:HOME}/.nvm"
  },
  "terminal.integrated.shellArgs.linux": [
    "-c", "source ~/.nvm/nvm.sh && exec bash"
  ]
}
```

### 3. 確認方法

1. VS Codeを再起動
2. 新しいターミナルを開いて以下を実行：
   ```bash
   which npx
   npx --version
   ```
3. MCPサーバーが正常に起動することを確認

### 4. トラブルシューティング

#### Node.jsバージョンが変わった場合
PATHのバージョン番号を更新：
```json
"PATH": "${env:HOME}/.nvm/versions/node/[新しいバージョン]/bin:${env:PATH}"
```

#### 動的バージョン管理が必要な場合
以下の設定を使用：
```json
{
  "terminal.integrated.shellArgs.linux": [
    "-c", "source ~/.nvm/nvm.sh && nvm use default && exec bash"
  ]
}
```

## セットアップスクリプト

環境確認用のスクリプト `scripts/setup-nvm.sh` を実行：
```bash
./scripts/setup-nvm.sh
```

このスクリプトは以下を確認します：
- Node.js バージョン
- npm バージョン
- npx の場所
- PATH にnvm が含まれているか

## 注意事項

- Node.jsのバージョンを変更した場合は、VS Codeの設定も更新が必要
- グローバル設定よりもワークスペース設定が優先される
- MCPサーバーの変更後はVS Codeの再起動が必要
