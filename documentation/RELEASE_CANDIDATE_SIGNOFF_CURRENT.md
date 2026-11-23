# LCG-P05《Old Things, New Days》发行前验收总表（当前有效）
**日期：2026-11-23｜只维护一份游戏｜一次买断、离线游玩、不含广告及游戏内购买｜尚未允许公开售卖。**
本文件优先于早期 `v0.16.x` 历史状态报告。成功的自动化测试不等于真实用户验收；未测试项目必须保留 NOT TESTED。

## 已实际完成的自动化证据
| 检查内容 | 结果 | 证据及适用范围 |
|---|---|---|
| Windows Godot 4.4.1 引擎导入、23/23 原生脚本、打包 EXE 与来源文件之外启动 | **PASS** | [Windows 成功工作流](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45132214635)，使用已发布的 INTERNAL TEST ONLY。 |
| 10 张真实 Godot 画面、纹理和退出时 GLES3 清理 | **PASS** | [Windows 视觉工作流](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45132214612)；覆盖 720p/1080p、设置、健康提示、隐私、经营事件。不代表不同实体电脑都能正确显示。 |
| 游戏真正 `_save_game`，独立进程关闭后新进程 `_load_game` | **PASS** | [Windows 独立临时账户测试](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45152027895)；恢复 $137、第四天、商品数量与价格、临时存箱数及邻里好感；sandbox 路径隔离，不读取用户存档。 |
| 既有 .pending/.bak/坏档案保护 | **PASS — 自动化测试** | `tests/qa_v0163_save_recovery.gd` 以及上述 Windows 原生运行；实际断电和普通家庭电脑上的持久性仍需人工测试。 |
| 4 首背景音乐与其 CC0 作者原始 OGG 逐字节比对 | **4/4 PASS** | [音乐原件 SHA-256 工作流](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45151817068) 和 [完整记录](MUSIC_ORIGINAL_BYTES_VERIFIED_2026-11-23.md)；官方作者页面 https://opengameart.org/content/short-loops-background-music-pack。 |
| 8 个游戏 OGG 音频在 Godot 可加载 | **PASS — 文件导入** | Windows [音频诊断](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45152027895)；不是声卡试听结果。 |
| Godot 本机英文语音技术能力 | **AVAILABLE IN CI** | 云端 Windows 可检测到两种英文系统语音；游戏开启 `audio/general/text_to_speech=true`；不表示所有电脑都安装了声音、音量正常、低阅读年龄玩家能够理解。 |
| 四种画面尺寸的 Windows CI 帧时间 | **MEASURED, NOT A PLAYER PERFORMANCE PASS** | 1024×768 平均约 22.6 wall-FPS；1280×720 约 14.4；1366×768 约 13.8；1920×1080 约 7.4；每个尺寸 90 帧。**这台云端机器使用 Microsoft Basic Render Driver 软件渲染而非游戏显卡**，不能用这些数值当作玩家的最低或推荐电脑配置，也不能直接宣称游戏优化达标。 |

## 尚未通过的发行关口
**P0 / REQUIRED HUMAN SIGN-OFF**
- [ ] 在一台真实 Windows 笔记本或台式电脑上双击最新版 EXE；确认正常出现窗口、字幕、3D 材质、无防病毒误报和崩溃。
- [ ] 测试至少 1280×720 和 1920×1080，观察文字裁切、图标尺寸、颜色、明暗；录屏且填写真实 GPU、CPU、RAM、Windows 版本和 FPS，特别检查低端机器。
- [ ] 用真人键盘鼠标走动、旋转镜头、E 放货、Tab 开经营桌、选择商品/定价/完成销售，走访九个货架；测试菜单 Tab、Shift+Tab、Esc、F1，遇到故障须留下复现步骤。
- [ ] 观察六款顾客模型、idle/walk/reach/reject 等动作、路径、碰撞、商品与桌椅互相穿透。
- [ ] 真实试听四首背景音乐和点击／脚步／销售音效，调整主音量、音乐、效果音到 0 和 100%；要求无明显爆音或完全静音。
- [ ] 安装英文 OS voice 的玩家在事件页实际点击扬声器并听清两个选项；没有 OS voice 时检查按钮禁用后仍能完全操作。
- [ ] 正常保存、退出、重启，再测试关闭窗口 X/Alt+F4；仅用**临时测试存档**检查备份与损坏数据，绝不可试坏真实玩家存档。
- [ ] 找愿意参与的低阅读能力用户／儿童在家长允许和监督下尝试图示事件，记录能否无需读懂英文作出选择；目前不能宣传“完全不识字也能独立玩完整游戏”。
- [ ] 真实玩家光敏、动态与舒适性体验；自动化没有办法取得完整光敏安全认证。
- [ ] 找回 Mini Shop 2.1 原始原色板或清楚核实合法替代方案；目前只证明部分材质兼容，并不能冒充完全同色。
- [ ] 核查 `Old Things, New Days` 和 `Little Cozy Games` 在准备售卖的国家或地区的商标/近似名称；不要把普通网络搜索当成完整商标清查。

## 买断制上架：不花钱先准备，不擅自发布
- 候选低起步费用渠道：**itch.io Paid**，项目要选择 **Paid** 并设最低价格，不要误选可零付款下载的 `Donate/0`，否则无法保证一次买断才能下载。官方：https://itch.io/docs/creators/pricing 。
- 付款资料和税务须依法如实填写。发行人应当符合官方账户条款：成年，或具备合法的父母/监护人同意并有能力订立协议。支付平台也有独立要求，不能绕过身份验证。官方：https://itch.io/docs/legal/terms 及 https://itch.io/docs/creators/payments 。
- **Steam 不是零启动费用**：每款新作品 US$100 Steam Direct，另有首发等待和 Coming Soon 要求。只有在真人测试、名称和授权确认、发行账户可行时再考虑，不需要现在付款。官方：https://partner.steamgames.com/doc/gettingstarted/appfee 及 https://partner.steamgames.com/doc/gettingstarted/onboarding 。
- 马来西亚 MyIPO 说明原创版权通常自动产生，不以先行版权登记作为存在条件；**版权和商标是不同问题**，且商店账户/税务是否需登记经营身份必须根据发行地与个人情况确认。官方：https://www.myipo.gov.my/faq/ 和 https://www.myipo.gov.my/search-trademark/ 。
- 官方 WIPO 商标查询：https://www.wipo.int/en/web/global-brand-database/index 。网页搜索不是商标法律意见。
- 尚未建立商品页面、未登录卖家账户、未提交身份资料、未付款、未上传零售 EXE、未开启售卖。
- 当前 Windows EXE 仍是 **INTERNAL TEST ONLY**；不要直接上传作为正式商品。店铺截图、最低电脑配置、语言与无障碍标签只填写**真实验证**结果。

## 商店风格和成本纪律
- 一次买断 / 单人离线 / 无联网玩家账户、广告、抽奖付费和订阅（工程检查不等于完整安全审计）。
- 保留 27 件商品、六种类别、九货架、已有存档与经营决策；七种真实生活事件属于现有游戏的一部分，不再为了增加版本号扩建系统。
- 修 bug 必须有复现步骤和回归测试；任何改变二进制的代码需重新跑 23/23 Windows 和截图，然后更新 Drive **同一个 LATEST ZIP/EXE**。历史备份保留，不重复购买素材。
- 未获得至少一台真实玩家 Windows 完整验收与素材/名称/商店确认之前：**RELEASE READY = NO**。
