# PDF 测试夹具说明 (PDF Fixtures)

本目录的 PDF 夹具均为本仓库自制的无版权测试文件，不含任何个人或受版权
保护的内容。

| 文件 | 页数 | 生成方式 | SHA-256 |
|---|---|---|---|
| `thousand-pages.pdf` | 1000 | `dart run tool/generate_thousand_page_pdf.dart`（手写 PDF 1.4 结构，每页一行 "Page N of 1000" 文本，Helvetica 字体） | `C9401BD82469BCCD55F9F0D4C6FD6EBF7649CA1B708DC7E1C8F1D066131212E7` |

用途：

- `thousand-pages.pdf` 用于性能门禁：固定 1,000 页文本 PDF 的导入时长与
  峰值内存报告（`integration_test/performance_gate_test.dart`）。
  目标：导入时长 ≤30 秒（仅在实测达标时宣称达标）。
- 生成脚本是确定性的（固定页面文本），重新生成后 SHA-256 不变；
  如升级生成脚本，请同步更新本表哈希。

加密/损坏/扫描件 PDF 的失败路径由单元测试与
`pdf_document_parser` 的错误映射覆盖，无需大体积夹具。
