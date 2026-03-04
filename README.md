# Harmony Browser（ArkTS）

一个使用 ArkTS 开发的鸿蒙浏览器示例应用，参考了 UC 浏览器的常见交互模式，提供以下核心能力：

- 浏览器主页面（地址栏 + 快捷操作）
- Web 浏览内核承载
- 历史记录查看与回访
- 设置页面（暗黑主题切换）
- 适合手机/平板的底部标签导航

## 目录结构

- `AppScope/app.json5`：应用级配置
- `entry/src/main/module.json5`：模块配置
- `entry/src/main/ets/entryability/EntryAbility.ets`：入口 Ability
- `entry/src/main/ets/pages/Index.ets`：核心页面与交互逻辑

## 功能说明

1. **浏览**：支持输入网址访问，支持后退、前进、刷新、主页。
2. **历史记录**：自动记录访问页面，支持点击回访和清空记录。
3. **设置**：支持暗黑主题开关。

> 说明：此仓库为演示版本，可在此基础上继续扩展下载管理、无痕模式、多标签页、广告拦截等完整浏览器能力。
