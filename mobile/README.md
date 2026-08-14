# 点读机 (dian_du_ji)

面向手机、平板与桌面的英文文档点读翻译应用：离线导入 TXT / 文本 PDF / DOCX，
点按单词即查本地词典（ECDICT），自动收录生词与短语，支持手机底部词卡、
平板右侧栏/悬浮词卡，以及 Android 系统分享/打开文件导入。所有解析、查询与
学习数据均在本机完成，不上传任何内容。

## 科研翻译增强（2026-08 交付）

- **离线专业词典**：内置计算机、医学、生物、化学、地理信息（GIS）五领域
  术语表（`assets/specialized/terms.json`，MIT 自建汇编，记录来源/版本/许可）。
- **多词术语识别**：点击句中单词时识别包含该词的 2–5 词专业术语
  （如 random → random forest），最长命中优先。
- **分层查询链**：通用词典与专业词典并行查询、合并展示，通用释义不会遮蔽
  专业术语释义；词卡显示术语、领域标签、当前原句、例句与来源标识。
- **在线翻译兜底（可选）**：本地未收录时可将所点词与所在单个句子
  （≤1000 字符，以术语为中心截取）发送至自控翻译网关。默认关闭，首次开启需
  同意隐私告知，设置页提供总开关与"清除在线翻译缓存"。请求不含文档全文、
  页图、标题、作者、路径或设备标识；结果本地缓存（键含句子摘要，不存原句）。
- 网关契约见 `docs/online-translation-gateway.md`；构建期通过
  `--dart-define=DIANDUJI_TRANSLATE_BASE_URL=...` 与
  `--dart-define=DIANDUJI_TRANSLATE_API_KEY=...` 注入网关地址与密钥，
  安装包内不硬编码任何第三方密钥。

## 阅读器体验增强（2026-08-15 交付）

- **PDF 目录导航**：读取 PDF 书签大纲，顶部"目录"按钮弹出章节列表
  （支持多级缩进），点击跳转对应页码。
- **页码指示与跳页**：PDF 阅读底部显示"当前页 / 总页数"，点击可输入页码跳转。
- **缩放记忆**：按文档记住缩放级别（设置键值表 `pdf-zoom-<文档ID>`），
  再次打开自动恢复。

## 目标平台

- Android 8.0 (API 26) 起；参考真机：Huawei BTK-W00（Android 12 / API 31 / arm64）。
- iOS 14+：保持源码兼容；签名与真机验收留待 macOS 环境执行（本仓库在 Windows 开发）。
- 桌面：Windows（本仓库可构建验证）；macOS / Linux 目录已生成，待对应平台验证。
- Web 原型保留在仓库根目录 `src/`（React + Vite），与 Flutter 应用相互独立，
  不参与 Flutter 构建。

## 环境要求

| 组件 | 版本 | 位置 |
|---|---|---|
| Flutter | 3.44.8 | `D:\local_environment\Flutter\flutter` |
| Dart | 3.12.2（随 Flutter） | 同上 `bin\cache\dart-sdk` |
| JDK | 17（构建用；机器上另有 8/11/25 不影响） | `D:\local_environment\Java\JDK17` |
| Android SDK | 见 `mobile\android\local.properties` (`sdk.dir`) | `D:\Android\sdk` |
| Gradle | 9.1.0（wrapper） | 由 wrapper 自动下载 |

## 路径映射（重要）

仓库工作区位于中文路径 `D:\Vibe Coding\点读机` 下。Flutter 工具的分析服务器
在 Windows 上通过标准输入/输出传递 LSP 消息，中文路径会导致 JSON 消息被截断
（`FormatException: Unexpected end of input`）。因此**所有 Flutter 命令必须
从 ASCII 盘符运行**：

```powershell
subst T: "D:\Vibe Coding\点读机\.worktrees\flutter-mvp-remaining"
Set-Location T:\mobile
$flutter = 'D:\local_environment\Flutter\flutter\bin\flutter.bat'
```

> 计划文档中的 `T:\mobile` 即本工作树。`kotlin.incremental=false` 保持启用，
> 因为 Kotlin 增量缓存无法把 C: 盘 Pub 缓存中的插件源码相对化到 T: 盘工程。

## 常用命令

