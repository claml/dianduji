# 在线翻译网关契约 (Online Translation Gateway Contract)

点读机的在线翻译通过受控网关接入。正式发布前须确定网关地址、服务端密钥
管理、日志脱敏与保留期限。移动端不内置任何第三方服务密钥。

## 请求 (POST, application/json)

请求体只包含最小必要字段，**绝不**包含 PDF、页图、整页文本、文档标题、
作者、文件路径、设备标识或阅读历史。

```json
{
  "term": "random forest",
  "sentence": "A random forest classifies samples.",
  "targetLanguage": "zh",
  "domain": "computerScience"
}
```

- `sentence` 是所点术语所在的**单个句子**；超长句以术语为中心截取，
  最大 `1000` 个 Unicode 字符（见
  `OnlineTranslationRequest.maxSentenceLength`）。
- `domain` 为 `computerScience | medicine | biology | chemistry`，可省略。
- 密钥（若网关需要）通过请求头或查询参数传递，由构建期
  `--dart-define=DIANDUJI_TRANSLATE_API_KEY` 注入，不写入安装包源码。

## 响应 (200, application/json)

```json
{
  "termTranslation": "随机森林",
  "sentenceTranslation": "随机森林对样本进行分类。",
  "domainGloss": "机器学习中的集成方法",
  "examples": [
    {"source": "Random forests reduce variance.", "translation": "随机森林降低方差。"}
  ],
  "sourceId": "gateway-v1",
  "cacheVersion": "1"
}
```

- `termTranslation`、`sentenceTranslation` 为必填；缺失视为格式异常。
- `domainGloss`、`examples` 可省略。
- `sourceId` 与 `cacheVersion` 用于本地缓存键与来源标识。

## 错误处理

| 情况 | 客户端行为 |
|---|---|
| 401/403 | `unauthorized`，不重试 |
| 其他非 2xx | `badResponse`，丢弃响应 |
| 超时（默认 8s） | `timeout`，可重试 |
| 连接失败 | `offline`，可重试 |
| 响应 JSON 非法/字段缺失 | `badResponse`，**不写缓存、不覆盖词卡** |

## 日志脱敏

客户端日志不输出原句、服务密钥或完整服务响应；缓存只保存结构化结果与
获取时间，不保存 PDF 或整页内容。缓存键使用术语 + 句子摘要（SHA-256）+ 语言
+ 领域 + 服务版本，不保存原句全文。
