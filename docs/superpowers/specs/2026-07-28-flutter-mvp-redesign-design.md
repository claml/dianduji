# Flutter 移动端点读翻译 App 重做设计

**日期：** 2026-07-28  
**状态：** 已完成会话设计评审，待书面规格复核  
**目标平台：** Android 优先验收，保持 iOS 14+ 兼容  
**实现技术：** Flutter / Dart

## 1. 背景与目标

当前 React Web 原型可以编译，但真实 PDF/DOCX 导入、句子级点词、词形还原、生词收录、短语分类和测试门禁均存在阻断问题。新版本不迁移现有 IndexedDB 数据，也不继续把 Web 原型作为产品运行时。

本项目将在 `mobile/` 下新建 Flutter 应用。现有 Web 文件保留为只读参考，未经用户明确批准不删除。Flutter 应用是后续唯一的产品实现。

首阶段交付一个可安装、可离线使用、面向手机和平板的 MVP，完成以下闭环：

1. 从系统文件选择器或其他应用导入 TXT、文本型 PDF、DOCX。
2. 在本地后台解析文档并持久化段落、句子、单词和短语结构。
3. 在适配手机和平板的阅读器中阅读文档并保存进度。
4. 点击单个单词后立即显示选中状态，再从本地词典返回音标、词性和中文释义。
5. 展示当前句中包含所选单词的短语。
6. 对生词执行一次且仅一次的收录或查询次数更新。
7. 管理生词本、短语本与阅读设置。

## 2. 首阶段范围

### 2.1 包含

- Android 8.0（API 26）及以上。
- 保持 iOS 14.0 及以上的代码兼容性；iOS 编译、签名和真机验收在 macOS 环境补做。
- TXT、文本型 PDF、DOCX 本地导入。
- Android 文件选择与分享导入；iOS 分享扩展保留统一接口并在 iOS 验收阶段接入。
- 文档解析状态、失败原因、取消、重试和删除。
- 手机与平板自适应文档库和阅读器。
- 本地英汉词典、词形还原、短语识别。
- 生词本、短语本、CSV 导出。
- 日间、夜间、护眼主题，字号、行距和自动收录设置。
- 阅读位置和阅读进度恢复。
- 单元测试、数据库测试、Widget/Golden 测试和 Android 集成测试。

### 2.2 不包含

- 扫描 PDF OCR。
- 在线翻译增强、在线发音或云端词典。
- 艾宾浩斯复习系统。
- 账号、云同步、AI 讲解和社区。
- 旧 Web IndexedDB 数据迁移。

这些能力属于后续独立子项目，不得以空按钮或伪实现出现在 MVP 中。

## 3. 架构

采用功能模块化的 MVVM。Flutter Widget 只负责布局、动画和事件转发；ViewModel 管理页面状态；Repository 是业务数据的唯一写入口；Service 隔离数据库、文件系统和平台能力。跨多个 Repository 且足够复杂的业务才进入 Use Case，避免为简单转发制造额外层级。

### 3.1 目录结构

```text
mobile/
  lib/
    app/
      app.dart
      router.dart
      theme/
    core/
      database/
      errors/
      files/
      platform/
      ui/
    features/
      documents/
        data/
        domain/
        presentation/
      reader/
        data/
        domain/
        presentation/
      dictionary/
        data/
        domain/
      phrases/
        data/
        domain/
      learning/
        data/
        domain/
        presentation/
      settings/
        data/
        presentation/
  test/
  integration_test/
  assets/
    dictionary/
  tool/
    dictionary_builder/
```

### 3.2 技术选择

- Riverpod：依赖注入、异步状态和 ViewModel 生命周期。
- Drift / SQLite：关系型数据、事务、迁移、类型安全查询和响应式列表。
- `go_router`：声明式导航和手机/平板路由壳。
- 平台通道：Android PDFBox 文本提取；后续 iOS PDFKit 文本提取。
- Dart isolate：解析、分句、分词和短语预识别等 CPU 密集工作。
- `file_picker` 或能力等价的受维护插件：系统文件选择。
- Android Intent 适配器：从微信、QQ 和其他应用接收分享文件。
- Dart `archive` 与 XML 解析：DOCX OpenXML 提取。

第三方依赖必须在加入前检查平台支持、维护状态、许可证和最小系统版本。禁止为了宣称支持某格式而引入无法通过真实夹具测试的包。

