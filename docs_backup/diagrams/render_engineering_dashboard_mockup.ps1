$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$out = 'C:\Users\HP\Documents\Arjun Assignment\T4\SIT782_Capstone\CapstoneB_Build_and_Develop\docs_backup\diagrams\engineering-dashboard-mockup.png'

$bmp = New-Object System.Drawing.Bitmap 1600, 1500
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'
$g.TextRenderingHint = 'AntiAliasGridFit'
$g.Clear([System.Drawing.Color]::FromArgb(246, 248, 251))

function New-Font([float]$size, [bool]$bold = $false) {
  $style = if ($bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
  return New-Object System.Drawing.Font('Segoe UI', $size, $style)
}

$titleFont = New-Font 22 $true
$sectionFont = New-Font 15 $true
$bodyFont = New-Font 11
$smallFont = New-Font 10
$dark = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(32, 41, 56))
$muted = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(100, 112, 128))
$white = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)

$sfLeft = New-Object System.Drawing.StringFormat
$sfLeft.Alignment = 'Near'
$sfLeft.LineAlignment = 'Near'

$sfCenter = New-Object System.Drawing.StringFormat
$sfCenter.Alignment = 'Center'
$sfCenter.LineAlignment = 'Center'

function RoundRect([int]$x, [int]$y, [int]$w, [int]$h, [int]$r) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $path.AddArc($x, $y, $d, $d, 180, 90)
  $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  return $path
}

function Box([int]$x, [int]$y, [int]$w, [int]$h, [string]$fillHex, [string]$lineHex, [string]$text, [System.Drawing.Font]$font) {
  $fill = [System.Drawing.ColorTranslator]::FromHtml($fillHex)
  $line = [System.Drawing.ColorTranslator]::FromHtml($lineHex)
  $path = RoundRect $x $y $w $h 16
  $brush = New-Object System.Drawing.SolidBrush($fill)
  $pen = New-Object System.Drawing.Pen($line, 1.5)
  $g.FillPath($brush, $path)
  $g.DrawPath($pen, $path)
  $rect = [System.Drawing.RectangleF]::new([single]($x + 10), [single]($y + 8), [single]($w - 20), [single]($h - 16))
  $g.DrawString($text, $font, $dark, $rect, $sfCenter)
  $brush.Dispose(); $pen.Dispose(); $path.Dispose()
}

function Card([int]$x, [int]$y, [int]$w, [int]$h, [string]$title, [scriptblock]$inner) {
  $path = RoundRect $x $y $w $h 18
  $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(224,228,235), 1.5)
  $g.FillPath($white, $path)
  $g.DrawPath($pen, $path)
  $g.DrawString($title, $sectionFont, $dark, [System.Drawing.RectangleF]::new($x+18, $y+16, $w-36, 24), $sfLeft)
  & $inner ($x+16) ($y+52) ($w-32) ($h-68)
  $pen.Dispose()
  $path.Dispose()
}

function MetricCard([int]$x, [int]$y, [int]$w, [int]$h, [string]$label, [string]$value, [string]$status, [string]$accentHex) {
  $fill = [System.Drawing.Color]::White
  $line = [System.Drawing.Color]::FromArgb(224,228,235)
  $accent = [System.Drawing.ColorTranslator]::FromHtml($accentHex)
  $path = RoundRect $x $y $w $h 16
  $pen = New-Object System.Drawing.Pen($line, 1.5)
  $brush = New-Object System.Drawing.SolidBrush($fill)
  $accentBrush = New-Object System.Drawing.SolidBrush($accent)
  $g.FillPath($brush, $path)
  $g.DrawPath($pen, $path)
  $g.FillRectangle($accentBrush, $x, $y, 8, $h)
  $g.DrawString($label, $smallFont, $muted, [System.Drawing.RectangleF]::new($x+20, $y+14, $w-40, 18), $sfLeft)
  $g.DrawString($value, (New-Font 20 $true), $dark, [System.Drawing.RectangleF]::new($x+20, $y+34, $w-40, 28), $sfLeft)
  $g.DrawString($status, $smallFont, $accentBrush, [System.Drawing.RectangleF]::new($x+20, $y+68, $w-40, 16), $sfLeft)
  $pen.Dispose(); $brush.Dispose(); $accentBrush.Dispose(); $path.Dispose()
}

