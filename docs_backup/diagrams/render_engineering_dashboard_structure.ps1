$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$out = 'C:\Users\HP\Documents\Arjun Assignment\T4\SIT782_Capstone\CapstoneB_Build_and_Develop\docs_backup\diagrams\engineering-dashboard-structure.png'

$bmp = New-Object System.Drawing.Bitmap 1500, 1080
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'
$g.TextRenderingHint = 'AntiAliasGridFit'
$g.Clear([System.Drawing.Color]::White)

function New-Font([float]$size, [bool]$bold = $false) {
  $style = if ($bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
  return New-Object System.Drawing.Font('Segoe UI', $size, $style)
}

$titleFont = New-Font 20 $true
$sectionFont = New-Font 13 $true
$bodyFont = New-Font 10
$dark = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(35,35,35))
$sfCenter = New-Object System.Drawing.StringFormat
$sfCenter.Alignment = 'Center'
$sfCenter.LineAlignment = 'Center'

function RoundRect([int]$x,[int]$y,[int]$w,[int]$h,[int]$r) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $path.AddArc($x,$y,$d,$d,180,90)
  $path.AddArc($x+$w-$d,$y,$d,$d,270,90)
  $path.AddArc($x+$w-$d,$y+$h-$d,$d,$d,0,90)
  $path.AddArc($x,$y+$h-$d,$d,$d,90,90)
  $path.CloseFigure()
  return $path
}

function Box([int]$x,[int]$y,[int]$w,[int]$h,[string]$fillHex,[string]$lineHex,[string]$text,[System.Drawing.Font]$font) {
  $fill = [System.Drawing.ColorTranslator]::FromHtml($fillHex)
  $line = [System.Drawing.ColorTranslator]::FromHtml($lineHex)
  $path = RoundRect $x $y $w $h 18
  $brush = New-Object System.Drawing.SolidBrush($fill)
  $pen = New-Object System.Drawing.Pen($line,2)
  $g.FillPath($brush,$path)
  $g.DrawPath($pen,$path)
  $rect = [System.Drawing.RectangleF]::new([single]($x+14),[single]($y+10),[single]($w-28),[single]($h-20))
  $g.DrawString($text,$font,$dark,$rect,$sfCenter)
  $brush.Dispose(); $pen.Dispose(); $path.Dispose()
}

Box 40 30 1420 980 '#F7F7F7' '#6B6B6B' "Engineering Analytics Dashboard Structure" $titleFont
Box 90 100 1320 80 '#DAE8FC' '#6C8EBF' "Header and Filters`nEnvironment | Team | Time Range | API Status" $sectionFont
Box 90 200 1320 90 '#D5E8D4' '#82B366' "Executive Summary`nAvailability | p95 Latency | Error Rate | Container Health | Ingestion Status | Alerts" $sectionFont
Box 90 320 630 130 '#FFE6CC' '#D79B00' "Active API Overview`nAll live Node backend APIs with status, latency, and error rate" $sectionFont
Box 780 320 630 130 '#F8CECC' '#B85450' "Frontend / Backend Integration Risks`nMissing or mismatched auth endpoints and failed frontend API calls" $sectionFont
Box 90 480 410 135 '#FFF2CC' '#D6B656' "Data API Performance`n/api/streams | /api/stream-names | /api/data-profile | dataset/series/timestamp routes" $bodyFont
Box 545 480 410 135 '#E1D5E7' '#9673A6' "Correlation and Analytics`n/api/top-correlated-pair | /api/analyse | correlation alert APIs" $bodyFont
Box 1000 480 410 135 '#DAE8FC' '#6C8EBF' "Auth APIs`n/api/register | /api/login | /api/refresh-token | /api/logout | /api/admin/users" $bodyFont
Box 90 645 410 125 '#D5E8D4' '#82B366' "ThingSpeak and Ingestion`nPolling success | retries | rows inserted | /api/feeds" $bodyFont
Box 545 645 410 125 '#FFE6CC' '#D79B00' "Container Runtime Health`nfrontend | backend | db | optional auxiliary services" $bodyFont
Box 1000 645 410 125 '#F8CECC' '#B85450' "Alert Panel`nHigh latency | 5xx spike | missing route | DB outage | ingestion failure" $bodyFont
Box 90 800 1320 150 '#FFFFFF' '#6B6B6B' "Full API Inventory`nTeam | Service | Method | Endpoint | Status | Monitor Priority" $sectionFont

$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
