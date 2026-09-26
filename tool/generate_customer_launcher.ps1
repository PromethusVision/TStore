# Run on Windows with the existing Flutter/Dart SDK on PATH.
# Reuses the owner-selected V; never writes to the official source wordmark.
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $repoRoot 'assets/logos/esnaftavar-logo.png'
if ((Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash.ToLowerInvariant() -ne 'a87dc38bcd50dd2650c71257e664c744ad28982f8eddd452f50029c6fe25fb30') {
    throw 'Official logo changed; review the selected symbol before regenerating.'
}
$outputDirectory = Join-Path $repoRoot 'build/branding'
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
Add-Type -AssemblyName System.Drawing
if (-not ('CustomerLauncherArtwork' -as [type])) {
    $references = @('System.Drawing.Common', 'System.Drawing.Primitives', 'System.Collections', 'System.Runtime')
    # Newer PowerShell/.NET releases split GDI interfaces into these assemblies.
    foreach ($assembly in @('System.Private.Windows.GdiPlus.dll', 'System.Private.Windows.Core.dll')) {
        $assemblyPath = Join-Path $PSHOME $assembly
        if (Test-Path -LiteralPath $assemblyPath) { $references += $assemblyPath }
    }
    Add-Type -ReferencedAssemblies $references -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
public static class CustomerLauncherArtwork {
    private static bool Warm(Color c) { return c.R > 150 && c.G < 220 && c.B < 130; }
    public static void Generate(string sourcePath, string destination) {
        using (var source = new Bitmap(sourcePath)) {
            if (source.Width != 2172 || source.Height != 724)
                throw new InvalidOperationException("Unexpected official logo size.");
            // Select the disconnected V component. Near-transparent export noise
            // otherwise bridges it to the neighboring a; preserve original RGBA.
            int width = source.Width, height = source.Height;
            var selected = new bool[width * height];
            var visited = new bool[width * height];
            var queue = new Queue<int>();
            queue.Enqueue(420 * width + 1500);
            int minX = width, minY = height, maxX = 0, maxY = 0, count = 0;
            while (queue.Count > 0) {
                int index = queue.Dequeue();
                if (visited[index]) continue;
                visited[index] = true;
                int x = index % width, y = index / width;
                Color c = source.GetPixel(x, y);
                if (c.A < 16 || !Warm(c)) continue;
                selected[index] = true; count++;
                minX = Math.Min(minX, x); maxX = Math.Max(maxX, x);
                minY = Math.Min(minY, y); maxY = Math.Max(maxY, y);
                if (x > 0) queue.Enqueue(index - 1);
                if (x + 1 < width) queue.Enqueue(index + 1);
                if (y > 0) queue.Enqueue(index - width);
                if (y + 1 < height) queue.Enqueue(index + width);
            }
            if (count != 65160 || minX != 1380 || minY != 149 || maxX != 1751 || maxY != 534)
                throw new InvalidOperationException("Official V selection changed.");
            using (var symbol = new Bitmap(maxX - minX + 3, maxY - minY + 3, PixelFormat.Format32bppArgb)) {
                for (int y = minY - 1; y <= maxY + 1; y++) {
                    for (int x = minX - 1; x <= maxX + 1; x++) {
                        int index = y * width + x;
                        bool adjacent = selected[index] || selected[index - 1] || selected[index + 1]
                            || selected[index - width] || selected[index + width];
                        Color c = source.GetPixel(x, y);
                        if (adjacent && Warm(c)) symbol.SetPixel(x - minX + 1, y - minY + 1, c);
                    }
                }
                Save(symbol, destination + "/esnaftavar-launcher.png", 720, false, false);
                // Entire V bounding rectangle fits the 66dp adaptive safe circle
                // within the 108dp canvas; no generator inset is added.
                Save(symbol, destination + "/esnaftavar-launcher-foreground.png", 440, true, false);
                Save(symbol, destination + "/esnaftavar-launcher-monochrome.png", 440, true, true);
            }
        }
    }
    private static void Save(Bitmap symbol, string path, int symbolHeight, bool transparent, bool monochrome) {
        using (var canvas = new Bitmap(1024, 1024, PixelFormat.Format32bppArgb)) {
            using (var graphics = Graphics.FromImage(canvas))
            using (var attributes = new ImageAttributes()) {
                graphics.Clear(transparent ? Color.Transparent : Color.White);
                graphics.CompositingMode = CompositingMode.SourceOver;
                graphics.InterpolationMode = InterpolationMode.HighQualityBicubic;
                graphics.PixelOffsetMode = PixelOffsetMode.HighQuality;
                attributes.SetWrapMode(WrapMode.TileFlipXY);
                int symbolWidth = (int)Math.Round(symbolHeight * (double)symbol.Width / symbol.Height);
                var target = new Rectangle((1024 - symbolWidth) / 2, (1024 - symbolHeight) / 2, symbolWidth, symbolHeight);
                graphics.DrawImage(symbol, target, 0, 0, symbol.Width, symbol.Height, GraphicsUnit.Pixel, attributes);
            }
            if (monochrome) {
                for (int y = 0; y < 1024; y++)
                    for (int x = 0; x < 1024; x++) {
                        Color c = canvas.GetPixel(x, y);
                        canvas.SetPixel(x, y, Color.FromArgb(c.A, 255, 255, 255));
                    }
            }
            canvas.Save(path, ImageFormat.Png);
        }
    }
}
'@
}
[CustomerLauncherArtwork]::Generate($sourcePath, $outputDirectory)
Push-Location -LiteralPath $repoRoot
try {
    & dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
    if ($LASTEXITCODE -ne 0) { throw 'Launcher resource generation failed.' }
}
finally { Pop-Location }
