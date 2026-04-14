# Ralph Codex Skills

`Ralph Codex Skills` 是一组面向 Codex 的四步式研发技能包。

它基于原版 Ralph 的“单 story、分轮推进、长期 backlog”方法做了 Codex 适配，并额外引入了来自 `obra/superpowers` 的独立 `brainstorming` 技能。

这次开源的核心内容只有 `skills/` 目录下的四个技能，它们可以直接复制到：

```text
~/.codex/skills/
```

然后在任意项目里按统一流程使用：

```text
brainstorming -> prd -> ralph -> run-ralph-codex
```

## 开源范围

本仓库对外开源时，核心交付物是 `skills/` 目录下的四个技能：

- `skills/brainstorming/`
- `skills/prd/`
- `skills/ralph/`
- `skills/run-ralph-codex/`

其中：

- `brainstorming`：做前置脑暴、方案比较和范围收敛
- `prd`：输出正式产品需求文档
- `ralph`：把 PRD 转成可执行的 `prd.json`
- `run-ralph-codex`：检查环境、注入运行文件并启动 Codex 版 Ralph 循环

仓库根目录里的 `ralph.sh`、`CODEX.md`、`prd.json.example` 等文件，主要是：

- 本仓库自测与演化时的参考实现
- `run-ralph-codex` 模板资源的来源
- 便于理解这套技能背后的运行方式

但对最终使用者来说，最重要的是 `skills/` 目录本身。

## 这套技能解决什么问题

它把“从模糊需求到自动开发”的流程收敛成四步：

1. `brainstorming`
2. `prd`
3. `ralph`
4. `run-ralph-codex`

相比直接让模型一次性完成所有工作，这套方式的好处是：

- 先脑暴，再落文档，减少方向性返工
- 用 PRD 和 `prd.json` 把需求结构化
- 每轮只处理一个最小 story，更稳定
- 通过 `progress.txt`、Git 历史和 `prd.json` 形成长期记忆
- 每轮都是新上下文，减少上下文漂移

## 技能说明

### 1. brainstorming

作用：在写 PRD 之前先做轻量脑暴。

适合场景：

- 需求还比较模糊
- 还不想直接写 PRD
- 想先比较几个方案
- 想先确认边界和优先级

它会：

- 理解当前项目上下文
- 一次推进一个关键问题
- 给出 `2-3` 个方向做比较
- 输出推荐方向与待确认点
- 必要时保存脑暴结论

这个 skill 的脑暴流程来自 `obra/superpowers`，并保留了可选视觉 companion 资源。

### 2. prd

作用：生成正式 PRD 文档。

适合场景：

- 已经有需求描述
- 已经有脑暴结论，准备收口
- 需要把目标、范围、用户故事、成功指标整理成正式文档

典型输出：

- 背景
- 目标
- 用户故事
- 功能需求
- 非目标
- 成功指标
- 未决问题

### 3. ralph

作用：把 markdown PRD 转成 Ralph 风格的 `prd.json`。

适合场景：

- 已经有 `tasks/prd-xxx.md`
- 想把需求拆成可由 Codex 逐轮推进的小故事

输出特点：

- story 粒度更小
- 带优先级
- 带验收条件
- 使用 `passes` 追踪完成状态
- 适合 append-only backlog

### 4. run-ralph-codex

作用：在当前项目里执行 Codex 版 Ralph 循环。

它不是只会“跑脚本”，而是一体化入口：

- 检查项目环境
- 注入缺失的 `ralph.sh`、`CODEX.md` 和 `tmp/ralph/`
- 检查 Git 仓库状态
- 检查 `prd.json`
- 调用 `./ralph.sh --tool codex ...`

也就是说，这个 skill 已经把“初始化运行环境”和“启动执行”合并成一个入口。

## 安装

把四个技能直接复制到全局 Codex skills 目录：

```bash
mkdir -p ~/.codex/skills
cp -R skills/brainstorming ~/.codex/skills/
cp -R skills/prd ~/.codex/skills/
cp -R skills/ralph ~/.codex/skills/
cp -R skills/run-ralph-codex ~/.codex/skills/
```

安装后建议重启 Codex，让新技能被重新发现。

## 推荐使用方式

### 第一步：先脑暴

```text
使用 brainstorming 技能，先帮我脑暴这个需求
```

### 第二步：输出 PRD

```text
使用 prd 技能，把刚才确定的需求整理成 PRD
```

### 第三步：生成 prd.json

```text
使用 ralph 技能，把刚才的 PRD 转成 prd.json
```

### 第四步：执行开发循环

