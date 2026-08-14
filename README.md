# 典读鸡 (Dianduji)

面向科研与英语阅读的点读翻译应用：离线导入 TXT / 文本 PDF / DOCX，点按单词
即查本地词典（ECDICT），自动收录生词与短语，支持手机、平板、桌面与 Web。

- **离线优先**：全部解析、查询、学习数据在本机完成。
- **科研翻译**：五领域专业词典（计算机/医学/生物/化学/地理信息 1065+ 条）、
  多词术语识别、分层查询链（用户词典 → 通用词典 → 专业词典 → 在线翻译）。
- **词典自进化**：在线翻译的新词自动收集，经 LLM（DeepSeek）整理入库，
  或由用户手动编写语境化释义。
- **PDF 阅读器**：原版式渲染、点读命中（断词合并）、目录导航、页码跳转、
  缩放记忆。

## 平台

- Android（参考真机：Huawei BTK-W00）
- Web（构建部署见下方；核心离线功能）
- Windows / macOS / Linux（桌面构建可用，未全量验证）

## 快速开始

```powershell
subst T: "你的工作树路径"   # 中文路径需要 ASCII 盘符（Flutter LSP 限制）
Set-Location T:\mobile
$flutter = 'D:\local_environment\Flutter\flutter\bin\flutter.bat'

& $flutter pub get
& $flutter analyze
& $flutter test
& $flutter build web            # Web 产物: build\web
```

### 在线翻译（可选）

在线翻译与 LLM 词典整理通过自控网关接入（密钥在服务端，客户端零密钥）：
- 网关参考实现与部署：`mobile/docs/gateway-reference/`（腾讯云 TMT + DeepSeek）
- 网关契约：`mobile/docs/online-translation-gateway.md`
- 客户端构建时注入网关地址：
  ```powershell
  & $flutter build apk --debug --dart-define=DIANDUJI_TRANSLATE_BASE_URL=https://你的网关/translate
  ```

## 测试与质量

- 326+ 单元/组件测试；覆盖率约 94%
- 性能：词典查询 ~196µs/次；千页 PDF 导入 ~1.9s；真机滚动 86-118 FPS
- 隐私：离线优先；在线请求仅含所点词与所在单句（≤1000 字符）

## 开源

- 许可证：MIT（`LICENSE`）
- 数据许可：ECDICT（MIT）、专业词典（MIT 自建汇编）——见 `mobile/docs/third-party-notices.md`
- 贡献指南：`CONTRIBUTING.md`
- 在线体验：<https://dianduji.github.io/dianduji>（构建部署后可用）

## 目录

- `mobile/`：Flutter 应用（Android / Web / 桌面）
- `mobile/docs/`：设计、契约、部署文档
- `docs/superpowers/`：开发计划与规格

© 2026 典读鸡 contributors