function DrawLineChart([int]$x, [int]$y, [int]$w, [int]$h) {
  $axisPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(214,219,226), 1)
  $gridPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(238,241,245), 1)
  for ($i=0; $i -lt 5; $i++) { $yy = $y + [int](($h/4)*$i); $g.DrawLine($gridPen, $x, $yy, $x+$w, $yy) }
  $g.DrawLine($axisPen, $x, $y+$h, $x+$w, $y+$h)
  $g.DrawLine($axisPen, $x, $y, $x, $y+$h)
  $pts = @([System.Drawing.Point]::new($x+5,$y+118),[System.Drawing.Point]::new($x+80,$y+92),[System.Drawing.Point]::new($x+155,$y+97),[System.Drawing.Point]::new($x+230,$y+65),[System.Drawing.Point]::new($x+305,$y+78),[System.Drawing.Point]::new($x+380,$y+50),[System.Drawing.Point]::new($x+455,$y+58),[System.Drawing.Point]::new($x+530,$y+34))
  $pen1 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(66,133,244), 3)
  $g.DrawLines($pen1, $pts)
  foreach($p in $pts){ $g.FillEllipse((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(66,133,244))), $p.X-4, $p.Y-4, 8, 8) }
  $g.DrawString('Latency trend (ms)', $smallFont, $muted, [System.Drawing.RectangleF]::new($x, $y+$h+8, 160, 16), $sfLeft)
  $axisPen.Dispose(); $gridPen.Dispose(); $pen1.Dispose()
}

function DrawBars([int]$x, [int]$y, [int]$w, [int]$h) {
  $gridPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(238,241,245), 1)
  $colors = @(
    [System.Drawing.Color]::FromArgb(93,156,236),
    [System.Drawing.Color]::FromArgb(250,110,82),
    [System.Drawing.Color]::FromArgb(140,193,82),
    [System.Drawing.Color]::FromArgb(172,146,236),
    [System.Drawing.Color]::FromArgb(79,192,232)
  )
  for ($i=0; $i -lt 5; $i++) { $yy = $y + [int](($h/4)*$i); $g.DrawLine($gridPen, $x, $yy, $x+$w, $yy) }
  $bars = @(110,145,90,165,130)
  $labels = @('Frontend','Backend','DB','ThingSpeak','Analytics')
  for($i=0;$i -lt $bars.Count;$i++){
    $bx = $x + 30 + ($i*95)
    $bh = $bars[$i]
    $by = $y + $h - $bh
    $brush = New-Object System.Drawing.SolidBrush($colors[$i])
    $g.FillRectangle($brush, $bx, $by, 52, $bh)
    $g.DrawString($labels[$i], $smallFont, $muted, [System.Drawing.RectangleF]::new($bx-10, $y+$h+8, 72, 28), $sfCenter)
    $brush.Dispose()
  }
  $gridPen.Dispose()
}

function DrawStatusList([int]$x, [int]$y, [int]$w, [int]$h) {
  $statusColors = @(
    [System.Drawing.Color]::FromArgb(52,168,83),
    [System.Drawing.Color]::FromArgb(52,168,83),
    [System.Drawing.Color]::FromArgb(52,168,83),
    [System.Drawing.Color]::FromArgb(251,188,5)
  )
  $items = @(
    @('frontend','Healthy','2 ms check'),
    @('backend','Healthy','/health 200 OK'),
    @('db','Healthy','PostgreSQL ready'),
    @('thingspeak poller','Warning','1 retry in last hour')
  )
  for($i=0;$i -lt $items.Count;$i++){
    $yy = $y + ($i*54)
    $dotBrush = New-Object System.Drawing.SolidBrush($statusColors[$i])
    $g.FillEllipse($dotBrush, $x, $yy+12, 14, 14)
    $g.DrawString($items[$i][0], $bodyFont, $dark, [System.Drawing.RectangleF]::new($x+24, $yy+6, 170, 18), $sfLeft)
    $g.DrawString($items[$i][1], $bodyFont, $dark, [System.Drawing.RectangleF]::new($x+190, $yy+6, 90, 18), $sfLeft)
    $g.DrawString($items[$i][2], $smallFont, $muted, [System.Drawing.RectangleF]::new($x+24, $yy+24, 240, 16), $sfLeft)
    $dotBrush.Dispose()
  }
}

