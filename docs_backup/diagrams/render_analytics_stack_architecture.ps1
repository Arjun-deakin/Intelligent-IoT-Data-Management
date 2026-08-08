$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$out = 'C:\Users\HP\Documents\Arjun Assignment\T4\SIT782_Capstone\CapstoneB_Build_and_Develop\docs_backup\diagrams\analytics-stack-architecture.png'

$bmp = New-Object System.Drawing.Bitmap 1500, 900
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

function Arrow([int]$x1,[int]$y1,[int]$x2,[int]$y2,[string]$label) {
  $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(80,80,80),3)
  $cap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(6,8,$true)
  $pen.CustomEndCap = $cap
  $g.DrawLine($pen,$x1,$y1,$x2,$y2)
  $labelFont = New-Font 10 $true
  $g.DrawString($label,$labelFont,$dark,[System.Drawing.RectangleF]::new([single](($x1+$x2)/2-30),[single](($y1+$y2)/2-16),[single]80,[single]18),$sfCenter)
  $pen.Dispose(); $cap.Dispose()
}

$g.DrawString('Planned Engineering Analytics Stack', $titleFont, $dark, [System.Drawing.RectangleF]::new(0, 18, 1500, 30), $sfCenter)

Box 40 80 340 690 '#F7F7F7' '#6B6B6B' 'Runtime Sources' $sectionFont
Box 85 155 250 90 '#D5E8D4' '#82B366' "Frontend telemetry`nAPI failure count`nrender timing" $bodyFont
Box 85 270 250 100 '#FFE6CC' '#D79B00' "Backend middleware`nrequest count`nlatency`nstatus code" $bodyFont
Box 85 395 250 90 '#E1D5E7' '#9673A6' "Correlation / analytics services`nexecution duration`nsuccess / failure" $bodyFont
Box 85 510 250 90 '#F8CECC' '#B85450' "Database health checks`nconnectivity`ninsert success" $bodyFont
Box 85 625 250 90 '#DAE8FC' '#6C8EBF' "ThingSpeak ingestion metrics`npoll success`nretry count`nrows inserted" $bodyFont

Box 455 160 300 430 '#F7F7F7' '#6B6B6B' 'Collection Layer' $sectionFont
Box 500 240 210 80 '#FFF2CC' '#D6B656' "Health endpoints`n/health`ncontainer health status" $bodyFont
Box 500 350 210 90 '#FCE5CD' '#D79B00' "cAdvisor (optional)`ncontainer CPU`nmemory`nruntime stats" $bodyFont
Box 500 470 210 90 '#D9EAD3' '#6AA84F' "Prometheus scrape targets / exporters`napplication metrics`nruntime metrics" $bodyFont

Box 840 270 240 200 '#F7F7F7' '#6B6B6B' 'Metrics Storage' $sectionFont
Box 885 345 150 90 '#F4CCCC' '#CC4125' "Prometheus`ntime-series store`nscrape + query" $bodyFont

Box 1160 180 280 350 '#F7F7F7' '#6B6B6B' 'Visualization and Alerting' $sectionFont
Box 1205 270 190 110 '#D9D2E9' '#8E7CC3' "Grafana dashboard`nAPI health`nlatency`nerror rate`ncontainer health" $bodyFont
Box 1205 410 190 90 '#F8CECC' '#B85450' "Alert rules`nhigh latency`n5xx spike`nmissing route`npoll failure" $bodyFont

Arrow 380 425 455 425 'metrics'
Arrow 755 425 840 370 'scrape'
Arrow 1080 370 1160 370 'query'

$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
