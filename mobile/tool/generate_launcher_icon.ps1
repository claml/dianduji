# 生成点读机 Android 启动图标（各密度 PNG）
# 用法：powershell -ExecutionPolicy Bypass -File .\generate_launcher_icon.ps1
# 设计：深蓝渐变圆角底 + 白色书本 + 右下放大镜（点读语义）
Add-Type -AssemblyName System.Drawing

$resDir = Join-Path $PSScriptRoot '..\android\app\src\main\res'
$sizes = @{
  'mipmap-mdpi'    = 48
  'mipmap-hdpi'    = 72
  'mipmap-xhdpi'   = 96
  'mipmap-xxhdpi'  = 144
  'mipmap-xxxhdpi' = 192
}

function New-Icon($size) {
  $bmp = New-Object System.Drawing.Bitmap $size, $size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.Clear([System.Drawing.Color]::Transparent)

  $s = [float]$size

  # 圆角矩形背景（深蓝 -> 青渐变）
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $radius = $s * 0.22
  $d = $radius * 2
  $path.AddArc(0, 0, $d, $d, 180, 90)
  $path.AddArc($s - $d, 0, $d, $d, 270, 90)
  $path.AddArc($s - $d, $s - $d, $d, $d, 0, 90)
  $path.AddArc(0, $s - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  $rect = New-Object System.Drawing.RectangleF 0, 0, $s, $s
  $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $rect,
    [System.Drawing.Color]::FromArgb(255, 61, 122, 237),
    [System.Drawing.Color]::FromArgb(255, 0, 191, 220),
    60.0)
  $g.FillPath($brush, $path)

  # 白色书本（两页）
  $bookLeft = $s * 0.24
  $bookTop = $s * 0.18
  $bookW = $s * 0.52
  $bookH = $s * 0.46
  $bookBrush = [System.Drawing.Brushes]::White
  $bookPath = New-Object System.Drawing.Drawing2D.GraphicsPath
  $br = $bookW * 0.10
  $bd = $br * 2
  $bookPath.AddArc($bookLeft, $bookTop, $bd, $bd, 180, 90)
  $bookPath.AddArc($bookLeft + $bookW - $bd, $bookTop, $bd, $bd, 270, 90)
  $bookPath.AddArc($bookLeft + $bookW - $bd, $bookTop + $bookH - $bd, $bd, $bd, 0, 90)
  $bookPath.AddLine($bookLeft + $bookW - $bd, $bookTop + $bookH, $bookLeft, $bookTop + $bookH)
  $bookPath.CloseFigure()
  $g.FillPath($bookBrush, $bookPath)

  # 书脊线
  $spineX = $bookLeft + $bookW * 0.42
  $spinePen = New-Object System.Drawing.Pen (
    [System.Drawing.Color]::FromArgb(255, 61, 122, 237), ($s * 0.035))
  $spinePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $spinePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $g.DrawLine($spinePen, $spineX, $bookTop + $bookH * 0.12,
    $spineX, $bookTop + $bookH * 0.86)

  # 放大镜（右下）
  $lensR = $s * 0.13
  $lensCx = $s * 0.68
  $lensCy = $s * 0.70
  $lensPen = New-Object System.Drawing.Pen ([System.Drawing.Brushes]::White, ($s * 0.045))
  $lensPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $lensPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $g.DrawEllipse($lensPen, $lensCx - $lensR, $lensCy - $lensR,
    $lensR * 2, $lensR * 2)
  $g.DrawLine($lensPen,
    $lensCx + $lensR * 0.72, $lensCy + $lensR * 0.72,
    $lensCx + $lensR * 1.55, $lensCy + $lensR * 1.55)

  $g.Dispose()
  return $bmp
}

foreach ($entry in $sizes.GetEnumerator()) {
  $dir = Join-Path $resDir $entry.Key
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  $icon = New-Icon $entry.Value
  $icon.Save((Join-Path $dir 'ic_launcher.png'),
    [System.Drawing.Imaging.ImageFormat]::Png)
  $icon.Dispose()
  Write-Host "generated $($entry.Key)/ic_launcher.png ($($entry.Value)x$($entry.Value))"
}
Write-Host 'done'