```powershell
Set-Location T:\mobile
$flutter = 'D:\local_environment\Flutter\flutter\bin\flutter.bat'

& $flutter pub get
& $flutter pub run build_runner build --delete-conflicting-outputs  # Drift 代码生成
& $flutter analyze
& $flutter test                          # 全部单元/组件测试（含无障碍与黄金图）
& $flutter test test/goldens --update-goldens   # 重新生成黄金图并目检 PNG
& $flutter build apk --debug             # 产物: build\app\outputs\flutter-apk\app-debug.apk
```

### 覆盖率与性能门禁

```powershell
& $flutter test --coverage
& 'D:\local_environment\Flutter\flutter\bin\cache\dart-sdk\bin\dart.exe' `
  tool/check_coverage.dart coverage/lcov.info --minimum 90
& $flutter test test/benchmarks/dictionary_benchmark_test.dart
```

- 覆盖率门禁只统计离线核心路径（文档解析/结构、导入状态机、词典、短语、
  学习仓库、阅读控制器），总体不低于 90%（当前约 94%）。`dart run` 会触发
  sqlite3 的原生构建钩子，宿主无 C 工具链时请用上述 `dart <file>` 直接执行。
- 词典基准在 `flutter test` 环境中运行（sqlite3 3.5+ 通过 Dart native assets
  加载，纯 `dart run` 不可用），预算为每次查询 <10ms。

### 真机性能门禁（BTK-W00，2026-08-14 实测）

```powershell
& $flutter test integration_test/performance_gate_test.dart -d 26DYD24119408737
```

| 指标 | 目标 | 实测（debug） | 状态 |
|---|---|---|---|
| 点击到词卡可见延迟 | <100ms（profile 门禁） | 396ms（debug JIT） | 记录；profile 门禁命令见下 |
| 长文档滚动帧率 | ≥55 FPS（profile） | 86–118 FPS | 通过 |
| 1,000 页文本 PDF 导入 | ≤30s | **1.9s** | 通过 |

profile 模式正式门禁（100ms 延迟 / 55 FPS）：

```powershell
& $flutter drive --driver=test_driver/integration_test.dart `
  --target=integration_test/performance_gate_test.dart `
  --profile -d 26DYD24119408737
```

千页 PDF 夹具由 `dart run tool/generate_thousand_page_pdf.dart` 确定性生成，
哈希见 `integration_test/fixtures/PDF_FIXTURES.md`。

### 真机集成测试（需连接 BTK-W00）

```powershell
$adb = 'C:\Users\24439\AppData\Local\Android\sdk\platform-tools\adb.exe'
& $adb -s 26DYD24119408737 wait-for-device
& $flutter test integration_test/txt_docx_import_test.dart -d 26DYD24119408737
& $flutter test integration_test/core_learning_flow_test.dart -d 26DYD24119408737
& $flutter test integration_test/shared_file_import_test.dart -d 26DYD24119408737
```

`shared_file_import_test.dart` 还要求手动验证分享导入：在文件管理器中分别
分享 TXT/PDF/DOCX 到点读机（冷启动与运行中各一次）。adb 等价命令见该测试
文件头部注释。

## 离线词典与短语资产

| 资产 | 说明 | SHA-256 |
|---|---|---|
| `assets/dictionary/ecdict.sqlite` | ECDICT 英汉词典（MIT，见 `assets/dictionary/LICENSE-ECDICT`），约 9.0 MB | `CFEB703A4184CF2959C36BC9E51C70A233299FE9CA8F1C7C100D5AD37A038E92` |
| `assets/phrases/phrases.json` | 内置短语表（短语动词/介词短语/搭配/习语） | `856A9C763F9D22EB81827CADD0F7F9FFD29D07ABA57A464255D999748E899F58` |

应用首次启动把词典复制到应用支持目录并以只读方式打开；词典只增不减，
升级词典需更新本表哈希。

重建词典（仅当更换 ECDICT 数据源时）：

```powershell
Set-Location T:\mobile
& $flutter pub get
& 'D:\local_environment\Flutter\flutter\bin\cache\dart-sdk\bin\dart.exe' `
  tool/dictionary_builder/build_dictionary.dart  # 生成 assets/dictionary/ecdict.sqlite
Get-FileHash assets\dictionary\ecdict.sqlite -Algorithm SHA256
```

## 测试夹具来源

`integration_test/fixtures/` 均为本仓库自制的无版权样本：

