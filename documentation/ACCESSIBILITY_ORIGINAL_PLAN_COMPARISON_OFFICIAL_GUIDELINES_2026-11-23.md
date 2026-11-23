# LCG-P05《Old Things, New Days》原始计划／无障碍保留核查与官方标准对照

**日期：2026-11-23；性质：源码审查及自动化测试记录，不是无障碍认证或公开发行许可。**

## 1. 实际核对的原始记录及限制

1. Google Drive 原始 `LCG_P05_LATEST_Godot_Project.zip`（v0.16.9）：逐文件阅读 `documentation/ACCESSIBILITY_AND_ONBOARDING_REVIEW_v0158.md`、`MERGE_AND_ACCESSIBILITY_AUDIT_v0157.md`、`PRIVACY_SAFETY_AND_ACCESSIBILITY_v0161.md`、`HEALTHY_PLAY_AND_FAMILY_GUIDE_v0160.md`、`DEVELOPMENT_HISTORY_UP_TO_v0161.md`、`STATUS_AND_NEXT.md`、`RELEASE_GATES_v0162.md`。
2. 已提供的 `接手游戏开发.pdf` 只有两页，内容是旧 GitHub 仓库交接与权限，并**不包含整个历史聊天记录**。因此「原始设计」以原始 ZIP 内的历史资料、旧版测试与可检索的相关聊天内容为依据，不能假称逐字审阅了所有更早对话。
3. GitHub `main` 当前工程、源码、23 组 Godot QA 及 Windows Actions 日志均已重新检查；原始 Drive ZIP 没有被覆盖。
4. 使用 Git **blob SHA-1** 对比，原始 ZIP 与当前 GitHub 以下文件内容完全一致：
   - `documentation/ACCESSIBILITY_AND_ONBOARDING_REVIEW_v0158.md`：`3a2794e404f6f8a9d18bd6e2428b44f81c8be156`
   - `documentation/HEALTHY_PLAY_AND_FAMILY_GUIDE_v0160.md`：`f4c074e5e5d1ae7a61dfc10b69fe3b4b33148ef7`
   - `documentation/PRIVACY_SAFETY_AND_ACCESSIBILITY_v0161.md`：`a93435fed60622c8a040ed6882721611c43a00d7`
   - 原始 `scripts/healthy_play.gd` 和 `scripts/privacy_safety.gd` 在本轮修改**之前**也完全一致；本轮仅新增了菜单键盘焦点逻辑，保留其时间提醒、数据删除、安全与存储行为。

## 2. 功能保留核对

| 最初确认的功能 | 当前检查状态 | 证据／局限 |
| --- | --- | --- |
| 五步事件触发教程（桌面→买入→上架→定价→首次成交），可跳过／重播 | **保留** | `scripts/shop.gd`、`qa_v014_onboarding_and_accessibility.gd`、`qa_v0158_visual_comfort_and_tutorial.gd` |
| 四幅静态流程图及 OK/WAIT 文本，指示不只靠颜色 | **保留并修复重叠** | 96px 素材显示至 42px 图标槽，双行文字、下方事件文字独立；已有 720p/1080p Godot 截图 |
| 六类别图标、27 件商品图片、九个货架 | **保留** | 原始资料与现有源码、经营目录和原生 QA |
| 近货架按 E 放货、不强迫精准对准小碰撞体；TAB 开经营桌 | **保留** | `_near_matching_shelf` 等；真实物理碰撞操作仍需真人设备测试 |
| 文字变大、高对比度、减少动态、图像指南、简洁 HUD | **保留** | 菜单保留七项设置；大字模式当前只是约 112%，**未达到建议的完整 200% 缩放** |
| 柔和镜头（FOV 70 vs 74）、柔和光照与减弱动态新用户默认开启；鼠标速度三档 | **保留** | `scripts/shop.gd` 默认配置、设置持久化与原生 QA |
| 帮助说明可滚动、F1／ESC、清晰键盘焦点外框 | **保留／本轮改善** | 菜单初始焦点、Tab/Shift+Tab、返回焦点，已加原生 QA |
| 25 分钟休息／90 分钟家庭计划初始提醒，可更改或关闭、不会强制结束 | **保留** | `scripts/healthy_play.gd`，独立本机偏好；具体分钟数只是可调设计选项 |
| 可选隐私与安全说明，游戏无额外登录／聊天／追踪 SDK，本机存档二次确认删除 | **保留** | `scripts/privacy_safety.gd`、`qa_v0161`；不代表操作系统／云备份可删除 |
| 静态、不主动闪烁的提示；可跳过 1.8 秒开场 | **保留** | `qa_v0168`；不能凭代码保证光敏安全 |
| 六款 3D 顾客、店铺经营事件及可选社区结局 | **保留** | 原始工程及 23 组原生测试；真实角色动画／碰撞仍待验收 |

