# LCG-P05《Old Things, New Days》原定下一阶段：Windows 内部验收清单

日期：2026-11-23。用途：保留用户先前约定的开发里程碑；仅供内部测试，不是公开发行许可。

## 已完成的先决工作（以 GitHub 实际日志为证）

- 源码和 10 个缺失外部 PNG 路径已进入 GitHub，50 个 GLB 的外部纹理 URI 均能解析。
- 来源登记表现为 132 条：原先 10 个 Kenney GLB 外部 PNG 路径 + 7 个由合法 FBX 自动提取的 PNG 均已核对来源与文件哈希。
- Godot 4.4.1 在 Linux Xvfb 实际执行过 23 组 QA，23/23 均具备退出码 0、零引擎错误和明确 PASS marker。
- 严格的 Linux 编辑器导入尚有 4 条 Vulkan 初始化 ERROR；Windows 验证不应直接继承“通过”结论。
- 证据：[`NATIVE_QA_TEXTURE_RECOVERY_AND_23_SUITES_2026-11-22.md`](NATIVE_QA_TEXTURE_RECOVERY_AND_23_SUITES_2026-11-22.md)。

## 原计划研发里程碑（按最新实际进度标记）

## 当前状态更新（2026-11-23）

- **W1 Windows 真正 Godot 4.4.1 原生引擎导入、主场景和 23/23 QA：PASS。**
- **W2 Windows INTERNAL TEST ONLY 单文件 EXE 已构建并通过隔离目录 headless 启动检查：PASS。**
- EXE 文件大小 **107,982,544 bytes**；SHA-256 `cf2a15095d11cc7475a38f57c9d34ecf282f16db5c610fa322edefa2b21c0a8c`。
- [GitHub Actions 成功运行](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45088442703) · [Windows EXE Artifact](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45088442703/artifacts/14780550862)。
- 下一阶段实际待办是 **W3 Windows 真人可视化/声音/操作试玩**及 W4 上架前来源与商标、隐私复核。并没有发布商业版本。
- 详细交接：[WINDOWS_INTERNAL_BUILD_AND_PLAYTEST_HANDOFF_2026-11-23.md](WINDOWS_INTERNAL_BUILD_AND_PLAYTEST_HANDOFF_2026-11-23.md)。



### W1 — Windows 原生引擎验证（自动化）

- [x] 在 Windows-2022 上运行 Godot 4.4.1 **Console** 编辑器；使用真正图形驱动完成全部 PNG/GLB 首次导入，记录全部 Godot ERROR。
- [x] Windows 主场景启动：退出码 0、零 Godot ERROR。
- [x] Windows 23 组本地原生测试：逐项校验其预期 PASS 标记、退出码、引擎错误行；不能只依据 Linux 23/23 判定。
- [x] 素材登记、许可、SHA-256、原生 QA 套件数量及入口仍须严格验证。
- [x] 不因 CI 环境缺 GPU 而假装编辑器完全无错误；收集真实失败日志并单独标记环境限制。

### W2 — Windows 内部 EXE（仅 W1 全 PASS 后）

- [x] 使用原有 `tools/build_windows_release.ps1` 的严格验收链，生成对应 Godot 引擎组件许可快照。
- [x] 使用已配置的 `Windows Desktop` 导出预设，启用 Embed PCK。
- [x] 验证 EXE 有 Windows PE `MZ` 头、尺寸合理、没有旁边单独的 `.pck`。
- [x] 文件名固定 `LCG-P05_INTERNAL_TEST_ONLY.exe`；内部测试构建≠上架/营销/商用审查已通过。
- [ ] 在干净 Windows 环境中验证实际双击启动，脱离原始 ZIP 和 Godot 编辑器也能读入 3D 模型。（已完成 Windows 云端隔离目录、无源代码、无独立 PCK 的 headless EXE 启动：退出码 0；真人双击及可见 3D 场景仍 NOT TESTED）

### W3 — 真实玩家设备视觉与操作（需人工截图、录屏和反馈）

- [ ] 720p / 1080p：Logo 1.8s、减弱动态跳过、选单、商店场景、三页商品目录与 27 张缩略图，记录截图。
- [ ] 六套 3D 顾客模型：walk / idle / reaching / rejection 动作、走位、比例、与商品或货架的穿插，检查不会穿过桌椅。
- [ ] 九个货架、商品拿取/上架、价格/采购反馈、手持物与地面 / 柜面 / 角色之间的碰撞。
- [ ] 鼠标视角速度三档、ESC、键盘移动、画面舒适模式、低龄或低阅读能力玩家实际理解图像化按钮。
- [ ] 近距离观察是否出现闪烁、刺眼强光或异常快速镜头变化；自动化不能宣称取得光敏安全认证。
- [ ] 在玩家设备上试听 BGM / 点击 / 上架 / 销售 / 脚步音效；自动化的静音 QA 并非实际音质测试。
- [ ] 验证普通存档、旧版兼容、.pending / .bak 恢复；手动结算二步确认；通过 X / Alt+F4 退出后重新打开，资金/库存/天数保持。
- [ ] 模拟存档目录不可写：关闭应失败且给出提示，不得错误声称已保存。
- [ ] 核对游戏内 Credits 与 Godot 4.4.1 导出版本的第三方依赖说明。

### W4 — 版权/发行关口（仅未来对公众发布时）

- [ ] Mini Shop 2.1 的原色板尚未与旧版 Mini Market 兼容色板作原始 ZIP 字节比对及视觉核对。
- [ ] 4 首 hernandack CC0 OGG 仍需原始来源字节一致性核对，或记录符合证据的替代决定。
- [ ] 工作室名称、LOGO 与游戏正式名称做目标发行市场的商标/相似标识核对。
- [ ] 实际平台的年龄分级、隐私及最终玩家体验审查（包括无障碍）；公共发行必须继续遵守 `IP_PUBLIC_RELEASE_GATE_v0165.json`。

## 测试记录模板

每个手动测试应记录日期、Windows 版本、硬件配置、Godot / EXE 版本、执行者、操作步骤、预期结果、实际结果（PASS / FAIL / NOT TESTED）、截图/录像/日志路径；未执行时一律填 NOT TESTED。

**边界：** 不创建 GitHub Release、不上传 itch.io、不声称已完成商标注册或 Windows 玩家体验验收。Google Drive 原始最新版源码 ZIP 保持不变。

## W3 执行准备更新（2026-11-23）

- [x] 15 项真人 Windows 试玩验收步骤、证据格式、故障严重度及 PASS/FAIL/NOT TESTED 规则已整理为 [`W3_WINDOWS_HUMAN_PLAYTEST_EXECUTION_KIT_2026-11-23.md`](W3_WINDOWS_HUMAN_PLAYTEST_EXECUTION_KIT_2026-11-23.md)。**这是执行准备完成，不代表 W3 真人验收完成。**
- [ ] 真人 Windows 设备执行上述 15 项并提供可复核的截图/录屏/日志；在取得证据前保留 NOT TESTED。
- [ ] 2026-11-30 UTC 之前将 GitHub Actions 内测 EXE Artifact 保存至长期备份位置；自动跨连接器上传尝试未成功，不能标记已备份。
