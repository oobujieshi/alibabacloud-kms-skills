# AlibabaCloud KMS Skills

阿里云 KMS 信封加密/解密 WorkBuddy & Anthropic Skills。

## 项目组成

```
├── envelope-encrypt/       # KMS 信封加密 Skill
│   ├── SKILL.md            # Skill 定义（skills.sh 标准）
│   ├── scripts/run.sh      # 平台自适应运行脚本
│   └── evals/evals.json    # skill-creator 评估用例
├── envelope-decrypt/       # KMS 信封解密 Skill
│   ├── SKILL.md
│   ├── scripts/run.sh
│   └── evals/evals.json
├── skillsbench/            # SkillsBench 评测任务
│   └── tasks/
│       ├── envelope-encrypt/
│       │   ├── task.md
│       │   ├── oracle/solve.sh
│       │   └── verifier/test.sh
│       └── envelope-decrypt/
│           ├── task.md
│           ├── oracle/solve.sh
│           └── verifier/test.sh
└── README.md
```

## 关联仓库

- **CLI 源码**: [alibabacloud-kms-skills-cli](https://github.com/oobujieshi/alibabacloud-kms-skills-cli)
- **Skills Bench**: SkillsBench 评测任务

## 安装

```bash
# WorkBuddy
cp -r envelope-encrypt ~/.workbuddy/skills/
cp -r envelope-decrypt ~/.workbuddy/skills/

# Anthropic Claude Code / skills.sh
npx skills add ./envelope-encrypt
npx skills add ./envelope-decrypt
```

## SkillsBench 评测

需要 Docker + benchflow CLI：

```bash
# 安装 benchflow
uv tool install benchflow

# 克隆 SkillsBench
git clone https://github.com/benchflow-ai/skillsbench.git
cd skillsbench
uv sync --locked

# 拷贝本项目的 task 到 SkillsBench
cp -r ../../skillsbench/tasks/* tasks/

# 设置凭证
export ALIBABA_CLOUD_ACCESS_KEY_ID=xxx
export ALIBABA_CLOUD_ACCESS_KEY_SECRET=xxx
export REGION_ID=cn-hangzhou
export KMS_KEY_ID=xxx

# Oracle 检查
bench eval run --tasks-dir tasks/envelope-encrypt --agent oracle --sandbox docker
bench eval run --tasks-dir tasks/envelope-decrypt --agent oracle --sandbox docker

# Agent + skill 评测
bench eval run --tasks-dir tasks/envelope-encrypt --agent claude-agent-acp \
    --model claude-sonnet-4-20250514 --skill-mode with-skill \
    --skills-dir tasks/envelope-encrypt/environment/skills/

# 无 skill baseline
bench eval run --tasks-dir tasks/envelope-encrypt --agent claude-agent-acp \
    --model claude-sonnet-4-20250514 --skill-mode no-skill
```

## Skill 列表

| Skill | 功能 | 触发词 |
|-------|------|--------|
| `envelope-encrypt` | KMS 信封加密 | encrypt with KMS, envelope encrypt, KMS加密, 信封加密 |
| `envelope-decrypt` | KMS 信封解密 | decrypt with KMS, envelope decrypt, KMS解密, 信封解密 |
