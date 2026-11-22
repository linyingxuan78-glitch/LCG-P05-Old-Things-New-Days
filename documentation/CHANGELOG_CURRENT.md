# CURRENT — LCG-P05 v0.16.8 (2026-11-22)

See `CHANGELOG_v0168.md` for the latest fix: Windows X/Alt+F4 and Quit Desktop use the same save-success exit gate, plus a testable 1.8-second studio fade. 23 native QA suites included, not run due to missing engine.

## Earlier changes (historical; not current version)

## v0.15.6 — Low-frequency events, bargaining, accessible picture cues (2026-11-22)

### v0.15.6：低频营业事件、有限议价、顾客反馈与图像操作提示

- 已修改 `scripts/shop.gd`：前两天不开突发事件，之后每日约 30% 机会出现天气/邻里/送货/居民清货事件，**事件日至少相隔 3 天**，日内仅一次，事件与上一次触发日随存档保存。需要注意已有每日热门类别依然按顺序轮换。
- 新增一次/日上限的顾客还价：价格略高于顾客预算时可能触发自愿选择，接受后在收银台按真实议价金额付款，拒绝不罚款；顾客与时间暂停，防止菜单打开还继续成交。寄售商品不允许议价低于应付款。
- 记录顾客成交、缺货、嫌贵反馈与还价次数，写进营业日汇总；并避免相邻到访顾客连续使用同一 3D 造型。现有六套造型不会变成几十个人物立绘。
- 新增由项目自产生的四张静态图标，给予“买入→上架→顾客→下一天”的简单图片提示；增加 `PICTURE GUIDE` 和 `COMPACT HUD` 两项可选设置。**完全不识字就能游玩、多国语言、本机光敏性检测尚未实现**。
- 第 13 组 Godot QA 脚本加入 Linux/Windows 验收清单。已通过源码静态检查、逐文件 SHA 校验与测试控制器模拟；**未完成 Godot 实际执行/视觉运行/Windows EXE**。
- 详情及重要限制：`documentation/USABILITY_EVENTS_AUDIT_v0156.md`。


# 当前唯一开发版 — v0.15.3（2026-11-22）

**增加了 18 种真实可售商品，而不是只添加装饰模型。** 保留原九种 SKU，扩展到 27 种。9 个实体陈列区共享容量，每区最多六件；27 种 SKU 共用 3 页 Store Desk。商品包含新的 Kenney GLB 模型与自建折叠衣物几何素材。

新增六类循环需求、逐日轮换的第二批二手货源、SKU 固定品相标记及折算进价，保留客户挑选、结账、财务、社区旧物日、实际角色动画调用与本地保存。

关键兼容处理：保留旧九商品存档的原始 `stock/prices` 数组并扩展默认值；9 个货架的射线交互和顾客巡游使用 SKU 对应陈列区，不再把 27 种 SKU 当成 27 个实际货架；九行目录按钮由页码动态选择 SKU，不会越界出屏幕。

测试脚本增补至十组；源代码静态检查和文件级校验与实际 Godot 运行验收严格分开。项目仍未经过原生引擎运行及商业发行测试，尚未生成 Windows EXE。