## 3. 本轮具体修改（与原决定没有冲突）

- `scripts/shop.gd`：菜单启动明确聚焦可用控件；有序 Tab／Shift+Tab；从设置与帮助返回到入口按钮；保持正常游戏 WASD/鼠标/E/TAB 操作。
- `scripts/shop.gd`：高对比度模式下，按钮普通／悬停／按下背景改为深色，边框更清楚；关闭模式后恢复原柔和绿色主题。之前白字配旧悬停绿色约 4.0:1，不满足 Xbox XAG 102 对高对比度模式的 7:1 指南；深色背景可提升至明显高于这一值。**此指标是特定颜色组合的工程估算，不等于整个游戏已通过专业对比度测试。**
- `scripts/healthy_play.gd`：开启可选家庭时间页时聚焦其可用控件，退出后还原原来来源菜单的焦点。
- `scripts/privacy_safety.gd`：进入隐私页、二次删除确认页、取消删除以及返回主菜单时管理焦点；未改变 `qa_mode` 删除保护或数据政策。
- 原有 `qa_v0158`、`qa_v0160`、`qa_v0161` 增加验证，仍保留原定 **23 个 QA 套件**，没有拿模拟测试替代真实引擎运行。
- `tools/ci_capture_viewport_v0171.gd`：扩展 Windows Godot 实际截图，覆盖标题、设置默认、大字+高对比度、帮助、健康时间、隐私以及 720p／1080p 商店（共 8 张），不会写入实际玩家存档。

## 4. 官方开发资料（官方建议不等于已获认证）

- Godot 4.4：Keyboard/Controller Navigation and Focus — https://docs.godotengine.org/en/4.4/tutorials/ui/gui_navigation.html 。进入菜单时显式 `grab_focus()`，不要完全依赖自动焦点选择。
- Xbox XAG 101 Text Display — https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/101 。PC/VR 1080p 建议默认文字至少 18px，并允许最高 200% 缩放而不丢功能；此工程部分小字仍需重新布局与可用性验证。
- Xbox XAG 102 Contrast — https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/102 。重要普通文字约 4.5:1，高对比度模式参考 7:1，且必须对所有显示状态检查，包括 hover、disabled。
- Xbox XAG 103 Additional Channels — https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/103 。关键提示勿只靠一种感觉或颜色；图像+文本是部分措施。
- Xbox XAG 107 Input — https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/107 。应考虑操作重映射和更多输入选择。当前仅已有 WASD／方向键、鼠标与几项操作捷径，不是完整重映射支持。
- Xbox XAG 112 UI Navigation — https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/112 。菜单焦点需清晰连贯，复杂布局的焦点路径不应凭猜测。
- Xbox XAG 117 Motion — https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/117 。减少自动移动／闪烁以及调整镜头，和已有默认柔和选项方向一致。
- Xbox XAG 118 Photosensitivity — https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/118 。必须测试实际画面，不能以「代码没有闪光」宣称安全。
- W3C WCAG 2.2 — https://www.w3.org/TR/WCAG22/ 。文字对比、焦点、输入大小等可作为补充参考，但网页规范不自动等于游戏认证。

