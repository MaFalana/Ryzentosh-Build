# Quick OC boot log reader - run elevated or from Kiro
# Mounts EFI, finds most recent non-empty log, and displays it

# Mount EFI
Start-Process cmd -ArgumentList '/c mountvol W: /s' -Verb RunAs -Wait

# Get all OC log files sorted newest first
$logFiles = Start-Process cmd -ArgumentList '/c dir W:\opencore*.txt /b /o-d > C:\Users\Malik\oc-logs-list.txt 2>&1' -Verb RunAs -Wait -PassThru
Start-Sleep -Seconds 1
$files = Get-Content 'C:\Users\Malik\oc-logs-list.txt' | Where-Object { $_.Trim() -ne '' }

Write-Host "`n=== OpenCore Boot Logs (newest first) ===" -ForegroundColor Cyan
Write-Host "Found $($files.Count) log files"
Write-Host ""

# Read each file until we find one with content
foreach ($file in $files) {
    Start-Process cmd -ArgumentList "/c copy /b W:\$file C:\Users\Malik\oc-log-raw.bin > nul 2>&1" -Verb RunAs -Wait
    $bytes = [System.IO.File]::ReadAllBytes('C:\Users\Malik\oc-log-raw.bin')
    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    $clean = $text -replace "`0", ""
    
    if ($clean.Length -gt 0) {
        Write-Host ">>> LOG: $file <<<" -ForegroundColor Green
        Write-Host ""
        
        # Check for key indicators
        if ($clean -match "EB\|STOP") {
            Write-Host "[!] BOOT STOPPED - Memory/Booter issue (not a kernel panic)" -ForegroundColor Red
        }
        if ($clean -match "EXITBS:START") {
            Write-Host "[OK] Reached EXITBS - boot.efi handed off to kernel" -ForegroundColor Yellow
        }
        if ($clean -match "EB\.MM\.AKMR") {
            Write-Host "[!] Memory allocation failure - check slide/SetupVirtualMap/DevirtualiseMmio" -ForegroundColor Red
        }
        if ($clean -match "Boot failed") {
            Write-Host "[!] Boot failed and aborted" -ForegroundColor Red
        }
        
        # Show boot-args
        $argsMatch = [regex]::Match($clean, 'MBA:NV.*?<"(.*?)">')
        if ($argsMatch.Success) {
            Write-Host "`nBoot-args: $($argsMatch.Groups[1].Value)" -ForegroundColor Cyan
        }
        
        # Show board ID
        $brdMatch = [regex]::Match($clean, 'BRD:NV\] (.*)')
        if ($brdMatch.Success) {
            Write-Host "Board ID: $($brdMatch.Groups[1].Value)" -ForegroundColor Cyan
        }
        
        Write-Host "`n--- Full Log ---`n"
        Write-Host $clean
        break
    }
    else {
        Write-Host "  $file - EMPTY (skipping)" -ForegroundColor DarkGray
    }
}
