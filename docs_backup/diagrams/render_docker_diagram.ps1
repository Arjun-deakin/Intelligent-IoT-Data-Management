$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$out1 = 'C:\Users\HP\Documents\Arjun Assignment\T4\SIT782_Capstone\CapstoneB_Build_and_Develop\docs_backup\diagrams\docker-container-architecture.png'

$bmp = New-Object System.Drawing.Bitmap 1600, 950
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'
$g.TextRenderingHint = 'AntiAliasGridFit'
$g.Clear([System.Drawing.Color]::White)

function New-Font([float]$size, [bool]$bold = $false) {
  $style = if ($bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
  return New-Object System.Drawing.Font('Segoe UI', $size, $style)
}

$titleFont = New-Font 22 $true
$headFont = New-Font 16 $true
$bodyFont = New-Font 12
$smallFont = New-Font 11
$midBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(35, 35, 35))

$sfCenter = New-Object System.Drawing.StringFormat
$sfCenter.Alignment = 'Center'
$sfCenter.LineAlignment = 'Center'

$sfLeft = New-Object System.Drawing.StringFormat
$sfLeft.Alignment = 'Near'
$sfLeft.LineAlignment = 'Center'

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
  $path = RoundRect $x $y $w $h 18
  $brush = New-Object System.Drawing.SolidBrush($fill)
  $pen = New-Object System.Drawing.Pen($line, 2.5)
  $g.FillPath($brush, $path)
  $g.DrawPath($pen, $path)
  $rect = [System.Drawing.RectangleF]::new([single]($x + 12), [single]($y + 10), [single]($w - 24), [single]($h - 20))
  $g.DrawString($text, $font, $midBrush, $rect, $sfCenter)
  $brush.Dispose()
  $pen.Dispose()
  $path.Dispose()
}

function Label([string]$text, [int]$x, [int]$y) {
  $size = $g.MeasureString($text, $smallFont)
  $rect = [System.Drawing.RectangleF]::new([single]($x - ($size.Width / 2) - 8), [single]($y - ($size.Height / 2) - 3), [single]($size.Width + 16), [single]($size.Height + 6))
  $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::LightGray, 1)
  $g.FillRectangle([System.Drawing.Brushes]::White, $rect)
  $g.DrawRectangle($pen, [int]$rect.X, [int]$rect.Y, [int]$rect.Width, [int]$rect.Height)
  $g.DrawString($text, $smallFont, $midBrush, $rect, $sfCenter)
  $pen.Dispose()
}

function Arrow([int]$x1, [int]$y1, [int]$x2, [int]$y2, [string]$label, [bool]$dashed = $false) {
  $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(70, 70, 70), 3)
  if ($dashed) { $pen.DashStyle = 'Dash' }
  $cap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(6, 8, $true)
  $pen.CustomEndCap = $cap
  $g.DrawLine($pen, $x1, $y1, $x2, $y2)
  if ($label) {
    Label $label ([int](($x1 + $x2) / 2)) ([int](($y1 + $y2) / 2))
  }
  $pen.Dispose()
  $cap.Dispose()
}

$g.DrawString('Docker Container-Based Architecture', $titleFont, $midBrush, [System.Drawing.RectangleF]::new(0, 18, 1600, 35), $sfCenter)

Box 145 110 1310 700 '#F7F7F7' '#6B6B6B' "Docker Compose Runtime`ndocker-compose.yml" $headFont
Box 600 55 400 48 '#DAE8FC' '#6C8EBF' 'Developer Browser / Host Access' $bodyFont

Box 220 210 270 130 '#D5E8D4' '#82B366' "frontend container`nVite React application`nPort 5173" $bodyFont
Box 650 205 310 145 '#FFE6CC' '#D79B00' "backend container`nNode / Express API`nPort 3000`nHealth endpoint: /health" $bodyFont
Box 1110 220 220 120 '#F8CECC' '#B85450' "db container`nPostgreSQL 16`nPort 5432" $bodyFont

Box 1110 405 220 85 '#E1D5E7' '#9673A6' "Named volume`npostgres_data" $bodyFont
Box 1110 535 220 95 '#FFF2CC' '#D6B656' "Schema initialization`nbackend/src/db/schema.sql" $smallFont

Box 220 430 270 80 '#F5F5F5' '#7A7A7A' "Bind mount`nnew-frontend/frontend" $bodyFont
Box 650 430 310 80 '#F5F5F5' '#7A7A7A' "Bind mount`nbackend" $bodyFont
Box 1090 695 260 100 '#DAE8FC' '#6C8EBF' "ThingSpeak Cloud API`nExternal live IoT feed source" $bodyFont

Box 220 590 740 120 '#FFF2CC' '#D6B656' "Container startup order`n1. db becomes healthy`n2. backend starts and passes /health`n3. frontend becomes ready after backend" $bodyFont
Box 220 735 740 60 '#FCE5CD' '#D79B00' "Container-to-container communication: frontend -> backend via /api proxy, backend -> db via SQL, backend -> ThingSpeak via HTTPS polling" $smallFont

Arrow 700 103 355 210 'HTTP :5173'
Arrow 490 275 650 275 'API proxy'
Arrow 960 280 1110 280 'SQL queries'
Arrow 1220 340 1220 405 'persistent storage'
Arrow 1220 535 1220 340 'init schema'
Arrow 490 470 490 340 'live source' $true
Arrow 805 430 805 350 'live source' $true
Arrow 960 320 1090 720 'HTTPS polling'

$legendRect = [System.Drawing.RectangleF]::new([single]1080, [single]120, [single]280, [single]60)
$g.DrawString('Internal Docker network links are shown by the directional arrows between containers. Exposed host ports are shown inside each container box.', $smallFont, $midBrush, $legendRect, $sfLeft)

$bmp.Save($out1, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