| 夹具 | 内容 | SHA-256 |
|---|---|---|
| `sample_utf8.txt` | UTF-8 英文与中文样本（63 B） | `0E693AF252941CC8878EF182E5F8980BBB656493C6C1F62EFB94BEF083307BC6` |
| `sample_gb18030.txt` | GB18030 编码中文样本（15 B） | `92EAE98810B2BE9D7E20D4C91B5602789BE0757C7AE9B6017C00342CDA847C7C` |
| `sample.docx` | 最小 DOCX 样本（492 B） | `C14F996CFD8B1F44209FFEE3B34EC4FDEAC75237E330F977B78C3F414857CE5A` |

## 数据库与迁移

- 用户数据库由 Drift 管理，模式定义在 `lib/core/database/app_database.dart`，
  生成代码为 `app_database.g.dart`（勿手改，用 build_runner 重新生成）。
- 迁移规则：只在 `MigrationStrategy` 中追加向后兼容的迁移；任何破坏性变更
  必须 bump schema 版本并保留旧版本升级路径。
- 文档正文以句子/词元结构存储（稳定句子 ID + 本地偏移），不保存像素滚动位置。
- 删除源文档只删除文档行；生词与短语保留并标记“原文档已删除”。

## 隐私行为

- 文档解析、词典查询、短语识别、学习记录全部在设备本地完成；应用不声明
  网络权限，不发送文档内容、查询记录或阅读历史。
- 分享导入仅接受系统授予读取权限的内容 URI，复制到应用私有缓存后解析；
  不申请宽泛存储权限。权限失效时提示重新分享。
- 发音使用系统 TTS 本地英文语音；未安装语音时提示“本机未安装英文语音”，
  不回退到网络。设置页提供隐私说明与第三方许可证对话框。

## 第三方依赖锁版说明

- `file_picker` 锁定 `10.3.10`：更高版本与 AGP 9 内置 Kotlin 存在回归，
  升级前必须验证 AGP 9 兼容性。
- `pdfrx 2.4.7` 是唯一 PDF 页面引擎；PDF 解析导入仍负责格式校验与
  加密/损坏/扫描件错误分类（`AppFailureCode`）。
- 完整第三方清单见 `docs/third-party-notices.md`。

## 发布签名

Release 构建从 Gradle 属性（`android/key.properties`）或环境变量读取
`DIANDUJI_STORE_FILE`、`DIANDUJI_STORE_PASSWORD`、`DIANDUJI_KEY_ALIAS`、
`DIANDUJI_KEY_PASSWORD`；缺失时 release 任务直接失败并给出可操作提示，
绝不回退到 debug 签名。真实 keystore 与 `key.properties` 已被 `.gitignore`
排除，仅提交 `android/key.properties.example`。

```powershell
$env:DIANDUJI_STORE_FILE = 'D:\secrets\dianduji-release.jks'
$env:DIANDUJI_STORE_PASSWORD = '...'
$env:DIANDUJI_KEY_ALIAS = 'dianduji'
$env:DIANDUJI_KEY_PASSWORD = '...'
& $flutter build appbundle --release
# 产物: build\app\outputs\bundle\release\app-release.aab
```

## 产物位置

- Debug APK：`build\app\outputs\flutter-apk\app-debug.apk`
- Release AAB：`build\app\outputs\bundle\release\app-release.aab`（需签名变量）
- 最终验收 APK（2026-08-14）SHA-256：
  `334BABDF6754FAD04D29590575763B4D34DCB77FF4A38AD5DDB71DBFE1FDDB94`
- 安装验证：

```powershell
$adb = 'C:\Users\24439\AppData\Local\Android\sdk\platform-tools\adb.exe'
& $adb -s 26DYD24119408737 install -r build\app\outputs\flutter-apk\app-debug.apk
& $adb -s 26DYD24119408737 shell monkey -p com.dianduji.dian_du_ji -c android.intent.category.LAUNCHER 1
```

## iOS 验证限制

Windows 开发环境无法完成 iOS 签名与真机验收；iOS 构建配置（`ios/`）保持
源码兼容，须在 macOS 上执行 `flutter build ios` 并接入签名后验收。

## 文档索引

- 需求与设计：仓库根目录《英文文档点读翻译 App 需求文档.md》《英文文档点读翻译 App 设计方案.md》
- 实施计划：`docs/superpowers/plans/2026-07-29-flutter-mvp-remaining-implementation.md`
- 第三方许可：`docs/third-party-notices.md`
