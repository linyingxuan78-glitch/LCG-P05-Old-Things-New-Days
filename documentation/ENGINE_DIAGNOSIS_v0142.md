# LCG-P05 Godot Native Acceptance — v0.14.2

## 实际执行结果（本次容器，2026-11-16）

**BLOCKED_ENGINE_NOT_INSTALLED** (exit 2). 没有 Godot editor 可执行文件。

已检查 `godot`, `godot4`、常用安装路径。DNS 解析失败：`getent hosts deb.debian.org` / `getent hosts downloads.godotengine.org` 无结果。`apt-get update` 提示 `Temporary failure resolving ...`，`curl` 提示 `Could not resolve host`。这是容器的联网与引擎取得限制，不能推断项目本身成功或失败。

## v0.14.2 实际更新

- 修复进入游戏时重复刷新教程界面的轻微问题。
- Linux 验收脚本增加项目主场景启动检查、引擎版本记录、导入日志解析错误扫描、7 组 Godot 回归测试，并正确区分退出码 0/1/2。
- 新增 `run_check_windows.cmd` 一键入口：优先查找已有 Godot，找不到才尝试从 Godot 官方下载标准 Windows 引擎并在本机运行同一套检查。
- 不分发未知来源或未经核实的引擎 EXE。Godot 4.7.1 官方归档参考：https://godotengine.org/download/archive/4.7.1-stable/
- Windows 脚本需要联网或已安装 Godot；不会自动把项目发布到 Steam。

## 验收分层

1. Python 静态检查：可以在当前容器完成（不等于引擎运行）。
2. 官方 Godot `--headless --editor --import`：当前容器**未完成**。
3. Godot `--headless --quit-after 15` 场景启动：当前容器**未完成**。
4. 七组原生测试：当前容器**未完成**。
5. 带屏幕的 Windows 鼠标、图形、音频、存档交互：**未完成**。
6. Windows EXE 导出与商用发行：**未完成**。

## 使用说明

Windows：解压工程 ZIP，将整个文件夹保留，双击 `run_check_windows.cmd`。检测器会搜索 Godot 编辑器；找不到时尝试从官方网站下载。运行结果在 `documentation/native_run_logs/RESULT_windows.txt` 及各 `.log`。

Linux（已有 Godot）：`bash tools/run_native_acceptance.sh`；若二进制名称非 `godot`，可指定 `GODOT_BIN=/absolute/path/to/Godot ...`。

脚本无法取代游戏中真正的视觉与交互测试，也不保证审核结果永久通过。此版本未附带 Windows 可执行游戏。