## 5. 原始待办再次分类

| 里程碑／待办 | 结果 |
| --- | --- |
| W1 Windows Godot 4.4.1 真实导入及 23/23 原生 QA | **已完成**（已取得成功 Windows Actions 证据） |
| W2 Windows INTERNAL TEST ONLY 单文件 EXE、独立启动 | **已完成内部测试构建**；不是可公开发行的认证 |
| W3 软件渲染实际截图、HUD／菜单重叠修复 | **已完成自动截图及源代码修正**；截图工具退出时仍存在 GLES3 RID 释放错误 |
| W3 键盘菜单焦点与返回路径 | **本轮已实现并加入回归测试** |
| W3 高对比度按钮可读性 | **本轮已修复并加入回归测试** |
| W3 实机操作（键鼠／碰撞／六顾客动画）、真实音频、720p/1080p 设备效果、存档与关闭后重开 | **NOT TESTED；需要有人在实际 Windows 玩家设备操作并提供证据** |
| 高达 200% 的完整字体和 UI 重排、全键位重映射、屏幕朗读／多语言／完全非阅读者操作路径 | **NOT IMPLEMENTED／未取得完成证明，不能冒充已无障碍** |
| 完整光敏风险评估、低视力／低阅读能力玩家使用测试 | **NOT TESTED；不可由静态代码替代** |
| W4 Mini Shop 2.1 官方原色板比对、四首音乐原始字节证据、正式名称／商标、年龄分级、地区发行要求 | **NOT VERIFIED／暂缓对公众发行** |

## 6. 自动化证据与解释

- [2026-11-23 已完成的 Windows 原生 23/23＋内部 EXE](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45096952298)。
- [首次菜单焦点修复后 Windows 23/23 及内测构建成功](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45104072125)。
- [增强按钮对比度与新回归测试 Windows 工作流](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45104676321)。
- [可选家庭／隐私菜单焦点回归 Windows 工作流](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45104919282)。
- [Windows Godot 截图，包含扩展无障碍视图](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45104968106)。

**未解决：** Windows 云端的独立截图工具在所有 PNG 保存成功后仍会记录 GLES3 `Texture` RID 与 `CompressedTexture2D` 退出清理错误，因此截图工作流的总体状态不能写成 PASS。严格 Windows 游戏原生 QA 和这个工具的退出错误是不同问题。

**结论：** 旧版无障碍功能并没有在本轮被无依据地删掉。已完成可直接执行的键盘与高对比度源码改进；其余真实玩家体验、全面阅读可及性、原件版权及公共发行关口不能仅靠源码自动宣告完成。

## 2026-11-23 追加：8 张 Windows 真画面检查发现并修复的问题

- `HEALTHY PLAY / FAMILY GUIDE` 的三段家庭计划文字在旧版实际 1280×720 截图里曾越过面板边缘；原版 Label 的固定尺寸不会约束自动字体高度。
- 保留三个原本段落（家庭制定日常计划、提醒不是强制锁、数据只在本机）的实际文字，健康面板扩展为 680×620，说明区域移入有键盘焦点的 `ScrollContainer`，明确启用 `clip_contents`，在 720p 保留完整文字与底部 Back 按钮。
- 新增 `qa_v0160_healthy_play.gd` 断言，检查滚动容器尺寸、内容存在、底部按钮可访问、文本未删。
- 旧版多张真实截屏已显示家庭说明超出边界；修正后的 Windows 自动截图显示可见的垂直滚动条、文字被限制在容器内（滚动到下方才能阅读最后一段）。这属于**UI 排版修复，不是完整认知/视觉无障碍认证**。
- [扩展 8 张实际图像的运行记录](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45105698714)（截图生成完成，但独立工具退出时仍有 GLES3 资源释放 ERROR，工作流整体未通过）。
- 新的 [Windows 原生 23 项／内部 EXE 验证运行](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45105698738)；以该运行最终结论和日志为准，不能预先标记成功。
