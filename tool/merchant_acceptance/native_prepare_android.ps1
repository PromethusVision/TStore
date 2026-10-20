param(
  [Parameter(Mandatory=$true)][string]$RunDirectory,
  [Parameter(Mandatory=$true)][string]$AndroidSdk,
  [Parameter(Mandatory=$true)][string]$JavaHome
)
$ErrorActionPreference = 'Stop'
$nativeRepo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$nativeScratch = [IO.Path]::GetFullPath((Join-Path $nativeRepo '.buildlog/merchant-acceptance'))
$nativeRun = (Resolve-Path -LiteralPath $RunDirectory).Path
$nativeState = Get-Content -LiteralPath (Join-Path $nativeRun 'run.json') -Raw | ConvertFrom-Json
if ($nativeState.kind -ne 'synthetic-merchant-ab-local-only' -or
    $nativeState.project -notmatch '^ev-merchant-ab-[a-f0-9]{12}$' -or
    $nativeRun -ne (Join-Path $nativeScratch $nativeState.project)) {
  throw 'Only an owned local fixture is accepted'
}
# Refuse junctions in the whole private path. Do not adopt a user AVD.
$nativeAncestor = Get-Item -LiteralPath $nativeRun
while ($null -ne $nativeAncestor -and $nativeAncestor.FullName -ne $nativeRepo) {
  if ($nativeAncestor.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Reparse path refused' }
  $nativeAncestor = $nativeAncestor.Parent
}
if ($null -eq $nativeAncestor) { throw 'Fixture escaped repository' }
$nativeAdb = Join-Path $AndroidSdk 'platform-tools/adb.exe'
$nativeDevices = & $nativeAdb devices
if ($LASTEXITCODE -ne 0 -or ($nativeDevices -match '^emulator-5582\s')) { throw 'Emulator port unavailable' }
$nativeRoot = Join-Path $nativeRepo '.buildlog/native-android'
New-Item -ItemType Directory -Path $nativeRoot -ErrorAction Stop | Out-Null
$env:ANDROID_USER_HOME = Join-Path $nativeRoot 'user'
$env:ANDROID_AVD_HOME = Join-Path $nativeRoot 'avd'
$env:JAVA_HOME = (Resolve-Path -LiteralPath $JavaHome).Path
New-Item -ItemType Directory -Path $env:ANDROID_USER_HOME,$env:ANDROID_AVD_HOME | Out-Null
$nativeName = 'merchant_native_' + $nativeState.project.Substring($nativeState.project.Length - 12)
'no' | & (Join-Path $AndroidSdk 'cmdline-tools/latest/bin/avdmanager.bat') create avd `
  --name $nativeName --package 'system-images;android-35;google_apis_playstore;x86_64' `
  --device pixel_5 --path (Join-Path $env:ANDROID_AVD_HOME 'merchant.avd')
if ($LASTEXITCODE -ne 0) { throw 'AVD creation failed; existing data retained' }
Start-Process -FilePath (Join-Path $AndroidSdk 'emulator/emulator.exe') `
  -ArgumentList "-avd $nativeName -port 5582 -no-window -no-audio -no-boot-anim -no-snapshot -gpu swiftshader_indirect -camera-back none -camera-front none -http-proxy http://127.0.0.1:9" `
  -WindowStyle Hidden -RedirectStandardOutput (Join-Path $nativeRoot 'emulator.log') `
  -RedirectStandardError (Join-Path $nativeRoot 'emulator-error.log')
Write-Output 'Owned emulator starting. Run native_device isolate before install or use.'
