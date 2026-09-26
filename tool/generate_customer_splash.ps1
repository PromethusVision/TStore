# Run from any directory on Windows with the project's Flutter/Dart SDK on PATH.
# Only scale/pad the official artwork. No cropping, recoloring or source writes.
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $repoRoot 'assets/logos/esnaftavar-logo.png'
$outputDirectory = Join-Path $repoRoot 'build/branding'
Add-Type -AssemblyName System.Drawing
$source = [System.Drawing.Bitmap]::new($sourcePath)

function Write-SplashInput {
    param([string]$Name, [int]$Width, [int]$Height, [int]$LogoWidth)
    $logoHeight = [int]($LogoWidth * $source.Height / $source.Width)
    $canvas = [System.Drawing.Bitmap]::new(
        $Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($canvas)
    $attributes = [System.Drawing.Imaging.ImageAttributes]::new()
    try {
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $attributes.SetWrapMode([System.Drawing.Drawing2D.WrapMode]::TileFlipXY)
        $destination = [System.Drawing.Rectangle]::new(
            (($Width - $LogoWidth) / 2), (($Height - $logoHeight) / 2), $LogoWidth, $logoHeight)
        $graphics.DrawImage($source, $destination, 0, 0, $source.Width, $source.Height,
            [System.Drawing.GraphicsUnit]::Pixel, $attributes)
        $canvas.Save((Join-Path $outputDirectory $Name), [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $attributes.Dispose()
        $graphics.Dispose()
        $canvas.Dispose()
    }
}

try {
    if ($source.Width -ne 2172 -or $source.Height -ne 724) {
        throw 'Unexpected official logo dimensions; review splash sizing before regenerating.'
    }
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
    # flutter_native_splash consumes 4x inputs: 228 x 76 logical pixels.
    Write-SplashInput -Name 'esnaftavar-splash.png' -Width 912 -Height 304 -LogoWidth 912
    # Android 12 masks a 1152 px canvas to a 768 px circle. The entire
    # 720 x 240 logo rectangle fits inside that circle, including all margins.
    Write-SplashInput -Name 'esnaftavar-android12.png' -Width 1152 -Height 1152 -LogoWidth 720
}
finally {
    $source.Dispose()
}

Push-Location -LiteralPath $repoRoot
try {
    # Keep the existing API-level separation of Android theme attributes.
    # The upstream generator otherwise inserts API 28/29 attributes in base styles.
    $baseStyles = @{}
    foreach ($style in @('values', 'values-night')) {
        $path = Join-Path $repoRoot "android/app/src/main/res/$style/styles.xml"
        $baseStyles[$path] = [System.IO.File]::ReadAllBytes($path)
    }
    try {
        & dart run flutter_native_splash:create --path=splash.yaml
        if ($LASTEXITCODE -ne 0) { throw 'Native splash generation failed.' }
    }
    finally {
        foreach ($path in $baseStyles.Keys) {
            [System.IO.File]::WriteAllBytes($path, $baseStyles[$path])
        }
    }
}
finally {
    Pop-Location
}
