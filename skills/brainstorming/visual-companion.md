# 视觉脑暴指南

这是一个可选的浏览器辅助流程，用于在脑暴阶段展示：

- 线框图
- 页面布局
- 信息层级
- 架构图
- 视觉方案对比

## 什么时候使用

按“问题”判断，而不是按“整个会话”判断。

如果用户通过“看图”会比“看文字”更容易理解，就适合启用视觉脑暴。

适合：

- UI 布局
- 组件视觉方向
- 页面流程
- 数据流 / 架构图
- A/B 视觉对比

不适合：

- 纯范围讨论
- 功能优先级排序
- 约束澄清
- API / 数据模型等纯文本决策

## 目录与脚本

本 skill 使用以下脚本：

- `scripts/start-server.sh`
- `scripts/stop-server.sh`
- `scripts/server.cjs`
- `scripts/frame-template.html`
- `scripts/helper.js`

## 启动方式

在仓库环境中，可使用：

```bash
./skills/brainstorming/scripts/start-server.sh --project-dir /path/to/project
```

脚本会返回：

- 本地访问 URL
- `screen_dir`
- `state_dir`

## 基本循环

1. 启动服务
2. 将 HTML 内容写入 `screen_dir`
3. 让用户打开浏览器查看
4. 在下一轮读取 `state_dir/events`
5. 根据反馈继续展示下一屏，或回到终端继续讨论

## 使用原则

- 视觉脑暴是可选增强，不应成为普通需求的默认流程
- 只在视觉问题上使用浏览器，文字问题继续留在终端
- 结束视觉步骤后，应明确回到终端继续对话
