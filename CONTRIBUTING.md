# 贡献指南 (Contributing)

感谢你对典读鸡的关注！欢迎提交 issue、PR 与建议。

## 行为准则

- 保持友善与专业；讨论围绕代码与设计。
- 隐私优先是本项目的核心约束：任何改动不得引入文档内容、句子或
  个人数据的上传（在线功能仅允许最小披露，见 `mobile/docs/online-translation-gateway.md`）。

## 开发流程

1. Fork 并 clone 仓库。
2. 创建功能分支：`git checkout -b feat/xxx`。
3. 改动遵循项目约定：
   - 功能行为先写测试（TDD：RED → GREEN → 回归）。
   - 运行 `flutter analyze` 零问题、全量 `flutter test` 通过。
   - 中文路径下需使用 ASCII 盘符（见 README）。
4. 提交信息格式：`type: summary`（如 `feat:`、`fix:`、`docs:`、`chore:`）。
5. 提交 PR，说明改动与验证方式。

## 测试

```powershell
Set-Location <worktree>\mobile
$flutter = 'D:\local_environment\Flutter\flutter\bin\flutter.bat'
& $flutter analyze
& $flutter test
```

## 数据与许可

- 新增数据必须注明来源与许可（见 `mobile/docs/third-party-notices.md`）；
  只允许再分发的数据进入仓库。
- 不提交任何密钥（`key.properties`、`keys.env` 等已在 .gitignore）。