function DrawTable([int]$x, [int]$y, [int]$w, [int]$h) {
  $headers = @('Endpoint','p95 latency','Error rate')
  $rows = @(
    @('/api/streams','420 ms','0.8%'),
    @('/api/data-profile','310 ms','0.2%'),
    @('/api/top-correlated-pair','690 ms','1.1%'),
    @('/api/auth/login','250 ms','0.4%')
  )
  $g.DrawString($headers[0], $smallFont, $muted, [System.Drawing.RectangleF]::new($x, $y, 210, 18), $sfLeft)
  $g.DrawString($headers[1], $smallFont, $muted, [System.Drawing.RectangleF]::new($x+230, $y, 100, 18), $sfLeft)
  $g.DrawString($headers[2], $smallFont, $muted, [System.Drawing.RectangleF]::new($x+360, $y, 90, 18), $sfLeft)
  for($i=0;$i -lt $rows.Count;$i++){
    $yy = $y + 30 + ($i*34)
    $g.DrawLine((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(238,241,245),1)), $x, $yy-8, $x+$w, $yy-8)
    $g.DrawString($rows[$i][0], $bodyFont, $dark, [System.Drawing.RectangleF]::new($x, $yy, 210, 18), $sfLeft)
    $g.DrawString($rows[$i][1], $bodyFont, $dark, [System.Drawing.RectangleF]::new($x+230, $yy, 100, 18), $sfLeft)
    $g.DrawString($rows[$i][2], $bodyFont, $dark, [System.Drawing.RectangleF]::new($x+360, $yy, 90, 18), $sfLeft)
  }
}

function DrawApiSection([int]$x, [int]$y, [int]$w, [string]$title, [array]$rows, [string]$accentHex) {
  $accent = [System.Drawing.ColorTranslator]::FromHtml($accentHex)
  $accentBrush = New-Object System.Drawing.SolidBrush($accent)
  $g.DrawString($title, $bodyFont, $accentBrush, [System.Drawing.RectangleF]::new($x, $y, $w, 16), $sfLeft)
  $g.DrawString('API / Surface', $smallFont, $muted, [System.Drawing.RectangleF]::new($x, $y+22, 240, 16), $sfLeft)
  $g.DrawString('Metric Focus', $smallFont, $muted, [System.Drawing.RectangleF]::new($x+255, $y+22, $w-255, 16), $sfLeft)
  for($i=0;$i -lt $rows.Count;$i++){
    $yy = $y + 46 + ($i*24)
    $linePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(238,241,245),1)
    $g.DrawLine($linePen, $x, $yy-6, $x+$w, $yy-6)
    $g.DrawString($rows[$i][0], $smallFont, $dark, [System.Drawing.RectangleF]::new($x, $yy, 240, 16), $sfLeft)
    $g.DrawString($rows[$i][1], $smallFont, $dark, [System.Drawing.RectangleF]::new($x+255, $yy, $w-255, 16), $sfLeft)
    $linePen.Dispose()
  }
  $accentBrush.Dispose()
}

function DrawApiInventory([int]$x, [int]$y, [int]$w, [int]$h) {
  $backendRows = @(
    @('GET /', 'availability, reachability'),
    @('GET /health', 'availability, status'),
    @('GET /api/streams', 'latency, payload success'),
    @('GET /api/stream-names', 'latency, error rate'),
    @('POST /api/filter-streams', 'validation, failure rate'),
    @('GET /api/data-profile', 'latency, error rate'),
    @('GET /api/datasets', 'latency, error rate'),
    @('GET /api/datasets/:id', 'latency, 404 rate'),
    @('POST /api/datasets', 'create success, validation'),
    @('GET /api/datasets/:name/series', 'payload success, latency'),
    @('POST /api/datasets/:name/series/filter', 'filter success, 4xx rate'),
    @('GET /api/datasets/:name/timestamps', 'latency, success rate'),
    @('POST /api/register', 'auth success, 4xx rate'),
    @('POST /api/login', 'auth failures, latency'),
    @('POST /api/refresh-token', 'token refresh success'),
    @('POST /api/logout', 'request success, latency'),
    @('GET /api/admin/users', '401/403 rate, latency'),
    @('GET /api/feeds', 'upstream success, latency'),
    @('POST /api/analyse', 'execution time, success'),
    @('POST /api/top-correlated-pair', 'p95 latency, failures')
  )
  $frontendRows = @(
    @('Dashboard API calls', 'request failure, render timing'),
    @('POST /api/auth/login', '404 count, integration gap'),
    @('POST /api/auth/register', '404 count, integration gap'),
    @('POST /api/auth/verify-2fa', '404 count, integration gap'),
    @('POST /api/auth/resend-2fa', '404 count, integration gap'),
    @('POST /api/auth/forgot-password', '404 count, integration gap')
  )
  $correlationRows = @(
    @('GET /service-status', 'availability, latency'),
    @('POST /detect-correlation-alert', 'execution time, failures')
  )
  $analyticsRows = @(
    @('POST /analyze', 'optional monitoring'),
    @('POST /analyze-csv', 'optional monitoring'),
    @('POST /analyze-corr', 'optional monitoring')
  )
  $thingspeakRows = @(
    @('polling service / feeds', 'ingestion success, retry count')
  )

  DrawApiSection $x $y 650 'Backend APIs' $backendRows '#D79B00'
  DrawApiSection ($x+690) $y 650 'Frontend / Integration Mismatch' $frontendRows '#B85450'
  DrawApiSection $x ($y+560) 420 'Correlation Service APIs' $correlationRows '#9673A6'
  DrawApiSection ($x+450) ($y+560) 420 'Analytics / Archived APIs' $analyticsRows '#6C8EBF'
  DrawApiSection ($x+900) ($y+560) 440 'ThingSpeak Monitoring Surface' $thingspeakRows '#82B366'
}

