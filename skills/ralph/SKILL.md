---
name: ralph
description: "将现有 PRD 转换为 Ralph 使用的 `prd.json`。当你已经有 markdown PRD，想把它拆成可由 Ralph / Codex 自动迭代执行的小故事时使用。触发示例：转换这个 prd、生成 prd.json、转成 ralph 格式、拆成自动执行故事。"
---

# Ralph PRD 转换器

将现有 PRD 转换为 Ralph 使用的 `prd.json`，供后续自动迭代执行。

本 skill 使用纯 `SKILL.md` 工作流编写，可被 Codex 及其他兼容运行时直接发现，无需依赖 marketplace 专属元数据。

## 工作流

**输入：** markdown PRD 文件或原始 PRD 文本。

将 PRD 转换为当前 Ralph 目录中的 `prd.json`。

## 输出格式

```json
{
  "project": "[项目名]",
  "branchName": "ralph/[feature-name-kebab-case]",
  "description": "[来自 PRD 标题或概述的功能描述]",
  "userStories": [
    {
      "id": "US-001",
      "title": "[故事标题]",
      "description": "作为一个 [用户]，我想要 [能力]，以便 [收益]",
      "acceptanceCriteria": [
        "标准 1",
        "标准 2",
        "Typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

## 最重要的规则：故事必须足够小

**每个故事都必须能在一轮 Ralph 迭代中完成。**

合适的粒度示例：

- 增加一个数据库字段和迁移
- 为现有页面增加一个 UI 组件
- 调整一个服务端 action 的逻辑
- 为列表增加一个筛选下拉框

过大的示例：

- “做完整个仪表盘”
- “增加认证系统”
- “重构整个 API”

判断标准：

- 如果一个改动无法在 2-3 句话内说清，就通常太大，需要继续拆。

## 故事排序规则

故事按依赖顺序排序，前面的故事不能依赖后面的故事。

推荐顺序：

1. 数据库 / Schema / 迁移
2. 服务端逻辑 / Action / API
3. 前端组件
4. 汇总页 / Dashboard / 组合视图

## 验收标准规则

验收标准必须是 Ralph 可以检查的内容，而不是模糊主观描述。

好的例子：

- 增加 `status` 字段，默认值为 `pending`
- 筛选下拉框包含 `All / Active / Completed`
- 点击删除时先出现确认弹窗
- `Typecheck passes`
- `Tests pass`

不好的例子：

- “功能正常工作”
- “用户体验更好”
- “处理各种边界情况”

固定规则：

- 每个故事都必须包含 `Typecheck passes`
- 涉及可测试逻辑时建议加入 `Tests pass`
- 涉及 UI 变更时加入 `Verify in browser using dev-browser skill`

## 转换规则

1. 每个用户故事对应一个 JSON 条目。
2. `id` 使用顺序编号：`US-001`、`US-002`。
3. `priority` 按依赖顺序和文档顺序生成。
4. 新故事默认 `passes: false`，`notes` 为空字符串。
5. `branchName` 从功能名生成，使用 kebab-case，并加上 `ralph/` 前缀。
6. 每个故事都自动补上 `Typecheck passes`。
7. 如果 `prd.json` 已存在，应保留原有 stories，并将新 stories 追加到 `userStories`，不要整体覆盖。

## 大需求拆分示例

原始需求：

> 增加用户通知系统

合理拆分：

1. US-001: 为数据库增加 notifications 表
2. US-002: 增加通知发送服务
3. US-003: 在顶部栏增加通知铃铛
4. US-004: 增加通知下拉面板
5. US-005: 增加已读标记能力
6. US-006: 增加通知偏好设置页

## 已有 backlog 的处理方式

当 `prd.json` 已存在时，把它视为 append-only backlog：

1. 读取现有 `prd.json`
2. 保留旧 stories，包括已完成 stories
3. 将新故事追加到 `userStories`
4. 除非用户明确要求清理，否则不要重置 `passes`、`notes` 或历史记录
5. 如果新 PRD 对应了不同分支目标，也不要删旧故事；应通过说明或 notes 记录差异

## 示例

输入 PRD：

```markdown
# 任务状态功能

增加任务状态能力。

## Requirements
- 在任务列表中切换 pending / in-progress / done
- 按状态筛选
- 每个任务展示状态徽标
- 状态持久化到数据库
```

输出 `prd.json`：

```json
{
  "project": "TaskApp",
  "branchName": "ralph/task-status",
  "description": "任务状态功能：支持展示和管理任务进度状态",
  "userStories": [
    {
      "id": "US-001",
      "title": "为任务表增加状态字段",
      "description": "作为开发者，我需要在数据库中存储任务状态。",
      "acceptanceCriteria": [
        "增加 status 字段：pending | in_progress | done，默认 pending",
        "成功生成并执行迁移",
        "Typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

## 保存前检查

- [ ] 现有 `prd.json` backlog 已保留，新故事采用追加方式
- [ ] 每个故事都足够小，可在单次迭代中完成
- [ ] 故事顺序符合依赖关系
- [ ] 每个故事都包含 `Typecheck passes`
- [ ] UI 故事包含 `Verify in browser using dev-browser skill`
- [ ] 验收标准都可验证，不含模糊表述
- [ ] 没有故事依赖后面的故事
