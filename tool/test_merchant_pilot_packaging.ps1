$ErrorActionPreference = 'Stop'
$pilotRoot = Split-Path $PSScriptRoot -Parent
$pilotLogs = Join-Path $pilotRoot '.buildlog/pilot-packaging'
New-Item -ItemType Directory -Force -Path $pilotLogs | Out-Null
$pilotFields = @{
    MERCHANT_PILOT_ENABLED = 'true'
    MERCHANT_PILOT_URL = 'https://tnipyxnvhgelwdpykyez.supabase.co'
    MERCHANT_PILOT_ANON_KEY = 'sb_publishable_syntheticPilotOnly12345'
}
$pilotEncoded = ($pilotFields.GetEnumerator() | ForEach-Object {
    [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("$($_.Key)=$($_.Value)"))
}) -join ','
$pilotCases = @(
    @{ name='pilot-wrong-target'; task=':app:assembleMerchantPilotDebug'; target='lib/main_development.dart'; reason='requires its isolated pilot entrypoint'; defines=$null },
    @{ name='pilot-release-no-config'; task=':app:assembleMerchantPilotRelease'; target='lib/main_merchant_pilot.dart'; reason='pilot configuration is invalid'; defines=$null },
    @{ name='pilot-release-no-signing'; task=':app:assembleMerchantPilotRelease'; target='lib/main_merchant_pilot.dart'; reason='release signing is not configured'; defines=$pilotEncoded },
    @{ name='local-merchant-release-denied'; task=':app:assembleMerchantDevelopmentRelease'; target='lib/main_merchant_development.dart'; reason='Merchant release requires a separately authorized release configuration'; defines=$null },
    @{ name='customer-production-wrong-target'; task=':app:assembleProductionRelease'; target='lib/main_merchant_pilot.dart'; reason='Customer release target must match'; defines=$null },
    @{ name='customer-bundle-signing-preserved'; task=':app:bundleProductionRelease'; target='lib/main_production.dart'; reason='release signing is not configured'; defines=$null },
    @{ name='pilot-bundle-no-signing'; task=':app:bundleMerchantPilotRelease'; target='lib/main_merchant_pilot.dart'; reason='release signing is not configured'; defines=$pilotEncoded },
    @{ name='aggregate-debug-denied'; task=':app:assembleDebug'; target='lib/main_merchant_pilot.dart'; reason='Merchant pilot packaging requires an explicit pilot flavor'; defines=$null }
)
$pilotOldSigning = $env:ESNAFTAVAR_SIGNING_PROPERTIES
$env:ESNAFTAVAR_SIGNING_PROPERTIES = ''
$pilotResults = @()
Push-Location (Join-Path $pilotRoot 'android')
try {
    foreach ($case in $pilotCases) {
        $log = Join-Path $pilotLogs "$($case.name).log"
        $arguments = @('--offline', '--console=plain', '--dry-run', $case.task, "-Ptarget=$($case.target)")
        if ($case.defines) { $arguments += "-Pdart-defines=$($case.defines)" }
        & ./gradlew.bat @arguments *> $log
        $code = $LASTEXITCODE
        $content = Get-Content -LiteralPath $log -Raw
        $pass = $code -ne 0 -and $content.Contains($case.reason)
        $pilotResults += @{name=$case.name; pass=$pass; expected_rejection=$case.reason; exit_code=$code}
        if (-not $pass) { throw "Pilot packaging boundary failed: $($case.name). See local log." }
    }
} finally {
    Pop-Location
    $env:ESNAFTAVAR_SIGNING_PROPERTIES = $pilotOldSigning
    $pilotResults | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $pilotLogs 'results.json')
}
Write-Output "Pilot packaging boundaries: $($pilotResults.Count) PASS; no artifact signed or remote connection attempted."
exit 0
