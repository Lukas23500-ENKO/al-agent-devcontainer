# ─────────────────────────────────────────────────────────────────────────────
# validate-launch-config.ps1
# Runs on every container start (postStartCommand).
# Validates that launch.json exists and is correctly configured for BC AL dev.
# ─────────────────────────────────────────────────────────────────────────────

$ErrorActionPreference = 'Stop'
$warnings = @()
$errors = @()

Write-Host ""
Write-Host "════════════════════════════════════════════════════════"
Write-Host "  ENKO AL Dev Container — launch.json Validation"
Write-Host "════════════════════════════════════════════════════════"
Write-Host ""

# ─────────────────────────────────────────────
# 1. Locate launch.json
# ─────────────────────────────────────────────
$launchPath = "/workspace/.vscode/launch.json"

if (-not (Test-Path $launchPath)) {
    Write-Host "  ⚠ launch.json not found at $launchPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  This is expected if no AL project is open yet." -ForegroundColor Gray
    Write-Host "  When you open an AL project, ensure launch.json exists at:" -ForegroundColor Gray
    Write-Host "  {project}/.vscode/launch.json" -ForegroundColor Gray
    Write-Host ""
    exit 0  # Not an error — container may not have a project yet
}

Write-Host "  ✓ launch.json found" -ForegroundColor Green

# ─────────────────────────────────────────────
# 2. Parse launch.json
# ─────────────────────────────────────────────
try {
    $launch = Get-Content $launchPath -Raw | ConvertFrom-Json
} catch {
    $errors += "launch.json is not valid JSON: $_"
    Write-Host "  ✗ launch.json is not valid JSON" -ForegroundColor Red
    Write-Host "    Error: $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}

Write-Host "  ✓ launch.json is valid JSON" -ForegroundColor Green

# ─────────────────────────────────────────────
# 3. Validate configurations exist
# ─────────────────────────────────────────────
if (-not $launch.configurations -or $launch.configurations.Count -eq 0) {
    $errors += "launch.json has no configurations defined"
    Write-Host "  ✗ No configurations found in launch.json" -ForegroundColor Red
} else {
    Write-Host "  ✓ $($launch.configurations.Count) configuration(s) found" -ForegroundColor Green
}

# ─────────────────────────────────────────────
# 4. Validate each AL configuration
# ─────────────────────────────────────────────
Write-Host ""
Write-Host "  Validating configurations:"
Write-Host ""

$configIndex = 0
foreach ($config in $launch.configurations) {
    $configIndex++
    $configName = if ($config.name) { $config.name } else { "Configuration $configIndex" }
    Write-Host "  [$configIndex] $configName" -ForegroundColor Cyan

    # Check type
    if ($config.type -ne "al") {
        $warnings += "[$configName] type is '$($config.type)' — expected 'al'"
        Write-Host "      ⚠ type should be 'al'" -ForegroundColor Yellow
    } else {
        Write-Host "      ✓ type = al" -ForegroundColor Green
    }

    # Check environmentType
    $validEnvTypes = @("Sandbox", "Production", "OnPrem")
    if (-not $config.environmentType) {
        $errors += "[$configName] environmentType is missing"
        Write-Host "      ✗ environmentType is missing" -ForegroundColor Red
    } elseif ($config.environmentType -notin $validEnvTypes) {
        $warnings += "[$configName] environmentType '$($config.environmentType)' is unusual"
        Write-Host "      ⚠ environmentType = $($config.environmentType) (unusual value)" -ForegroundColor Yellow
    } else {
        Write-Host "      ✓ environmentType = $($config.environmentType)" -ForegroundColor Green

        # Warn if Production is configured — extra caution
        if ($config.environmentType -eq "Production") {
            $warnings += "[$configName] points to a Production environment — be careful!"
            Write-Host "      ⚠ WARNING: This configuration targets Production" -ForegroundColor Yellow
        }
    }

    # Check environmentName
    if (-not $config.environmentName) {
        $errors += "[$configName] environmentName is missing"
        Write-Host "      ✗ environmentName is missing" -ForegroundColor Red
    } else {
        Write-Host "      ✓ environmentName = $($config.environmentName)" -ForegroundColor Green
    }

    # Check tenant
    if (-not $config.tenant) {
        $warnings += "[$configName] tenant is not set — may cause auth issues"
        Write-Host "      ⚠ tenant is not set" -ForegroundColor Yellow
    } else {
        Write-Host "      ✓ tenant = $($config.tenant)" -ForegroundColor Green
    }

    # Check authentication
    $validAuthMethods = @("UserPassword", "AAD", "Windows")
    if (-not $config.authentication) {
        $warnings += "[$configName] authentication method not set — defaulting to UserPassword"
        Write-Host "      ⚠ authentication not set (will default to UserPassword)" -ForegroundColor Yellow
    } elseif ($config.authentication -notin $validAuthMethods) {
        $warnings += "[$configName] authentication '$($config.authentication)' is unusual"
        Write-Host "      ⚠ authentication = $($config.authentication) (unusual value)" -ForegroundColor Yellow
    } else {
        Write-Host "      ✓ authentication = $($config.authentication)" -ForegroundColor Green
    }

    Write-Host ""
}

# ─────────────────────────────────────────────
# 5. Check app.json exists and version is set
# ─────────────────────────────────────────────
$appJsonPath = "/workspace/app.json"

if (Test-Path $appJsonPath) {
    try {
        $appJson = Get-Content $appJsonPath -Raw | ConvertFrom-Json
        Write-Host "  ✓ app.json found" -ForegroundColor Green
        Write-Host "    App:       $($appJson.name)" -ForegroundColor Gray
        Write-Host "    Publisher: $($appJson.publisher)" -ForegroundColor Gray
        Write-Host "    Version:   $($appJson.version)" -ForegroundColor Gray
        Write-Host "    BC target: $($appJson.application)+" -ForegroundColor Gray
        Write-Host ""
    } catch {
        $warnings += "app.json found but could not be parsed: $_"
        Write-Host "  ⚠ app.json found but could not be parsed" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠ app.json not found — is this an AL project?" -ForegroundColor Yellow
    Write-Host ""
}

# ─────────────────────────────────────────────
# 6. Summary
# ─────────────────────────────────────────────
Write-Host "════════════════════════════════════════════════════════"

if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "  ✓ All checks passed — ready to develop" -ForegroundColor Green
} elseif ($errors.Count -eq 0) {
    Write-Host "  ⚠ Passed with $($warnings.Count) warning(s)" -ForegroundColor Yellow
    foreach ($w in $warnings) {
        Write-Host "    · $w" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ✗ $($errors.Count) error(s) found — fix before developing" -ForegroundColor Red
    foreach ($e in $errors) {
        Write-Host "    · $e" -ForegroundColor Red
    }
    if ($warnings.Count -gt 0) {
        Write-Host ""
        Write-Host "  ⚠ $($warnings.Count) warning(s):" -ForegroundColor Yellow
        foreach ($w in $warnings) {
            Write-Host "    · $w" -ForegroundColor Yellow
        }
    }
}

Write-Host "════════════════════════════════════════════════════════"
Write-Host ""
