# 第三方许可声明 (Third-Party Notices)

点读机 (dian_du_ji) 使用以下第三方组件。全部组件均在本机离线处理，不向网络发送数据。

## ECDICT 英汉词典数据

- 来源: [skywind3000/ECDICT](https://github.com/skywind3000/ECDICT)
- 许可证: MIT
- 说明: 打包为 `assets/dictionary/ecdict.sqlite`，词典文件与 `LICENSE-ECDICT` 一并随应用分发。仅用于本机离线查询。

## 四领域专业术语表

- 来源: 项目自建汇编（计算机/医学/生物/化学高频科研术语，基于公开教材与术语资料整理，非第三方词库转载）
- 许可证: MIT（见 `assets/specialized/LICENSE.md`）
- 说明: 打包为 `assets/specialized/terms.json`，数据集级记录版本、来源与许可；仅用于本机离线查询。

## Flutter / Dart 生态

- [Flutter](https://flutter.dev) — BSD-3-Clause
- [Dart](https://dart.dev) — BSD-3-Clause
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) — MIT
- [drift / drift_flutter](https://pub.dev/packages/drift) — MIT
- [sqlite3](https://pub.dev/packages/sqlite3) — MIT（绑定 SQLite，SQLite 为公有领域）
- [pdfrx](https://pub.dev/packages/pdfrx) — BSD-3-Clause（PDF 页面渲染引擎）
- [file_picker](https://pub.dev/packages/file_picker) — MIT（版本锁定 10.3.10，见 README）
- [path_provider](https://pub.dev/packages/path_provider) — BSD-3-Clause
- [go_router](https://pub.dev/packages/go_router) — BSD-3-Clause
- [uuid](https://pub.dev/packages/uuid) — MIT
- [crypto](https://pub.dev/packages/crypto) — BSD-3-Clause（在线缓存键的句子摘要哈希）
- [crypto](https://pub.dev/packages/crypto) — BSD-3-Clause
- [mammoth](https://pub.dev/packages/mammoth) — BSD-2-Clause（DOCX 解析）
- 其余 Dart 依赖的完整许可证列表见各包内的 LICENSE 文件以及
  `flutter pub deps` / 发布包的 NOTICES。

## 字体与图标

- Material Icons — Apache-2.0（随 Flutter 分发）
- 应用未捆绑自定义字体；系统字体用于渲染。

## 隐私与合规说明

- 文档解析、词典查询、短语识别、学习记录全部在设备本地完成。
- 应用不请求网络权限之外的存储权限；共享文件通过内容 URI 授权读取，
  并复制到应用私有缓存后解析。
- 不收集、不上传文档内容、查询记录或阅读历史。