$g.DrawString('Engineering Analytics Dashboard', $titleFont, $dark, [System.Drawing.RectangleF]::new(70, 32, 560, 30), $sfLeft)
$g.DrawString('Cross-team operational metrics for frontend, backend, correlation, analytics, database, and ThingSpeak ingestion', $bodyFont, $muted, [System.Drawing.RectangleF]::new(72, 66, 900, 20), $sfLeft)

Box 1180 30 320 52 '#FFFFFF' '#E0E4EB' 'Time Window: Last 24 Hours    |    Environment: Docker Local' $smallFont

MetricCard 70 110 215 95 'Availability' '99.4%' 'Healthy overall' '#34A853'
MetricCard 305 110 215 95 'API p95 Latency' '690 ms' 'Watch correlation route' '#4285F4'
MetricCard 540 110 215 95 'Error Rate' '0.9%' 'Below alert threshold' '#FBBC05'
MetricCard 775 110 215 95 'ThingSpeak Ingest' '10 rows/cycle' 'Last poll successful' '#AB47BC'
MetricCard 1010 110 215 95 'DB Health' 'Connected' 'Schema ready' '#0F9D58'
MetricCard 1245 110 215 95 'Container Restarts' '1' 'Stable runtime' '#F29900'

Card 70 235 620 280 'Latency Trend' { param($x,$y,$w,$h) DrawLineChart $x $y ($w-10) ($h-40) }
Card 715 235 410 280 'Service Request Volume' { param($x,$y,$w,$h) DrawBars $x $y ($w-20) ($h-55) }
Card 1145 235 315 280 'Service Health' { param($x,$y,$w,$h) DrawStatusList $x ($y+4) $w $h }

Card 70 540 620 220 'Endpoint Performance Snapshot' { param($x,$y,$w,$h) DrawTable $x $y ($w-10) $h }
Card 715 540 360 220 'Key Alerts' {
  param($x,$y,$w,$h)
  $alertColors = @(
    [System.Drawing.Color]::FromArgb(251,188,5),
    [System.Drawing.Color]::FromArgb(251,188,5),
    [System.Drawing.Color]::FromArgb(52,168,83),
    [System.Drawing.Color]::FromArgb(52,168,83)
  )
  $items = @(
    'Correlation endpoint latency spike',
    'ThingSpeak retry detected in last hour',
    'No database outage detected',
    'Frontend API proxy healthy'
  )
  for($i=0;$i -lt $items.Count;$i++){
    $yy = $y + ($i*40)
    $alertBrush = New-Object System.Drawing.SolidBrush($alertColors[$i])
    $g.FillEllipse($alertBrush, $x, $yy+8, 12, 12)
    $g.DrawString($items[$i], $bodyFont, $dark, [System.Drawing.RectangleF]::new($x+22, $yy, $w-26, 22), $sfLeft)
    $alertBrush.Dispose()
  }
}
Card 1095 540 365 220 'Collection Framework View' {
  param($x,$y,$w,$h)
  $g.DrawString('Collectors', $bodyFont, $dark, [System.Drawing.RectangleF]::new($x, $y, 120, 18), $sfLeft)
  $g.DrawString('Backend middleware`nContainer health checks`nThingSpeak poll counters`nFrontend request telemetry', $smallFont, $muted, [System.Drawing.RectangleF]::new($x, $y+24, 150, 90), $sfLeft)
  $g.DrawString('Storage', $bodyFont, $dark, [System.Drawing.RectangleF]::new($x+165, $y, 80, 18), $sfLeft)
  $g.DrawString('Prometheus`nTime-series metrics store', $smallFont, $muted, [System.Drawing.RectangleF]::new($x+165, $y+24, 110, 60), $sfLeft)
  $g.DrawString('Visualization', $bodyFont, $dark, [System.Drawing.RectangleF]::new($x+280, $y, 80, 18), $sfLeft)
  $g.DrawString('Grafana or custom React operations dashboard', $smallFont, $muted, [System.Drawing.RectangleF]::new($x+280, $y+24, 80, 90), $sfLeft)
}

Card 70 785 1390 620 'Complete API Inventory By Section' { param($x,$y,$w,$h) DrawApiInventory $x $y ($w-10) $h }

$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
