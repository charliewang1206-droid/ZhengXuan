# 正选进度表

这个文件记录每一次重要推进。规则：每完成一个可验证任务，就新增一条记录；如果需要返工，也照实记录。

| 时间 | 版本 | 任务 | 状态 | 完成内容 | 验证方式 | 下一步 |
|---|---|---|---|---|---|---|
| 2026-06-28 21:46 HKT | v0.1 | 工程骨架上传 GitHub | 完成 | SwiftUI、SwiftData、基础 Tab、核心模型和 Codemagic 配置已上传 | GitHub `main` 提交 `da4af3e` | 运行 Codemagic |
| 2026-06-28 21:58 HKT | v0.1 | Codemagic Simulator Build 修复 | 完成 | 将 CI 从固定 `iPhone 15` 改为通用 `iphonesimulator` 构建 | GitHub 提交 `f9c73f9` | 重新运行 Codemagic |
| 2026-06-28 22:00 HKT | v0.1 | Codemagic 首次通过 | 完成 | 云端 iOS Simulator build 通过，CI 闭环成立 | Codemagic green build | 进入 v0.2 |
| 2026-06-28 22:03 HKT | v0.2 | 分类、标签、条目功能启动 | 进行中 | 准备实现基础资料库功能和进度记录纪律 | 本地工作区 | 完成 v0.2 第一批功能 |
| 2026-06-28 22:08 HKT | v0.2 | 基础资料库第一批功能 | 待验证 | 已实现分类/子分类/评价字段/标签/条目/搜索的基础页面和校验 | 本地静态检查通过：24 个 Swift 文件均加入 Xcode 工程 | 推送 GitHub 并运行 Codemagic |
| 2026-06-28 22:13 HKT | v0.3 | 快速体验记录第一批功能 | 待验证 | 首页和条目详情已接入体验记录表单，支持核心三字段、更多细节、标签、分类评价字段、历史记录编辑和删除 | 本地静态检查通过：25 个 Swift 文件均加入 Xcode 工程 | 推送 GitHub 并运行 Codemagic |
