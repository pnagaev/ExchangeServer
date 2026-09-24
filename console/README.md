# Инструкция по улучшению консоли EMS

**Статус: Рекомендованная конфигурация**

*Применимо к **Microsoft Exchange Server 2019***

## 0. Подготовка
Перед началом работы убедитесь, что вы запускаете Exchange Management Shell(EMS) от имени Администратора.

## 1. Установка последней версии модуля PSReadLine 2.4.5
Модуль PSReadLine обеспечивает продвинутый ввод данных (подсказки, история, автодополнение).
### Вариант 1(Автоматический)

```powershell
Install-Module PSReadLine -Force -Scope CurrentUser -SkipPublisherCheck
```
или
```powershell
Install-Module PSReadLine -RequiredVersion 2.4.5 -Scope AllUsers -Force
```
### Вариант 2(Ручной — если нет доступа к интернету) 
- Найдите сервер с установленным PSReadLine 2.4.5
- Папка с PSReadLine находится в
```powershell
explorer "$HOME\Documents\WindowsPowerShell\Modules\PSReadLine"
```
или
```powershell
explorer `C:\Program Files\WindowsPowerShell\Modules\PSReadLine\`
```
- Скопируйте вручную папку с установленным PSReadLine на свой сервер по этому же пути.
- Если там есть предыдущие версии, то их удалять не обязательно, PowerShell выберет последнюю.

## 2. Настройка профиля PowerShell
Профиль — это скрипт, который выполняется при каждом запуске оболочки.

 1.	Создаем папку профиля WindowsPowerShell(если она отсутствует).
```powershell
  New-Item -Type Directory (Split-Path $PROFILE) -Force | Out-Null
```
 2. Загружаем кастомный профиль (Внимание, данная операция перезапишет существующий профиль)
```powershell
 Invoke-WebRequest 'https://raw.githubusercontent.com/pnagaev/ExchangeServer/main/console/Microsoft.PowerShell_profile.ps1' -OutFile $PROFILE
```
3. Проверка содержимого профиля
```powershell
  notepad $PROFILE
  #или
  ise $PROFILE
```
## 3. Кастомизация вывода get-mailbox 
Настройка визуального отображения командлета get-mailbox с важными полями.
1. Создаем директорию для скриптов **c:\scripts**, если она отсутствует.
```powershell
 New-Item -Type Directory "C:\scripts" -Force | Out-Null
 ```
2. Скачиваем файл настроек 
```powershell
 Invoke-WebRequest 'https://raw.githubusercontent.com/pnagaev/ExchangeServer/main/console/myexchange.ps1xml' -OutFile 'C:\Scripts\myexchange.ps1xml'
```
## 4. Визуальное оформление консоли
### Ярлык и права доступа
1. Найдите ярлык EMS в **C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Exchange Server**
2. В свойствах ярлыка (вкладка **Дополнительно\Advanced**) поставьте галочку **«Запускать от имени администратора»/Run as Administrator** 
3. Закрепите ярлык на панели задач путём нажатия ПКМ над ярлыком и выбора пункта меню **Pin to Taskbar**
4. Альтернатива проделанным выше изменениям - запуск консоли EMS удерживая **Ctrl+Enter**
### Шрифт и прозрачность
1. Скачайте из Интернета и устанавливите в систему шрифты **Cascadia Mono**, **Hack Nerd Font Mono**
```powershell
# Cascadia Mono
$Release = Invoke-RestMethod 'https://api.github.com/repos/microsoft/cascadia-code/releases/latest'
$Url = ($Release.assets | Where-Object name -like '*.zip' | Select-Object -First 1).browser_download_url
Invoke-WebRequest $Url -OutFile "$env:TEMP\CascadiaCode.zip"
Expand-Archive "$env:TEMP\CascadiaCode.zip" "$env:TEMP\CascadiaCode" -Force

# Hack Nerd Font
Invoke-WebRequest `
    'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip' `
    -OutFile "$env:TEMP\Hack.zip"
Expand-Archive "$env:TEMP\Hack.zip" "$env:TEMP\Hack" -Force

explorer.exe $env:TEMP
```
3. Запустите консоль EMS, нажимите ПКМ на заголовке окна, выберите пункт меню **Default** и перейдите во вкладку **Font**
4. Устанавливите шрифт *Cascadia Mono** и размер шрифта по умолчанию 24
5. Перейдите во вкладку **Color** и устанавливаем прозрачность 90%

