# LCG-P05 · v0.16.9 Godot CI 交接与真实验收方案

**状态：工作流与本地脚本已编写并进行离线检查；GitHub Actions 尚未执行；Godot 4.4.1 原生测试尚未执行；没有生成 EXE。**

## 为什么改用远端 CI

本地执行环境没有 Godot 编辑器，也无法解析官方/ GitHub 下载服务器的 DNS，继续重试同一 URL 并不能证明游戏可运行。Godot 官方支持 `--headless --import`、启动主场景、`--script` 和 `--export-release`；`chickensoft-games/setup-godot@v2` 可以在 GitHub Actions runner 上安装指定引擎与模板。这是**待执行的替代通道**，不是已经完成的测试。

官方依据：
- https://docs.godotengine.org/en/4.4/tutorials/editor/command_line_tutorial.html
- https://github.com/chickensoft-games/setup-godot
- https://github.com/godot-gdunit-labs/gdUnit4-action （参考：第三方测试框架；当前工程未接入该插件）
- https://github.com/youichi-uda/godot-qa （参考：画面与输入回归；当前工程未接入该插件）

## 如何实际启动

1. 如果准备将源码移交 GitHub，请使用**私有仓库（Private repository）**。未取得公开发行批准前，不要把项目仓库设为公开，不要开启 GitHub Pages，不要推送到 itch.io。仓库里可以放整个解压后的 Godot 工程，`project.godot` 应在根目录，并且必须保留 `.github/workflows/godot_native_qa.yml`。
2. 打开仓库的 **Actions** 页面，选择 **LCG P05 native Godot QA (internal only)**，点击 **Run workflow**。
3. 默认 `attempt_windows_exe=false`：只执行版权/静态检查、官方 Godot 4.4.1 的资源导入、场景启动，以及已有 **23** 组原生 GDScript 测试。失败后从 Artifact 下载 `lcg-p05-native-qa-logs`；不要把 FAIL 或未运行的日志描述为通过。
4. 所有测试真正通过后，开发者才可以选择 `attempt_windows_exe=true` 再运行。Windows runner 会重跑相应验证，生成与当前引擎匹配的第三方许可证说明，并尝试导出 **`LCG-P05_INTERNAL_TEST_ONLY.exe`**。这个文件仅供私人测试，默认不对公众发布。
5. 需要检查完整日志：`documentation/native_run_logs/RESULT.txt`、`RESULT_windows.txt`、各 `qa_*.log`、`documentation/WINDOWS_EXPORT_RESULT.txt`。出现 `SCRIPT ERROR`、导入异常或缺少预期 PASS 标记时按失败处理。

### 不要混淆三类验收

- **离线审计：** 文件、来源、版本号和自动化配置的静态一致性。这里已经执行。
- **Godot headless：** 真正通过引擎导入、解析和 GDScript 测试；流程已准备，尚未实际执行。
- **Windows 玩家体验：** 真正的 EXE 在非开发机上双击启动、3D 视觉/穿模、声音、输入、儿童与无障碍试玩、光敏性风险测试。即使远端 headless QA 通过，仍需单独进行。

## 隐私和版权边界

- 云端 CI 不会自动登录开发者 itch.io 或发布游戏。GitHub Actions 产生的内部测试 EXE 仍不是正式发行许可。
- 仓库仅包含这个项目的源代码和随工程使用的资产，不应上传用户个人存档、账号密码、隐私数据或不属于项目的文件。
- `tools/sync_release_notices.py` 与 `tools/check_creator_provenance_v0166.py` 会先于引擎运行。官方 Godot 第三方依赖版权快照在 Windows 内部导出时生成。
- 这个流程不提供商标注册或合法性的自动保证。正式商业上架继续受 `documentation/IP_PUBLIC_RELEASE_GATE_v0165.json` 控制。
- 请勿直接把 GitHub workflow 报告当作游戏的光敏性合格证书或儿童安全认证。

## 引擎缺失时的开发原则

AI agent 写新代码后应立即审计可执行的内容；如果本机没有 Godot，则记录 BLOCKED 并交给 CI，不能把“测试控制器模拟通过”报告成“游戏运行通过”。CI 报错后应根据**具体 Godot 运行日志**修复并重跑，而不是增加更多无关功能。

## 本轮 QA 修复

原有 20 个测试场景，在 `root.add_child(shop)` 之前设置 `shop.qa_mode=true`，避免 `_ready()` 前仍处于非 QA 模式。已有另两个 QA 场景保持正确的初始化顺序；许可 API 测试不创建玩家场景。

## 仍未解决

- GitHub 工作流尚未实际触发，也没有来自 GitHub 的运行日志或 Artifact。
- 当前本地环境无法运行 Godot 4.4.1；即使仓库可访问，也不能推断其结果。
- Windows 单文件 EXE、视觉、音频、动画、无障碍和全部真实设备测试都尚未验收。
