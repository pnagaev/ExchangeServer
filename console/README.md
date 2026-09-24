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
Install-Module PSReadLine -RequiredVersion 2.4.5 -Scope AllUsers -Force
```
### Вариант 2(Ручной — если нет доступа к интернету) 
- Найдите сервер с установленным PSReadLine 2.4.5
- Папка с PSReadLine находится в `C:\Program Files\WindowsPowerShell\Modules\PSReadLine\2.4.5`
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
2. Запустите консоль EMS, нажимите ПКМ на заголовке окна, выберите пункт меню **Default** и перейдите во вкладку **Font**
3. Устанавливите шрифт *Cascadia Mono** и размер шрифта по умолчанию 24
4. Перейдите во вкладку **Color** и устанавливаем прозрачность 90%

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
# ===== Рамочный prompt — дизайнерская палитра =====
$esc   = [char]27
$reset = "$esc[0m"
 
# Рамочные символы через коды
$BoxTL = [char]0x250C   # ┌
$BoxBL = [char]0x2514   # └
$BoxH  = [char]0x2500   # ─
 
# Палитра (один блок — легко перекрашивать)
$C_Frame  = "$esc[38;5;240m"   # каркас — графит
$C_Accent = "$esc[38;5;208m"   # скобки/разделители — янтарный
$C_User   = "$esc[38;5;117m"   # имя — небесный
$C_Host   = "$esc[38;5;109m"   # хост — шалфейный
$C_Path   = "$esc[38;5;222m"   # путь — сливочный
$C_Prompt = "$esc[1;38;5;176m" # $ — жирный орхидный
$C_AdmRed = "$esc[1;91m"       # админ — жирный красный
 
# Заголовок окна и флаг админа — один раз
$Host.UI.RawUI.WindowTitle = "$env:USERNAME@$env:COMPUTERNAME`: $((Get-Location).ProviderPath)"
$IsAdmin = (whoami /groups) -match 'S-1-5-32-544'
 
function prompt {
    $MyLocation    = (Get-Location).Path
    $MyWindowWidth = $Host.UI.RawUI.MaxWindowSize.Width - 15
 
    if ($MyLocation.Length -gt $MyWindowWidth) {
        $MyLocation = $MyLocation.Substring(0,9) + "..." + $MyLocation.Substring($MyLocation.Length - 20, 20)
    }
 
    # Имя: красное и жирное для админа, небесное для пользователя
    $NameColor = if ($IsAdmin) { $C_AdmRed } else { $C_User }
 
    # ┌──(user-host)[путь]
    Write-Host "$C_Frame$BoxTL$BoxH$BoxH" -NoNewline
    Write-Host "$C_Accent($NameColor$env:USERNAME$C_Accent-$C_Host$env:COMPUTERNAME$C_Accent)" -NoNewline
    Write-Host "$C_Frame[$C_Path$MyLocation$C_Frame]" -NoNewline
 
    # └─$
    Write-Host "`n$C_Frame$BoxBL$BoxH$C_Prompt`$$reset" -NoNewline
 
    return " "
}
# =====================================================

```
4. Сохраните файл, закройте консоль и запустите EMS снова