## 5. Отключение системных уведомлений Tips&Tricks
Это уберет лишние текстовые блоки при запуске.
1. Запустите EMS от админа и сделайте копию системных файлов.
```powershell
  cp "$($exbin)RemoteExchange.ps1" "$($exbin)RemoteExchange-old.ps1"
```
2. Откройте файл для редактирования:
```powershell
  notepad "C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1"
```
3. Найдите блок ## FILTERS и закомментируйте строки с get-exbanner и get-tip:
```powershell
## FILTERS #################################################################
## Assembles a message and writes it to file from many sequential BinaryFileDataObject instances 
Filter AssembleMessage ([String] $Path) { Add-Content -Path:"$Path" -Encoding:"Byte" -Value:$_.FileData }

## now actually call the functions 

#get-exbanner 
#get-tip 
```
4. Сохраните и закройте файл.
  
## 6. Настройка кастомного Prompt
Изменение строки ввода для удобства мониторинга пути и прав.
1. Запустите EMS от имени администратора и сделайте копию файла
```powershell
cp "$($exbin)CommonConnectFunctions.ps1" "$($exbin)CommonConnectFunctions-old.ps1"
```
2. Откройте файл 
```powershell
notepad "C:\Program Files\Microsoft\Exchange Server\V15\bin\CommonConnectFunctions.ps1"
```
3. Найдите функцию prompt {..} и полностью удалите её и замените на код ниже

```powershell
# ============================================================================
# EMS custom prompt
# ============================================================================

$esc   = [char]27
$reset = "$esc[0m"

# Unicode box characters
$BoxTL = [char]0x250C   # ┌
$BoxBL = [char]0x2514   # └
$BoxH  = [char]0x2500   # ─

# Colors
$C_Frame  = "$esc[38;5;240m"
$C_Accent = "$esc[38;5;208m"
$C_User   = "$esc[38;5;117m"
$C_Host   = "$esc[38;5;109m"
$C_Path   = "$esc[38;5;222m"
$C_Prompt = "$esc[1;38;5;176m"
$C_AdmRed = "$esc[1;91m"

# Determine elevation once
$Identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal($Identity)

$IsAdmin = $Principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

function prompt {

    $MyLocation = (Get-Location).Path

    # Window title
    $Host.UI.RawUI.WindowTitle =
        "$env:USERNAME@$env:COMPUTERNAME`: $MyLocation"

    # Available width
    $MyWindowWidth = [Math]::Max(
        40,
        $Host.UI.RawUI.WindowSize.Width - 15
    )

    # Shorten long path
    if ($MyLocation.Length -gt $MyWindowWidth) {

        $TailLength = [Math]::Min(30, $MyLocation.Length - 10)

        $MyLocation =
            $MyLocation.Substring(0, 9) +
            '...' +
            $MyLocation.Substring($MyLocation.Length - $TailLength)
    }

    $NameColor = if ($IsAdmin) {
        $C_AdmRed
    }
    else {
        $C_User
    }

    # ┌──(user-host)[path]
    Write-Host "$C_Frame$BoxTL$BoxH$BoxH" -NoNewline

    Write-Host `
        "$C_Accent($NameColor$env:USERNAME$C_Accent-$C_Host$env:COMPUTERNAME$C_Accent)" `
        -NoNewline

    Write-Host `
        "$C_Frame[$C_Path$MyLocation$C_Frame]" `
        -NoNewline

    # └─$
    Write-Host `
        "`n$C_Frame$BoxBL$BoxH$C_Prompt`$$reset" `
        -NoNewline

    return ' '
}

```
4. Сохраните файл, закройте консоль и запустите EMS снова

### ⚠️ ВАЖНО
- После обновления Exchange Server изменения в файлах RemoteExchange.ps1 и CommonConnectFunctions.ps1 будут утеряны и операцию придётся выполнять заново.
- В случае ошибок при запуске вы всегда можете восстановить оригинальные файлы
