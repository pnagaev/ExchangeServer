Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

Write-Host "Custom profile loaded" -ForegroundColor green
Update-FormatData -PrependPath C:\scripts\myexchange.ps1xml
cd c:\scripts

function ll {
    Get-ChildItem -Force @args | Select-Object Mode, LastWriteTime, @{
        Name = 'Size'
        Expression = {
            if ($_.PSIsContainer) {
                ''
            }
            elseif ($_.Length -ge 1GB) {
                '{0:N2} GB' -f ($_.Length / 1GB)
            }
            elseif ($_.Length -ge 1MB) {
                '{0:N2} MB' -f ($_.Length / 1MB)
            }
            else {
                '{0:N2} KB' -f ($_.Length / 1KB)
            }
        }
    }, Name | Format-Table Mode, LastWriteTime, @{
        Label = 'Size'
        Expression = { $_.Size }
        Alignment = 'Right'
    }, Name -AutoSize
}
