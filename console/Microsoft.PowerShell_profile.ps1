Write-Host "Custom profile loaded" -ForegroundColor green
cd c:\scripts

# Поиск по истории(как в Linux): введите часть команды и выбирайте стрелками только по введённым символам
Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Обновляем вывод get-mailbox на более информативный
Update-FormatData -PrependPath C:\scripts\myexchange.ps1xml

# Алиас ll(как в Linux), часто набираю вместо ls
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
