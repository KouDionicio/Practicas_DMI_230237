Add-Type -AssemblyName System.Drawing

function New-ArmyIcon {
    param(
        [string]$Path,
        [int]$Size
    )

    $bitmap = New-Object System.Drawing.Bitmap(
        $Size,
        $Size,
        [System.Drawing.Imaging.PixelFormat]::Format24bppRgb
    )
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.Color]::FromArgb(89, 71, 125))
    $graphics.ScaleTransform($Size / 512.0, $Size / 512.0)

    $white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $graphics.FillPolygon($white, [System.Drawing.PointF[]]@(
        [System.Drawing.PointF]::new(96, 78),
        [System.Drawing.PointF]::new(251, 133),
        [System.Drawing.PointF]::new(251, 379),
        [System.Drawing.PointF]::new(96, 434)
    ))
    $graphics.FillPolygon($white, [System.Drawing.PointF[]]@(
        [System.Drawing.PointF]::new(416, 78),
        [System.Drawing.PointF]::new(261, 133),
        [System.Drawing.PointF]::new(261, 379),
        [System.Drawing.PointF]::new(416, 434)
    ))

    $accent = New-Object System.Drawing.Pen(
        [System.Drawing.Color]::FromArgb(233, 184, 203),
        18
    )
    $accent.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $accent.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $accent.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $graphics.DrawBezier($accent, 70, 360, 122, 417, 186, 448, 256, 462)
    $graphics.DrawBezier($accent, 256, 462, 326, 448, 390, 417, 442, 360)

    $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $accent.Dispose()
    $white.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}

$scriptDirectory = if ($PSScriptRoot) {
    $PSScriptRoot
} else {
    Join-Path (Get-Location) 'Practica03\yes_no_app\tool'
}
$iconSet = Join-Path $scriptDirectory '..\ios\Runner\Assets.xcassets\AppIcon.appiconset'
$catalog = Get-Content -Raw (Join-Path $iconSet 'Contents.json') | ConvertFrom-Json

foreach ($entry in $catalog.images) {
    $logicalSize = [double](($entry.size -split 'x')[0])
    $scale = [double]($entry.scale.TrimEnd('x'))
    $pixels = [int][Math]::Round($logicalSize * $scale)
    New-ArmyIcon -Path (Join-Path $iconSet $entry.filename) -Size $pixels
}