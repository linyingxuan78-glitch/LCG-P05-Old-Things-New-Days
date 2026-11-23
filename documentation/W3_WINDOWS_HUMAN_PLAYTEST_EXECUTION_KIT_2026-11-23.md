# W3 Windows 真人试玩执行包 — 2026-11-23

**状态：待执行 / NOT TESTED。** 本文是实际操作和证据采集协议，不代表任何真人设备已验收。

## 版本锁定
- 工程：LCG-P05《Old Things, New Days》，Godot 4.4.1
- 已完成：Windows 原生导入、23/23 自动化 QA、内部单文件 EXE、隔离目录 headless 启动
- 唯一应使用的测试构建：`LCG-P05_INTERNAL_TEST_ONLY.exe`
- EXE SHA-256：`cf2a15095d11cc7475a38f57c9d34ecf282f16db5c610fa322edefa2b21c0a8c`
- 证据：[Windows CI run](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45088442703)
- [EXE Artifact](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45088442703/artifacts/14780550862)（GitHub 暂存，计划到期时间 2026-11-30 UTC；到期后需重新构建）
- 原始 Google Drive 工程 ZIP 不覆盖；不要向公众分发此内测 EXE。

## 启动与验证
1. 在 Windows 10/11 电脑下载上方 GitHub Actions Artifact，完整解压 ZIP，确认其中 EXE 文件名；不必安装 Godot。
2. 打开 PowerShell，在解压目录运行 `(Get-FileHash '.\LCG-P05_INTERNAL_TEST_ONLY.exe' -Algorithm SHA256).Hash`，与上述 SHA-256 核对；不一致时停止使用并记录。
3. 双击 EXE，观察是否出现可见窗口、开场动画、主菜单、3D 店铺；截图。若被系统拦截，不要关闭安全防护或擅自忽略警告。
4. 记录 Windows 版本、CPU、GPU、内存、屏幕分辨率、是否有外接音箱/耳机、游戏版本、日期。
5. 按下面测试编号逐一执行。每条都必须写 PASS / FAIL / NOT TESTED；失败附最短复现步骤、截图/录屏及错误原文。不要凭自动化通过直接填 PASS。
6. 试玩时避免将私人存档、用户名或本地文件路径发到公开仓库；如需共享日志先清除个人信息。

## W3 现场验收清单

| ID | 现场操作 | 预期/观察重点 | 结果 |
| --- | --- | --- | --- |
| W3-01 | 双击 EXE，正常窗口启动、退出、重新启动 | 不依赖编辑器；无丢失贴图、崩溃、错误弹窗 | NOT TESTED |
| W3-02 | 1280×720、1920×1080 各截图菜单和店内 | UI 不被裁切，文字/图标可辨认 | NOT TESTED |
| W3-03 | 观看 1.8 秒品牌开场、启用减少动态后重启 | 时长、跳过与过渡无异常 | NOT TESTED |
| W3-04 | 走访九个货架、全部六类共 27 个商品 | 模型纹理/缩略图/比例/位置正确 | NOT TESTED |
| W3-05 | 观察六套顾客模型与 idle、walk、reaching、rejection | 骨骼动画自然、人物不会穿过货架/桌椅 | NOT TESTED |
| W3-06 | 鼠标视角三档、键盘移动、ESC、菜单焦点 | 视角、交互与退出可操作 | NOT TESTED |
| W3-07 | 进货、定价、摆货、成交、议价、日结算确认 | 金额、库存、天数变化正确，确认步骤可见 | NOT TESTED |
| W3-08 | 分别试听 BGM、点击、上架、销售、脚步 | 音效可听、无爆音、音量设置有效 | NOT TESTED |
| W3-09 | 正常保存、退出、重开 | 资金、库存、日期一致 | NOT TESTED |
| W3-10 | 用一次窗口 X 和一次 Alt+F4 退出、重开 | 成功保存才退出，数据不丢 | NOT TESTED |
| W3-11 | 使用**独立测试存档**验证 .pending/.bak、损坏档案 | 只恢复有效备份，损坏档案不误报成功 | NOT TESTED |
| W3-12 | 在可安全恢复的独立测试账户模拟存档不可写 | 明确警告且不虚称保存成功 | NOT TESTED |
| W3-13 | 观察画面舒适、对比、大字、图像按钮、五步教程 | 可辨认、不出现明显闪烁或强光 | NOT TESTED |
| W3-14 | 在游戏内打开 Credits、隐私与健康游玩说明 | 版权文本可读、退出/删除选项符合实际行为 | NOT TESTED |
| W3-15 | 与 Mini Shop 2.1 **官方原色板**对照截图 | 兼容色板是否偏色；无原始文件则 NOT TESTED | NOT TESTED |

## 错误反馈格式

```text
Test ID:
Date / Windows version:
CPU / GPU / RAM:
Resolution:
EXE SHA-256:
Result: PASS / FAIL / NOT TESTED
Steps:
Expected:
Actual:
Screenshot / video filename:
Error text (if any):
Severity: blocker / major / minor / cosmetic
```

## 通过规则
- W3 不以「23/23 自动化通过」替代真实操作验收。
- FAIL 必须能复现并指向具体模型、交互或状态；NOT TESTED 不能当 PASS。
- 真实 Windows 视觉、音频、碰撞和存档尚未验收，故 **不能宣称可正式发行**。
- 发现问题先修复工程、重新执行 Windows 原生 23 组 QA，再生成新的内部 EXE 和新的哈希；不要沿用旧构建测试结论。

## W4 并行工作（不阻塞本轮内部试玩）
- 找回 Mini Shop 2.1 官方 ZIP，逐字节对照 colormap 并做可见画面对比。
- 核对四首 hernandack CC0 OGG 原始来源/文件；当前来源声明不是字节级证据。
- 继续保留商标/正式游戏名、第三方 Credits、年龄分级、隐私和发行平台审核的未完成状态。