## 4. 数据模型

### 4.1 Document

- `id`：UUID。
- `title`：用户可编辑标题。
- `format`：`txt | pdf | docx`。
- `sourceName`：导入时文件名。
- `localPath`：应用沙盒内文件路径。
- `contentHash`：用于识别重复导入。
- `fileSize`、`pageCount`、`wordCount`、`paragraphCount`。
- `parseStatus`：`queued | parsing | completed | failed | cancelled`。
- `parseProgress`：0 到 1。
- `failureCode`、`failureMessage`。
- `lastReadLocator`：稳定的句子或段落定位符及局部偏移。
- `readProgress`：0 到 1。
- `createdAt`、`updatedAt`、`lastOpenedAt`。

### 4.2 Paragraph

- `id`、`documentId`、`ordinal`。
- `text`。
- `style`：`body | heading1 | heading2 | quote | listItem`。

### 4.3 Sentence

- `id`、`documentId`、`paragraphId`、`ordinal`。
- `text`。
- `startOffset`、`endOffset`：相对于段落原文的准确偏移。

### 4.4 Token

- `id`、`documentId`、`sentenceId`、`ordinal`。
- `surface`：原文显示形式。
- `normalized`：大小写和标点规范化结果。
- `lemma`：词形还原结果。
- `partOfSpeech`。
- `startOffset`、`endOffset`：相对于句子原文的准确偏移。

### 4.5 PhraseOccurrence

- `id`、`documentId`、`sentenceId`。
- `phraseKey`、`surface`。
- `type`：`phrasalVerb | prepositionalPhrase | collocation | idiom`。
- `meaning`、`confidence`。
- `startTokenOrdinal`、`endTokenOrdinal`。

### 4.6 VocabularyEntry

- `id`。
- `lemma`：唯一索引。
- `displayWord`、`phonetic`、`partOfSpeech`、`definition`。
- `proficiency`：`known | vague | unknown`。
- `lookupCount`、`firstLookupAt`、`lastLookupAt`。
- `sourceDocumentId`、`sourceDocumentTitle`、`sourceSentenceId`。

首次查询在词典结果完成后执行一次事务性 upsert。再次查询只增加一次 `lookupCount` 并更新时间。不得由 Widget 生命周期或多个响应式 effect 隐式触发写入。

### 4.7 SavedPhrase

- `id`。
- `phraseKey`：唯一索引。
- `surface`、`type`、`meaning`、`contextSentence`。
- `sourceDocumentId`、`sourceDocumentTitle`。
- `createdAt`。

删除文档时级联删除 Paragraph、Sentence、Token 和 PhraseOccurrence。VocabularyEntry 与 SavedPhrase 作为用户学习资产保留；来源文档不存在时显示“原文档已删除”。

## 5. 文档导入与解析

### 5.1 通用流程

1. 从文件选择器或分享入口取得只读 URI/路径。
2. 读取扩展名、MIME 和文件头魔数，确认真实格式。
3. 计算文件哈希并检查重复导入。
4. 复制到应用私有沙盒，原文件后续移动或删除不影响应用。
5. 建立 `queued` 文档记录并启动后台解析。
6. 解析器按页或段落产生统一的 `ParsedBlock` 流。
7. 分句、分词、词形还原和短语预识别。
8. 分批事务写入结构化数据并更新进度。
9. 成功时标记 `completed`；失败或取消时删除结构化半成品并保留可重试的文档记录。

同一文件的重试必须幂等，不产生重复结构记录。

### 5.2 TXT

- 优先识别 BOM。
- 无 BOM 时验证 UTF-8；失败后尝试 GB18030/GBK。
- 多种编码均可能成立或替换字符比例过高时，显示编码选择并允许重试。
- 保留空行形成的段落边界。

### 5.3 DOCX

- 验证 ZIP 与 OpenXML 必需文件。
- 只读取正文、段落、标题样式、列表和必要的换行。
- 不把 XML 标签、页眉页脚关系数据或格式标记混入正文。
- 限制压缩包条目数、单条目大小和总展开大小，防止压缩炸弹。

### 5.4 PDF

