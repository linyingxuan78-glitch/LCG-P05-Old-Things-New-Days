# 四首背景音乐：原站文件逐字节核实（2026-11-23）
**结果：4/4 SHA-256 exact match · 此项音乐来源验证通过，不等于所有素材或作品名称均获法律许可。**

原始发布页面：https://opengameart.org/content/short-loops-background-music-pack
作者：hernandack；页面显示 CC0 1.0、2018-12-11 发布，列出四个原始 OGG 下载链接。
实证：GitHub Actions Ubuntu 实际下载原站文件，并与当前游戏同名 OGG 计算 SHA-256，对照文件大小。
测试运行：https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45151817068
原始机器报告 Artifact：LCG-P05_UPSTREAM_CC0_MUSIC_HASH_AUDIT。

| 文件 | 游戏内 bytes | 游戏内 SHA-256 | 官方 OGG 原件 |
| --- | ---: | --- | --- |
| A Brand New Wisdom.ogg | 265389 | `99d0095c328d598f5fb1bca9fbb4a518112bbf676dc662f0c0c6edfee88d788c` | EXACT MATCH |
| Just Saying Tho.ogg | 397509 | `687aa35987b89797af14735348c5b2f1b766ac0ba528dc001746aaf4ca1cc82f` | EXACT MATCH |
| Swinging Sweet.ogg | 405170 | `5a22466a7ec28c324324217aff836809ccbc9e2489cc22ebf72725f4bfd320bb` | EXACT MATCH |
| Winter Dust.ogg | 468597 | `8c0da93d35ddfb3c8e4cc01ce4ba6611fb407eec4b6c23f17a691ad7dc0f1fe0` | EXACT MATCH |

**范围限制**：四首 BGM 属 hernandack 发布的 CC0 素材。其他 Kenney 音效、模型、徽标、作品名称、第三方商标及第三方内容分别依照原有资产来源表审查；上述四行通过不代表这些其余发行关口均完成。旧版 `MUSIC_SOURCE_EVIDENCE_v0166.json` 是当时**尚未完成**字节比对的历史记录，不能再把其中的旧判定当作当前状态。本报告是更新的核实结果。

公开发售之前仍需要：真人声音播放/音量体验；最终 License/Credits 文件与确实打包的资产相符；商标、产品名称和店铺账户合规。不要把 GitHub 内测工程直接宣称正式发行。
