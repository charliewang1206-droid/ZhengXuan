# 正选 ZhengXuan

正选是一个本地优先的私人生活体验评价与选择 App。第一版坚持离线可用、即时记录、私人评价、降低纠结、鼓励探索和可导出迁移。

当前提交完成阶段 1：原生 iOS 工程骨架、SwiftUI 入口、SwiftData 本地数据库配置、核心模型、基础 Tab 信息架构、集中化显示名称配置。

## 如何运行

1. 在 macOS 上使用 Xcode 15 或更新版本打开 `ZhengXuan.xcodeproj`。
2. 选择 `ZhengXuan` scheme。
3. 选择 iPhone Simulator，点击 Run。
4. 如果要安装到真实 iPhone，请在 Xcode 的 Signing & Capabilities 中选择你的开发者团队。

最低系统版本：iOS 17.0。

## 项目结构

- `Config/AppConfig.xcconfig`：集中配置 App 显示名称、Bundle Identifier、最低 iOS 版本。
- `ZhengXuan/App`：App 入口、全局配置、底部 Tab 导航。
- `ZhengXuan/Design`：轻量设计常量。
- `ZhengXuan/Models`：SwiftData 核心模型与业务枚举。
- `ZhengXuan/Features`：按功能拆分的页面骨架。
- `ZhengXuan/Resources`：Info.plist 与系统启动页配置。

## 数据模型

阶段 1 已建立以下 SwiftData 模型：

- `ZXCategory`：分类，支持父子分类、图标、颜色、排序、说明、归档。
- `RatingFieldDefinition`：分类评价模板字段，支持评分、单选、多选、布尔、短文本、数字、可选备注。
- `ZXTag`：横向标签，可关联条目和体验记录。
- `ZXItem`：被评价对象，支持主分类、子分类、标签、收藏、想尝试、归档、封面路径。
- `ExperienceRecord`：体验记录，包含总体感受、再次选择意愿、一句话印象和可选上下文。
- `ExperienceFieldValue`：动态评价字段值，保留可查询的数值、文本、布尔和选项结构。

## 如何测试

阶段 1 可先用 Xcode 执行 `Product > Build` 验证工程编译。后续阶段会逐步加入推荐逻辑、导入导出和统计逻辑的单元测试。

## 导出导入数据

阶段 5 会实现：

- 全量 JSON 导出与导入。
- 体验记录 CSV 导出。
- iOS 系统分享面板。
- 覆盖导入与合并导入的风险提示和结果摘要。

## 未来接入 iCloud / CloudKit

当前模型已尽量保持本地结构清晰。未来可在不改变核心页面结构的前提下：

1. 保持 SwiftData 模型为主。
2. 增加 CloudKit container 配置。
3. 为导入导出结构保留 schema version。
4. 在同步开启前提供本地备份导出入口。

## 阶段 1 已完成

- 创建可打开的 Xcode 工程。
- 配置 iOS 17、SwiftUI、SwiftData。
- 建立五个底部 Tab：首页、分类、帮我选、探索、我的。
- 集中配置显示名称和 Bundle Display Name。
- 建立核心数据模型和枚举。
- 添加基础空状态和首页概览。

## 下一阶段

阶段 2 会实现分类、标签、条目的 CRUD，补上分类详情、条目列表和基础搜索能力。