- Android 使用受控的平台适配器包装 PDFBox Android；按页提取文本并报告页数与进度。
- iOS 实现同一 `PdfTextExtractor` 接口并使用 PDFKit。
- 加密 PDF 返回 `encryptedPdf`。
- 没有可提取文本但存在页面时返回 `scannedPdfNeedsOcr`。
- 页面文本为空、顺序异常或解析器错误不得伪装为成功。
- 解析器有文件大小、页数、处理时间和内存保护上限，并支持取消。

## 6. 词典与短语引擎

### 6.1 离线词典

- 使用 MIT 许可的 ECDICT 构建只读移动端 SQLite 资产。
- 构建工具按词频、考试标签和常用程度筛选首包，规范词条不少于 50,000。
- 应用内保留许可证、数据来源和构建版本。
- 词典资产与用户数据库分离，词典更新不会修改学习记录。
- 查询顺序：原词精确匹配、规范化匹配、词形表还原、未找到。
- 使用 ECDICT 的词形变化数据，不使用手写通用后缀裁剪作为主算法。
- 查询结果包含音标、词性和中文释义。

### 6.2 短语识别

- 短语库、数据库和 UI 共用一个 `PhraseType` 枚举。
- 输入是单个 Sentence 的 Token 序列，不扫描整个段落。
- 采用最长匹配优先，重叠结果去重。
- 结果包含 Token 范围和置信度；低于展示阈值的结果不显示。
- 点词时只展示当前句中覆盖所选 Token 的短语。
- 正例、反例、标点和大小写变体进入固定语料测试集。

## 7. 阅读器与交互

### 7.1 自适应布局

- 宽度小于 600dp：底部导航；文档库、阅读器、生词本和短语本使用单列。
- 宽度大于等于 600dp：NavigationRail；文档库使用列表与详情双栏，横屏阅读允许文档列表、正文和翻译详情多栏同屏。
- 平板不得简单放大手机界面。

视觉方向采用已确认的 Graphite 日间主题：白色和浅灰表面、深石墨文字、`#3D7AED` 单一强调色、克制边框、无渐变、低装饰。夜间与护眼主题沿用需求文档色板。

### 7.2 点词

- 阅读器按句子和 Token 渲染，每个 Token 使用唯一 ID。
- 点击后立即给该 Token 添加 2dp 强调色下划线和 12% 强调色背景。
- 当前 Sentence 使用更弱的背景提示，不高亮全文同拼写单词。
- 触摸移动超过手势阈值后判定为滚动，不触发点词。
- 词典查询完成后更新卡片内容并执行一次生词收录。

### 7.3 翻译详情

- 手机：从底部进入，紧凑高度目标 40%，允许在 35% 到 50% 自适应；上滑展开至约 65%，必要时内部滚动。
- 平板横屏：翻译详情优先显示在右侧面板，不遮挡正文。
- 必显：原词、音标、发音入口、词性、核心释义。
- 短语区仅列出覆盖所选 Token 的当前句短语，并提供明确的收录反馈。
- 手机卡片打开时底部阅读进度条隐藏并禁用；完全关闭后恢复。

### 7.4 阅读进度

- 使用稳定 Locator 保存位置，不只保存易受字号影响的像素 scroll offset。
- 滚动过程中节流保存。
- 返回文档库、应用进入后台和进程退出生命周期触发强制保存。
- 重新打开文档恢复到对应句子附近并校准可视位置。

## 8. 学习库与设置

### 8.1 生词本

- 按全部、认识、模糊、陌生筛选。
- 按时间、字母和查询频率排序。
- 支持中英文搜索、熟练度修改、详情、二次确认删除和手动添加。
- CSV 导出正确转义引号、逗号和换行。

### 8.2 短语本

- 使用统一短语类型筛选。
- 支持原文和中文释义搜索。
- 展示上下文、来源和二次确认删除。

### 8.3 设置

- 日间、夜间、护眼主题。
- 逻辑字号 12 到 24，默认 16。
- 行距 1.4 到 2.0，默认 1.6。
- 自动收录生词开关。
- 隐私说明、许可证、缓存与本地数据清理入口。

## 9. 错误、安全与隐私

