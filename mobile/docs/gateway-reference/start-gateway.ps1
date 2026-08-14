# 点读机在线翻译网关 —— 一键启动脚本（密钥不写在此文件）
#
# 使用方法：
#   1. 复制 keys.env.example 为 keys.env，填入你的腾讯云密钥
#   2. 运行：powershell -ExecutionPolicy Bypass -File .\start-gateway.ps1
#   3. 看到 "gateway listening on :8080" 即成功；Ctrl+C 停止
#
# 安全：keys.env 已被 .gitignore 排除，绝不进入 git 仓库。

$keysFile = Join-Path $PSScriptRoot 'keys.env'
if (-not (Test-Path $keysFile)) {
    Write-Error '缺少 keys.env：请复制 keys.env.example 并填入密钥。'
    exit 1
}
$keys = @{}
Get-Content $keysFile | ForEach-Object {
    if ($_ -match '^([A-Z_]+)=(.*)$') { $keys[$matches[1]] = $matches[2].Trim() }
}
$env:TENCENT_SECRET_ID = $keys['TENCENT_SECRET_ID']
$env:TENCENT_SECRET_KEY = $keys['TENCENT_SECRET_KEY']
$env:TENCENT_REGION = if ($keys['TENCENT_REGION']) { $keys['TENCENT_REGION'] } else { 'ap-guangzhou' }
$env:DEEPSEEK_API_KEY = if ($keys['DEEPSEEK_API_KEY']) { $keys['DEEPSEEK_API_KEY'] } else { '' }
$env:DEEPSEEK_MODEL = if ($keys['DEEPSEEK_MODEL']) { $keys['DEEPSEEK_MODEL'] } else { 'deepseek-v4-flash' }
$env:DIANDUJI_SYNC_SECRET = if ($keys['DIANDUJI_SYNC_SECRET']) { $keys['DIANDUJI_SYNC_SECRET'] } else { '' }
$env:PORT = if ($keys['PORT']) { $keys['PORT'] } else { '8080' }

$script = Join-Path $PSScriptRoot 'gateway_tencent.py'
python $script