```text
使用 run-ralph-codex 技能，继续执行当前 backlog
```

## run-ralph-codex 关键能力

### 默认只跑一轮

```bash
/Users/liubai/.codex/skills/run-ralph-codex/scripts/run_ralph_codex.sh 1
```

语义是：

- 启动 Ralph
- 只处理一个最高优先级且 `passes: false` 的 story

### 批量跑当前 backlog

```bash
/Users/liubai/.codex/skills/run-ralph-codex/scripts/run_ralph_codex.sh --all
```

`--all` 的语义不是无限循环，而是：

- 统计当前 `prd.json` 中待完成 story 数量
- 把这个数量作为本次运行上限
- 尽量把当前 backlog 一次推进完

### 指定模型和思考深度

```bash
/Users/liubai/.codex/skills/run-ralph-codex/scripts/run_ralph_codex.sh \
  --model gpt-5.4 \
  --reasoning-effort high \
  --all
```

这两个参数会透传到底层 `codex exec`。

### Git 前置确认

如果当前目录不是 Git 仓库，`run-ralph-codex` 不会直接硬跑。

你可以：

- 明确同意初始化当前目录 Git
- 指向一个已有 Git 仓库路径
- 先退出并切换目录

初始化当前目录 Git：

```bash
/Users/liubai/.codex/skills/run-ralph-codex/scripts/run_ralph_codex.sh --init-git 1
```

指定已有仓库：

```bash
/Users/liubai/.codex/skills/run-ralph-codex/scripts/run_ralph_codex.sh --repo /path/to/repo --all
```

## 运行约定

### 1. 每轮只做一个 story

即使使用 `--all`，底层仍然是“一轮一个 story”的方式推进。

### 2. prd.json 是长期 backlog

这里的 `prd.json` 不是一次性临时文件，而是 append-only backlog。

约定：

- 旧 story 不删除
- 已完成 story 保留
- 新需求通过追加 story 进入 backlog
- 用 `passes` 表示完成状态

### 3. progress.txt 是跨轮经验记录

`progress.txt` 用来沉淀：

- 哪些命令更可靠
- 哪些测试有特殊约束
- 哪些目录或脚本有坑
- 哪些经验值得下一轮复用

### 4. 日志按时间戳写入

每轮日志会写到：

```text
tmp/ralph/YYYYMMDD-HHMMSS-TZ.iter-XXX.tool.log
```

这样可以避免多轮覆盖，也方便排查问题。

### 5. 完成状态以 prd.json 为准

这版 Codex 适配已经修复了旧 Ralph 容易误判日志中 `<promise>COMPLETE</promise>` 的问题。

现在：

- `prd.json` 是完成判定主依据
- 日志里的 `<promise>COMPLETE</promise>` 只是辅助信号

## 与原版 Ralph 的主要差异

相对于原版 Ralph，这个技能包主要做了这些改造：

- 把工作流前置成四步，而不是直接从 PRD 开始
- 新增独立 `brainstorming` skill
- 针对 Codex 做了运行适配
- 提供可直接全局安装的 Codex skill 目录结构
- 提供 `run-ralph-codex` 一体化入口
- 支持 `--all`
- 支持 Git 前置确认
- 支持 `--model` 和 `--reasoning-effort`
- 采用时间戳日志
- 明确 `prd.json` 为 append-only backlog

## 已知限制

- 这套技能依赖可用的 Codex CLI、Git 和 `jq`
- 如果当前项目还没有 `prd.json`，`run-ralph-codex` 不会替你凭空生成 backlog，而是会提示先走 `brainstorming / prd / ralph`
- `--all` 是批量推进模式，不是无限重试模式
- 如果遇到平台额度限制、网络异常或外部依赖故障，本次批量运行仍可能提前停止
- 视觉脑暴 companion 是可选增强，不是每个项目都需要启用

## 仓库结构

这次开源最重要的目录是：

```text
skills/
├── brainstorming/
├── prd/
├── ralph/
└── run-ralph-codex/
```

其中 `run-ralph-codex` 自带：

- `scripts/run_ralph_codex.sh`
- `assets/ralph-template/ralph.sh`
- `assets/ralph-template/CODEX.md`

因此它可以在目标项目里自动注入最小运行文件，而不是要求用户先手动复制整仓库根目录脚本。

## 致谢

- 原始方法论来自 Geoffrey Huntley 的 Ralph 思路
- `brainstorming` 的流程灵感来自 `obra/superpowers`
- 本仓库的重点工作，是把这套方法论整理成更适合 Codex 使用、可直接全局安装的技能包
