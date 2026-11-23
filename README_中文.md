> **当前发行验收事实（2026-11-23，最新）：** Windows Godot 4.4.1 原生导入、原定 **23/23** 套游戏测试、内部 EXE 导出和独立启动在 [最新版严格 Windows 流程](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45153165346) 均成功；旧的 10 张 Windows 真实截图和纹理退出清理在 [视觉流程](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45132214612) 通过。**游戏还不能对外发售，仍需要真人设备操作／听觉／显卡性能／图示理解，以及名称与商店账户审查。**
>
> **新增发行实际测试：** [独立进程真实保存与重新打开、四分辨率虚拟云端渲染、音频载入及英文系统语音能力](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45152027895) 已执行。保存恢复 PASS；八首 OGG 全部可载入；Windows runner 有两个英文系统语音。但**云端 Microsoft Basic Render Driver 1080p 软件渲染约 7.4 FPS，并不能当成用户实际显卡结果；实际音频也未被真人试听**。
>
> **音乐授权已补齐原文件证明：** [四首 hernandack CC0 OGG 原站逐字节 SHA-256 4/4 全匹配](documentation/MUSIC_ORIGINAL_BYTES_VERIFIED_2026-11-23.md)，不是只看网站写 CC0。发行最新依据：[当前验收表](documentation/RELEASE_CANDIDATE_SIGNOFF_CURRENT.md)及[尚未公开的买断制店铺文案](documentation/STORE_PAGE_DRAFT_UNPUBLISHED.md)。原有 Google Drive [LATEST 完整源码](https://drive.google.com/file/d/1OVX5BUi6OOUwlErkhS0mMToqOYBfgJUE/view)和[Windows 内测 EXE](https://drive.google.com/file/d/1DU1toHcscDcYNDzj4szfH8afHkTuE1I8/view)仍使用同一个文件 ID；下面较旧日期/版本号和测试证据仅作历史记录。

> **经营事件与低阅读门槛升级（2026-11-23，已通过 Windows 原生测试）：** 已将七种真实经营情境的原创改编加入同一份二手店游戏：免费衣架、旧电器检查、私人物品归还、无价签商品、捐赠整理、通道障碍、家具修复。经营桌通过图标 SORT 自愿进入，**不强迫玩家读长文本**；两张大型图示按钮、独立状态符号、处理后大图标＋数字，以及可选的 Windows 英语系统朗读（无需联网收费服务）用于辅助理解。第一二营业日仍是安静教学；旧存档兼容。语音仅覆盖新增事件，尚非全游戏无字玩法。
>
> **本次真实 Windows 4.4.1 Godot 23/23 原生测试、单文件内测 EXE 导出和独立启动均通过**：[测试记录](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45126152356)。原来的 27 种商品、9 个货架、无障碍设置、安全存档和买断制／离线方向未删除。最新源码与 EXE 正在统一回写现有 Google Drive LATEST 文件 ID，不另加新版本号。研究资料不代表全部 48 件事都已在游戏里实现，具体见 [经营事件完成清单](documentation/PICTURE_FIRST_REAL_WORLD_THRIFT_EVENTS_2026-11-23.md)。
>
> **统一主工程说明（2026-11-23）：此项目只维护一个连续的游戏，不再为了修修补补不断增加版本号。** 最新源代码已从 GitHub 全量整理并回写到 [Google Drive 唯一 LATEST 源码 ZIP](https://drive.google.com/file/d/1OVX5BUi6OOUwlErkhS0mMToqOYBfgJUE/view)。原 11月22日版本已改名备份，不会覆盖；开发留档和修改均以 Git commit 记录。
>
> **最新经过验证的 Windows 内测 EXE**：[Google Drive 内测 ZIP](https://drive.google.com/file/d/1DU1toHcscDcYNDzj4szfH8afHkTuE1I8/view)；[Godot 4.4.1 Windows 23/23 QA、EXE 导出与隔离启动全部 PASS](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45105698738)。**注意：只是内部测试，绝不代表正式发售或真人试玩已验收。**
>
> **既定商业模式：一次买断、单机离线，不增加广告、订阅、道具付费或强制账号。** 下一阶段停止无目标增加商品／场景，集中处理真实 Windows 人工试玩、音乐原始文件证明、最终商品名称和上架合规。见 [发行冻结与签收表](documentation/ONE_TIME_PURCHASE_RELEASE_FREEZE_AND_SIGNOFF_2026-11-23.md)。以下旧版本小节只保留作历史，旧日期／链接／状态不再代表当前工程。

# Little Cozy Games · Old Things, New Days · LCG-P05 v0.16.9 — 当前唯一最新版

> **最新状态（2026-11-23）：Godot 4.4.1 Windows INTERNAL TEST ONLY EXE 已成功构建。** Windows 原生资源导入、主场景启动、23/23 QA 与来源登记（132 项）均通过。
> 已在 Windows 云端的无源码临时目录执行 EXE 无界面独立启动检查：退出码 0、零 Godot ERROR。**实际有人操作的画面、音效、键鼠、碰撞与存档测试仍 NOT TESTED**，并未公开发行。
>
> **内部试玩版：** [GitHub Actions 下载（压缩包）](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45088442703/artifacts/14780550862) · [全部通过的构建证据](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45088442703)。
> **当前交接与下一步：** [Windows 内部测试报告](documentation/WINDOWS_INTERNAL_BUILD_AND_PLAYTEST_HANDOFF_2026-11-23.md)。
>
> **以下各小节保留 v0.16.2–v0.16.9 当时的历史开发记录。旧段落中“尚未运行 QA、尚未导出 EXE、115 项素材”的描述已被 2026-11-23 的实际 CI 结果取代。**

## 玩家将会体验什么？

玩家第一人称走进温馨的二手商店，经营 **27 种可售商品／6 大类／9 个共用陈列区**：进货、拿货、上架、定价、接待顾客、每日结算；另有居民转让、少量天气/社区经营事件、顾客议价及寻求替代品、按需播放的社区旧物日软结局。六套顾客 3D 外观和动画控制已写入工程，尚需实机验证动作姿势和移动路线。

## v0.16.3 历史新增：存档安全与恢复（2026-11-22）

- 存档先写 `*.pending` 并验证内容，再替换正式 JSON，避免直接清空旧存档。
- 有效旧存档会保存为 `.bak`；Windows 替换失败时仅在备份校验通过后才尝试移除旧文件。意外断电可从有效 `.pending`／正式档／备份依次恢复。
- 主菜单可以识别待恢复存档，手动保存失败会明确通知玩家；玩家主动删除游戏进度时同步删除临时文件，防止误恢复。
- 新增隔离的 Godot QA，使用与真实存档不同的测试文件名。当前环境仍没有 Godot 引擎，**这些原生测试尚未执行**。

## v0.16.2 本轮已写入的实际修改（2026-11-22）

- **图像化商品目录**：从工程内已授权的 GLB 模型离线绘制 **27 张产品缩略图**，并在三页采购目录每行显示商品实物轮廓；保留小型类别图标、商品名称、价格与库存。对低龄／阅读困难玩家更友善，但**还不能声称完全不识字也能独立游玩**。
- **操作符号**：新增自制的购物车、货架、三盒批发按钮标记；图标配有文字，避免信息只靠颜色。
- **防误触结束营业**：手动点击「CLOSE DAY」或按 N 时打开不闪烁的双按钮确认页。取消恢复原位置的经营桌／场景；只有明确确认才进行营业日结算。原有自动计时闭店机制不变。
- **视角速度**：在 Audio & Accessibility 加入鼠标视角速度慢／标准／快三档，独立保存在现有本机设置中。旧设置默认标准，原有柔和视角、柔和光照、减弱动态、高对比度和字体放大均保留。
- **隐私**：不新增联网 SDK、登录、广告、聊天或收集身份资料。儿童安全说明、家庭时间提醒、两步确认删除本机存档仍保留。
- **来源追溯**：原有 85 个媒体文件保持一致，本轮另加 27 张源模型衍生缩略图和 3 枚项目自制图标，**共 115 份媒体／115 条来源及 SHA-256 记录**。逐件说明见 `licenses/USED_ASSET_PROVENANCE.csv`。

## v0.16.5 既有：版权同步与单文件导出前置条件（2026-11-22）

- 检查 **115 个媒体文件**与 `licenses/USED_ASSET_PROVENANCE.csv` 每一行一一对应；SHA-256、来源、授权缺失时严格失败。使用 `python tools/sync_release_notices.py --sync` 可从已核对的登记表**生成玩家可读的 Credits**；下一轮新增素材必须先更新原始来源登记再同步。
- 玩家自愿打开 Credits 时，直接读取 `licenses/PLAYER_THIRD_PARTY_NOTICES.txt` 与完整 `licenses/GODOT_ENGINE_MIT_LICENSE_NOTICE.txt`；不再维护重复的、可能过时的硬编码名单。
- Windows 开发者可以双击 `DEV_BUILD_WINDOWS_RELEASE.cmd` **尝试**原生检测及导出，它在缺少 Godot 4.4.1／Windows 导出模板、原生 QA 未通过或素材校验不合格时会中止，不会伪装成已经有 EXE。
- 已设置 `binary_format/embed_pck=true`，目标是成功导出时把资源嵌入 Windows EXE。**目前仍未生成 EXE，更没有验证干净 Windows 机器能否运行。**
- Godot 引擎内部第三方 `COPYRIGHT.txt`、品牌 LOGO／商标以及最终人工版权审查仍是开放的发行关口。打包资源权属登记不等于市场发行已获法律认可。

## 打开工程与验收

1. 开发者应在 Windows 安装 **Godot 4.4.1 标准版**（或核实兼容的后续 4.x），打开 `project.godot`，等待模型／PNG 导入，运行 `main.tscn`。
2. Windows：运行 `run_check_windows.cmd`，查看 `documentation/native_run_logs/RESULT_windows.txt`；Linux：运行 `tools/run_native_acceptance.sh`。它们是**测试脚本，不是直接游玩的 EXE**。
3. 现有 **23 组 Godot 引擎 QA 脚本**，尚未在本环境真正执行。Python/静态检查只能确认结构、资源引用、哈希及测试程序判定逻辑。
4. 真实发行前必须进行 Godot 启动／渲染、商品交易与读档、角色动画／穿模、键盘与鼠标导航、色觉及低龄理解测试、光敏性风险评估，最终导出自包含 Windows EXE。清单见 `documentation/RELEASE_GATES_v0162.md`。

## 路径与版权

- 游戏运行时直接读取工程内 `assets/`；不依赖当初上传的原始素材 ZIP。
- 游戏当前保留原存档路径 `user://lcg_p05_shop_v09.json` 兼容旧存档，不上传个人信息。
- 制作名单／许可可在游戏主菜单自愿打开；不强制观看。正式发布时仍需核对第三方版权与游戏商业名称。Kenney 等 CC0 资产来源请参考 `licenses/`。
- 此工程包含项目内资源，但**Godot 导出 EXE 尚未制作，也未通过商业发布验收**。

旧开发记录归档在 `documentation/DEVELOPMENT_HISTORY_UP_TO_v0161.md`；不要把那些历史版本号误认为另一个可用最新工程。

## v0.16.5 历史：商业权利暂缓与溯源修复
- 根据 2026-11-16 历史审查记录：`Second Chance Shop` 已退役，`LCG-P05 Shop Lab` 为内部项目代号，非正式注册名称。
- 原始 ZIP 精确哈希匹配：原本缺少路径的 4 个 Kenney UI 音效已找到原件。26 张预览图改为区分直接 ZIP 原件与工程内模型衍生图。
- 【历史状态，已被 v0.16.7 更新】当时 Logo 被暂时隐藏并排除；现已依据项目主确认的 AI 生成来源恢复为内部测试使用。
- 官方 Godot 4.4 API 可从运行中的二进制直接读取各组件的版权人及许可证全文：Credits 中新增 ENGINE COMPONENTS，Windows 开发者导出脚本须生成版本匹配的许可证快照。
- **4 首 hernandack 音乐暂无可供 SHA 对照的原始音频 ZIP**（公开 CC0 来源已查明，但原始字节链仍待最终核对）。
- **工作室名称与游戏正式名称未做完整官方商标检索，不能公开发行。** 当前确认 itch.io 同名账号属于项目主，见 v0.16.7 说明。历史详情 `documentation/IP_CLEARANCE_HOLD_v0165.md`。
- 原生 Godot 测试仍不可执行时，不得宣称运行或 Windows 导出已成功。

## v0.16.7 修复：初始聊天与真实作者来源再确认

- 确认 itch.io 的 Little Cozy Games 是项目主本人经营的账号；公开作品包括 Tidy Little Home、Little Repair Workshop、PAPER WORKS、RingBop。**不要再把这个账号误当陌生第三方**。
- 工作室现有 Logo 为项目主指示 ChatGPT 生成的旧作品，内部测试版恢复展示，保留原件及哈希；未宣称商标已注册。
- 新游戏工作名称：**Old Things, New Days**（旧物，新日子），替换之前仅供内部识别的游戏屏幕标题；商标官方检索仍需完成。
- 找回音乐创作者 **hernandack** 官方 itch.io 下载页和 OpenGameArt 的 **CC0** 发布页；四首原始曲名以及直接音频 URL 已记录于 `documentation/MUSIC_SOURCE_EVIDENCE_v0166.json`；**当前环境未能抓取原站原始字节进行哈希对比**。
- 将“不知道素材来源”与“没有取得商标注册”分开标记。商用发布仍须经过发行前 Gate、原生 QA 与商标相似性检查，不能混同为已确立侵权。
- 相关证据请见 `documentation/CREATOR_PROVENANCE_AND_NAME_v0166.md` 与更新后的版权索引。


## v0.16.7 工作室开场与版权规范
已固定 1.8 秒安静 Logo 淡入/淡出、可键鼠触屏跳过、减少动态效果直达菜单；保存失败不能离开营业场景。品牌历史、版权和四首音乐的重新上传哈希请看 `documentation/LITTLE_COZY_GAMES_STUDIO_IDENT_STANDARD_v0167.md`。此版本仍为 Godot 源码工程，未完成引擎及 Windows 原生验收。

## v0.16.8 修复：系统窗口关闭／存档失败防护
- 新增窗口 X / Alt+F4 的统一退出拦截：只有当前经营进度成功保存才调用程序退出。原来的退出到桌面按钮也使用相同的保存检测，不再忽略失败结果。
- 新游戏首次写入失败时显示明确提示，不错误报告已经保存。
- Logo 的 1.8 秒淡入淡出拆成确定性的动画更新函数，并增加原生 QA 检查透明度、减弱动态选项、菜单返回以及保存失败时不退出等场景。
- 23 组 Godot 原生测试脚本仍**未执行**；当前容器没有 Godot 4.4.1 可执行程序，官方引擎下载不可用。本轮静态/模拟 QA 不等于运行成功或光敏性测试。
- Windows EXE **仍未生成**。ZIP 是开发工程，不是可游玩发行包；原 115 份媒体及许可链继续保留。

## v0.16.9 · 原生运行验收的云端 CI 路径（未在本环境实际执行）

- 加入 `.github/workflows/godot_native_qa.yml`，参考 Godot 官方 headless 命令和 Chickensoft setup-godot v2。默认只能从私人 GitHub 仓库手动运行；不会上传 itch.io、创建发行版本或公开商店条目。
- CI 检查 Python 静态与版权来源、使用官方 Godot 4.4.1 导入工程、启动主场景，然后运行项目现有 23 组 Godot 原生 QA 脚本。保留失败日志以便后续逐项修复。
- Windows EXE 内部测试版必须由开发者在手动工作流中明确启用，且只能在原生 QA 通过后尝试打包，使用项目原有版权与导出检查；输出名称仍为 `LCG-P05_INTERNAL_TEST_ONLY.exe`。
- 修复 20 份 QA 脚本的初始化顺序：在 `add_child()` 之前设置 `qa_mode=true`，避免进入 `_ready()` 时有未保护的本地存档或偏好读取/写入。
- 新增 `tools/check_ci_pipeline.py`：审核 23 个 QA 入口 Windows/Linux 对齐、测试模式初始化顺序、CI 没有公开发布步骤。
- 原有 v0.16.1、v0.16.2 和 v0.16.8 离线审核中与版本号有关的规则调整为审查实际工程与源码是否一致，不再假定所有后续版本永远等于某一固定版本。
- **当前环境不具备 Godot 4.4.1 引擎，CI 也尚未实际在 GitHub 运行。上述属于已编写的自动验收配置，不是游戏已通过原生测试、Windows EXE 已打包的证据。**

详细使用说明：`documentation/NATIVE_CI_HANDOFF_v0169.md`。