- 统一错误类型覆盖：格式不支持、文件损坏、文件加密、编码未知、扫描 PDF、空间不足、解析超时、解析取消和数据库错误。
- 用户提示使用可行动的中文文案；诊断日志不记录文档正文、查询上下文或敏感路径。
- 文档默认完全本地处理，MVP 不发起翻译网络请求。
- 只读取用户明确选择或分享给应用的文件，并复制到应用沙盒。
- 所有数据库写入通过 Repository 和事务完成。
- 应用被系统终止后，启动时检查未完成任务并提供恢复或清理。
- 数据库升级使用版本化迁移；迁移前备份，迁移测试失败则不打开新版本写入。

## 10. 无障碍与动画

- 所有交互区域至少 48×48dp。
- 图标按钮提供语义标签；解析状态、保存结果和错误支持屏幕阅读器播报。
- 支持系统字体缩放，核心释义与操作标签不得截断。
- 日间模式普通文字对比度至少 4.5:1，关键控件状态至少 3:1。
- 遵循系统减少动态效果设置。
- 页面转场约 200ms；点词首帧反馈不等待动画或数据库。
- 触觉反馈始终配合可见状态，不作为唯一反馈。

## 11. 测试与质量门禁

### 11.1 TDD 规则

每项行为变更先写失败测试，确认失败原因正确，再实现最小代码并运行全套相关测试。解析器、Repository、ViewModel 和核心引擎均可脱离真实 UI 单独测试。

### 11.2 测试层级

- 单元测试：格式检测、TXT 编码、DOCX 解析、分段、分句、Token 偏移、词形表、词典查询、短语匹配和错误映射。
- 数据库测试：事务、唯一索引、生词单次 upsert、级联删除、学习数据保留、迁移和恢复。
- Repository/ViewModel 测试：导入状态机、取消重试、阅读位置、筛选排序和设置更新。
- Widget/Golden 测试：手机和平板、三种主题、大字体、空状态、加载状态、错误状态和翻译详情两档高度。
- Android 集成测试：导入、阅读、点词、收录、返回、重启和位置恢复完整闭环。

### 11.3 固定夹具

- UTF-8、带 BOM UTF-8、GBK/GB18030 和无法确定编码的 TXT。
- 正常文本型 PDF、1000 页性能 PDF、加密 PDF、损坏 PDF、扫描型 PDF。
- 正常 DOCX、含标题/列表 DOCX、损坏 DOCX、压缩炸弹模拟文件。
- 短语正例、反例、标点和大小写变化语料。
- 包含重复词、缩写、所有格、连字符和 Unicode 标点的英文段落。

### 11.4 合并门禁

- `flutter analyze` 零错误。
- 全部单元、数据库、Widget 和适用的集成测试通过。
- 核心解析、词典、短语和学习数据逻辑覆盖率不低于 90%。
- 本地词典查询小于 10ms。
- 点词首帧 UI 反馈小于 100ms。
- 目标 Android 参考设备上阅读滚动不低于 55 FPS。
- 使用固定 1000 页文本型 PDF 验证需求的 30 秒解析目标；如未达到，MVP 不宣称满足该指标，并在性能专项中继续优化。
- 不存在吞异常、空实现按钮、伪格式支持或无测试的核心路径。

## 12. 实施顺序

1. 安装并验证 Flutter/Android 工具链，创建 `mobile/` 工程和质量脚本。
2. 建立错误模型、数据库、Repository 边界和迁移测试。
3. 实现格式检测、沙盒复制、TXT/DOCX/PDF 解析适配器及夹具测试。
4. 实现分句、分词、Token 偏移、词形表和短语引擎。
5. 构建 ECDICT 移动资产和词典查询层。
6. 实现手机/平板文档库、导入任务和错误恢复。
7. 实现句子级阅读器、点词、翻译详情和阅读进度。
8. 实现生词本、短语本、设置和导出。
9. 完成无障碍、主题、Golden 测试、集成测试和性能验收。

每一步必须产生可独立测试的交付物；前一步质量门禁未通过时不开始下一步。

## 13. 已知约束

- 当前 Windows 环境未安装 Flutter、Dart 或 Android 调试工具，实施前必须先配置工具链。
- Windows 无法完成 iOS 编译和签名；iOS 真机验收需要 macOS 和 Apple 开发环境。
- 当前目录不是 Git 仓库，无法创建 worktree、提交设计或提供可靠回退点。正式实施前建议初始化 Git，并在首次代码改动前提交现有快照。
- 旧 Web 原型存在用户文件且没有版本控制，因此默认不删除、不覆盖，只在 `mobile/` 中新增 Flutter 实现。

