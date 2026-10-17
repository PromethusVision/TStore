param([Parameter(Mandatory=$true)][string]$DartExecutable)
$ErrorActionPreference = 'Stop'
$pilotRoot = Split-Path $PSScriptRoot -Parent
$pilotLogs = Join-Path $pilotRoot '.buildlog/pilot-preflight'
New-Item -ItemType Directory -Force -Path $pilotLogs | Out-Null
$pilotBase = @{
    MERCHANT_PILOT_ENABLED = 'true'
    MERCHANT_PILOT_URL = 'https://tnipyxnvhgelwdpykyez.supabase.co'
    MERCHANT_PILOT_ANON_KEY = 'sb_publishable_syntheticPilotOnly12345'
}
$pilotCases = @(
    @{name='valid-offline-only'; changes=@{}; pass=$true},
    @{name='disabled'; changes=@{MERCHANT_PILOT_ENABLED='false'}; pass=$false},
    @{name='production'; changes=@{MERCHANT_PILOT_URL='https://mefhfvrgkwciubeajjeb.supabase.co'}; pass=$false},
    @{name='server-key'; changes=@{MERCHANT_PILOT_ANON_KEY='sb_secret_doNotPrintThisValue12345'}; pass=$false},
    @{name='mixed-config'; changes=@{SUPABASE_PRODUCTION_URL='forbidden'}; pass=$false},
    @{name='economic-activation'; changes=@{REWARD_EARNING_V1_ENABLED='true'}; pass=$false},
    @{name='wrong-target'; changes=@{}; target='lib/main_production.dart'; pass=$false},
    @{name='wrong-flavor'; changes=@{}; flavor='production'; pass=$false}
)
$pilotResults = @()
Push-Location $pilotRoot
try {
    foreach ($case in $pilotCases) {
        $fields = $pilotBase.Clone()
        foreach ($entry in $case.changes.GetEnumerator()) { $fields[$entry.Key] = $entry.Value }
        $file = Join-Path $pilotLogs "$($case.name).json"
        $fields | ConvertTo-Json | Set-Content -LiteralPath $file -Encoding utf8NoBOM
        $target = if ($case.target) {$case.target} else {'lib/main_merchant_pilot.dart'}
        $flavor = if ($case.flavor) {$case.flavor} else {'merchantPilot'}
        $log = Join-Path $pilotLogs "$($case.name).log"
        & $DartExecutable --packages=.dart_tool/package_config.json tool/merchant_pilot_preflight.dart --config $file --target $target --flavor $flavor *> $log
        $code = $LASTEXITCODE
        $content = Get-Content -LiteralPath $log -Raw
        if (($case.pass -and $code -ne 0) -or (-not $case.pass -and $code -ne 2)) { throw "Unexpected preflight result: $($case.name), exit=$code" }
        if ($content.Contains('doNotPrintThisValue') -or $content.Contains('syntheticPilotOnly12345')) { throw 'Preflight disclosed a client/config value' }
        if ($case.pass) {
            $result = $content | ConvertFrom-Json
            if ($result.distribution_ready -ne $false -or $result.remote_authorization -ne $false) { throw 'Offline proof overclaims readiness' }
        }
        $pilotResults += @{name=$case.name; pass=$true; exit_code=$code}
    }
} finally {
    Pop-Location
    $pilotResults | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $pilotLogs 'results.json')
}
Write-Output "Pilot offline preflight: $($pilotResults.Count) PASS; no network requests."
exit 0
