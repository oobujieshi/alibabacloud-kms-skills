# AlibabaCloud KMS Skills

阿里云 KMS 信封加密/解密 WorkBuddy Skills。

## 安装

将 skill 目录复制到 WorkBuddy 的 skills 目录：

```bash
cp -r envelope-encrypt ~/.workbuddy/skills/
cp -r envelope-decrypt ~/.workbuddy/skills/
```

## Skill 列表

| Skill | 功能 |
|-------|------|
| `envelope-encrypt` | KMS 信封加密 |
| `envelope-decrypt` | KMS 信封解密 |

## 工作原理

1. 触发时，WorkBuddy 运行 `scripts/run.sh`
2. `run.sh` 自动检测当前平台（Linux/macOS/Windows）
3. 从 [alibabacloud-kms-skills-cli Releases](https://github.com/oobujieshi/alibabacloud-kms-skills-cli/releases) 下载对应的预编译二进制
4. 缓存到 `~/.cache/alibabacloud-kms-skills/`
5. 执行二进制并传递参数

## 二进制来源

预编译二进制由 [alibabacloud-kms-skills-cli](https://github.com/oobujieshi/alibabacloud-kms-skills-cli) 仓库的 GitHub Actions 自动构建并发布。

支持的平台：linux-amd64, linux-arm64, windows-amd64, darwin-amd64, darwin-arm64
