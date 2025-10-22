<#
.SYNOPSIS
  Cleans up files and folders older than 7 days in the user's AppData\Local\Temp folder.

.DESCRIPTION
  This script safely deletes temporary files and folders older than 7 days
  from the current user's temp directory (C:\Users\<User>\AppData\Local\Temp).
  It skips locked/in-use files and logs actions to the console.

.NOTES
  Run PowerShell as Administrator for best results.
#>

# --- Configuration ---
$TempPath = "$env:LOCALAPPDATA\Temp"
$DaysOld  = 7

Write-Host "Scanning temp folder: $TempPath"
Write-Host "Deleting files and folders older than $DaysOld days..."
Write-Host "Started: $(Get-Date)"
Write-Host "----------------------------------------"

# --- Calculate cutoff date ---
$CutoffDate = (Get-Date).AddDays(-$DaysOld)

# --- Delete old files ---
Get-ChildItem -Path $TempPath -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { -not $_.PSIsContainer -and $_.LastWriteTime -lt $CutoffDate } |
    ForEach-Object {
        try {
            Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop
            Write-Host "Deleted file: $($_.FullName)"
        }
        catch {
            Write-Warning "Could not delete file: $($_.FullName) — $($_.Exception.Message)"
        }
    }

# --- Delete old folders (after files are gone) ---
Get-ChildItem -Path $TempPath -Recurse -Force -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt $CutoffDate } |
    Sort-Object FullName -Descending |  # delete child folders first
    ForEach-Object {
        try {
            Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction Stop
            Write-Host "Deleted folder: $($_.FullName)"
        }
        catch {
            Write-Warning "Could not delete folder: $($_.FullName) — $($_.Exception.Message)"
        }
    }

Write-Host "----------------------------------------"
Write-Host "Cleanup complete! Finished at: $(Get-Date)"
