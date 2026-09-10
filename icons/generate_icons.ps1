# Self-contained PowerShell script to generate high-resolution PNG icons for Grammi Web App
# Renders vector path geometry using Windows Presentation Foundation (WPF) with 100% solid #0b0f17 background

Add-Type -AssemblyName PresentationCore, PresentationFramework, WindowsBase

$pathData = "M504.3 11.1C493.3-1.6 474.5-3.7 461 6.2L252.3 160l144.9 0L502.6 54.6c11.8-11.8 12.6-30.8 1.6-43.5zM32 192c-17.7 0-32 14.3-32 32s14.3 32 32 32c0 82.5 43.4 147.7 123.9 176.2c-11.1 13.9-19.4 30.3-23.9 48.1C127.6 497.4 142.3 512 160 512l192 0c17.7 0 32.4-14.6 28.1-31.7c-4.5-17.8-12.8-34.1-23.9-48.1C436.6 403.7 480 338.5 480 256c17.7 0 32-14.3 32-32s-14.3-32-32-32L32 192z"
$geom = [System.Windows.Media.Geometry]::Parse($pathData)

function Render-Icon($targetPath, $canvasSize, $iconSize) {
    $dv = New-Object System.Windows.Media.DrawingVisual
    $dc = $dv.RenderOpen()

    # 1. Solid opaque background #0b0f17 (zero transparency)
    $bgColor = [System.Windows.Media.Color]::FromRgb(0x0b, 0x0f, 0x17)
    $bgBrush = New-Object System.Windows.Media.SolidColorBrush($bgColor)
    $dc.DrawRectangle($bgBrush, $null, (New-Object System.Windows.Rect(0, 0, $canvasSize, $canvasSize)))

    # 2. Linear gradient from bottom-left (#0d9488) to top-right (#2dd4bf)
    $gradBrush = New-Object System.Windows.Media.LinearGradientBrush
    $gradBrush.StartPoint = New-Object System.Windows.Point(0, 1)
    $gradBrush.EndPoint = New-Object System.Windows.Point(1, 0)
    $gradBrush.GradientStops.Add((New-Object System.Windows.Media.GradientStop([System.Windows.Media.Color]::FromRgb(0x0d, 0x94, 0x88), 0.0)))
    $gradBrush.GradientStops.Add((New-Object System.Windows.Media.GradientStop([System.Windows.Media.Color]::FromRgb(0x14, 0xb8, 0xa6), 0.5)))
    $gradBrush.GradientStops.Add((New-Object System.Windows.Media.GradientStop([System.Windows.Media.Color]::FromRgb(0x2d, 0xd4, 0xbf), 1.0)))

    # 3. Position and scale centered with proportional padding
    $scale = $iconSize / 512.0
    $offset = ($canvasSize - $iconSize) / 2.0

    $transformGroup = New-Object System.Windows.Media.TransformGroup
    $transformGroup.Children.Add((New-Object System.Windows.Media.ScaleTransform($scale, $scale)))
    $transformGroup.Children.Add((New-Object System.Windows.Media.TranslateTransform($offset, $offset)))

    $dc.PushTransform($transformGroup)
    $dc.DrawGeometry($gradBrush, $null, $geom)
    $dc.Pop()
    $dc.Close()

    # Render with 96 DPI
    $rtb = New-Object System.Windows.Media.Imaging.RenderTargetBitmap($canvasSize, $canvasSize, 96, 96, [System.Windows.Media.PixelFormats]::Pbgra32)
    $rtb.Render($dv)

    $encoder = New-Object System.Windows.Media.Imaging.PngBitmapEncoder
    $encoder.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($rtb))
    $fs = [System.IO.File]::Create($targetPath)
    $encoder.Save($fs)
    $fs.Close()
    Write-Output "Generated: $targetPath ($canvasSize x $canvasSize)"
}

$iconsDir = $PSScriptRoot
Render-Icon "$iconsDir\apple-touch-icon.png" 180 108
Render-Icon "$iconsDir\icon-192.png" 192 120
Render-Icon "$iconsDir\icon-512.png" 512 320
Render-Icon "$iconsDir\icon-512-maskable.png" 512 280
Write-Output "All icons successfully exported."
