---
name: run-ralph-codex
description: "为当前项目准备并执行 Codex 版 Ralph 自动循环。当你希望用一个 skill 完成环境检查、注入缺失的 Ralph 运行文件（如 `ralph.sh`、`CODEX.md`），然后基于 `prd.json` 执行下一条待完成故事时使用。触发示例：运行 ralph、继续 Ralph 循环、执行 prd.json、在当前项目里启动 Ralph、让 Codex 跑下一条故事。"
---

# 运行 Ralph Codex

为当前项目补齐 Codex 版 Ralph 运行环境，然后执行循环。

## 工作流

1. 解析目标项目根目录：优先使用当前 Git 仓库根目录，否则使用当前工作目录。
2. 检查并补齐最小运行文件：
   - `ralph.sh`
   - `CODEX.md`
   - `tmp/ralph/`
3. 检查目标目录是否是 Git 仓库。
4. 如果不是 Git 仓库，先暂停执行，并明确提示用户：
   - 是否在当前目录初始化 Git
   - 或是否改为使用一个已有的 Git 仓库路径
5. 检查是否存在 `prd.json`。
6. 如果没有 `prd.json`，停止执行，并提示先运行 `prd` 和 `ralph` 两个 skill。
7. 如果存在 `prd.json`，找出其中 `passes: false` 的待处理 stories。
8. 确定要执行的迭代轮数；默认使用 `1`。如果用户明确要求“跑完当前 backlog”，则使用 `--all`。
9. 如果用户明确指定模型或思考深度，把它们透传给 `codex exec`。
10. 执行 `scripts/run_ralph_codex.sh [iterations|--all|--init-git|--repo <path>|--model <model>|--reasoning-effort <level>]`。
11. 执行完成后，检查：
   - `prd.json` 是否更新了 `passes`
   - `progress.txt` 是否追加了新进度
   - `tmp/ralph/` 是否生成新的时间戳日志
12. 总结本轮变化：说明处理了哪个 story、是否产生 commit、最新日志文件路径是什么。

## 保护规则

- 这个 skill 可以注入缺失的运行文件，但不会替你生成 `prd.json`。
- 如果当前目录不是 Git 仓库，默认不要擅自初始化；先提示用户确认。
- 如果项目里还没有 `prd.json`，请先使用 `prd` 和 `ralph`。
- 把 `prd.json` 视为 append-only backlog，不要删除历史 stories。
- 默认一次只跑一轮，除非用户明确要求连续跑多轮或使用 `--all`。
- 如果所有 stories 都已经通过，应明确告知“无需执行”。
- 如果项目中已经存在 `ralph.sh` 或 `CODEX.md`，优先复用，不要覆盖。
- `--all` 会把“当前未完成 stories 数量”作为迭代上限，尽可能连续跑到 backlog 完成；如果中途有 story 卡住，仍可能在达到上限后停止。
- 只有在用户明确同意时，才使用 `--init-git`。
- 如果用户提供了已有仓库路径，可使用 `--repo /path/to/repo`。
- 如果用户指定了 `--model`，应让底层 `codex exec -m <model>` 显式使用该模型，而不是只继承全局默认值。
- 如果用户指定了 `--reasoning-effort`，应显式透传为 Codex 的 `model_reasoning_effort` 配置。

## 默认命令

```bash
./skills/run-ralph-codex/scripts/run_ralph_codex.sh 1
```

如果要尝试一口气跑完当前 backlog，可使用：

```bash
./skills/run-ralph-codex/scripts/run_ralph_codex.sh --all
```

如果当前目录不是 Git 仓库，并且用户明确同意初始化：

```bash
./skills/run-ralph-codex/scripts/run_ralph_codex.sh --init-git 1
```

如果用户提供了一个已有的 Git 仓库路径：

```bash
./skills/run-ralph-codex/scripts/run_ralph_codex.sh --repo /path/to/existing/repo --all
```

如果你想显式指定模型和思考深度：

```bash
./skills/run-ralph-codex/scripts/run_ralph_codex.sh --model gpt-5.4 --reasoning-effort high --all
```

只有在用户明确要求多轮时，才使用更大的整数或 `--all`。

## 预期结果

- 自动补齐缺失的 Ralph 运行文件
- 在进入 Ralph 循环前先确认 Git 环境是否可用
- 执行 `./ralph.sh --tool codex [iterations]`
- 如果指定了模型或思考深度，底层实际启动的 `codex exec` 会显式带上这些参数
- 尝试处理当前最高优先级且未完成的 story
- 使用 `--all` 时，会把当前 backlog 中未完成 story 的数量作为连续运行上限
- 如果有进展，`progress.txt` 会被追加
- `tmp/ralph/` 会生成新的时间戳日志文件

## 资源

### scripts/
- `scripts/run_ralph_codex.sh`：解析目标项目、注入缺失运行文件、确认 Git 环境、打印待处理 stories，并执行 `ralph.sh --tool codex`；支持固定轮数、`--all`、`--init-git`、`--repo <path>`、`--model <model>` 和 `--reasoning-effort <level>`。

### assets/
- `assets/ralph-template/ralph.sh`：用于向目标项目注入 Ralph 运行脚本模板。
- `assets/ralph-template/CODEX.md`：用于向目标项目注入 Codex 提示模板。
