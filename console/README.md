# Инструкция по улучшению консоли EMS

**Статус: Рекомендованная конфигурация**
*Применимо к **Microsoft Exchange Server 2019***

## 0. Подготовка
Перед началом работы убедитесь, что вы запустили PowerShell от имени Администратора.

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
- Копируем вручную папку с установленным PSReadLine на свой сервер по этому же пути.
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
## 3. Настройка "правильного" отображения для get-mailbox 
- Создаём **c:\scripts**, если нет.
```powershell
 New-Item -Type Directory "C:\scripts" -Force | Out-Null
 ```
- Копируем файл 
```powershell
 Invoke-WebRequest 'https://raw.githubusercontent.com/pnagaev/ExchangeServer/main/console/myexchange.ps1xml' -OutFile 'C:\Scripts\myexchange.ps1xml'
```
## 4. Настройка консоли
### Ярлык
- Находим местоположение ярлыка **C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Exchange Server**
- Изменяем в свойствах **Properties\Advanced\Run as Administrator** или запускаем консоль EMS удерживая **Ctrl+Enter**
- Нажимаем ПКМ над ярлыком и нажимаем **Pin to Taskbar**
### Шрифт
- Скачиваем из Интернета и устанавливаем в систему шрифт **Cascadia Mono**, **Hack Nerd Font Mono**
- Запускаем консоль EMS и нажимаем ПКМ на заголовке окна, выбираем **Default** и переходим во вкладку **Font**
- Устанавливаем шрифт *Cascadia Mono** и размер шрифта по умолчанию 24

### Прозрачность
- Переходим во вкладку **Color** и устанавливаем прозрачность 90%

## 5. Убираем Tips&Tricks
- Запускаем EMS от админа и делаем копию файла.
```powershell
  cp "$($exbin)RemoteExchange.ps1" "$($exbin)RemoteExchange-old.ps1"
```
- Открываем файл
```powershell
  notepad "C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1"
```
- находим строки
```powershell
## FILTERS #################################################################
## Assembles a message and writes it to file from many sequential BinaryFileDataObject instances 
Filter AssembleMessage ([String] $Path) { Add-Content -Path:"$Path" -Encoding:"Byte" -Value:$_.FileData }

## now actually call the functions 

get-exbanner 
get-tip 
```
и комментируем строки

```powershell
#get-exbanner 
#get-tip 
```
- Сохраняем файл.
  
## 6. Настройка Prompt
- Запускаем EMS от админа и делаем копию файла
```powershell
cp "$($exbin)CommonConnectFunctions.ps1" "$($exbin)CommonConnectFunctions-old.ps1"
```
- Открываем файл для внесения изменений
```powershell
notepad "C:\Program Files\Microsoft\Exchange Server\V15\bin\CommonConnectFunctions.ps1"
```
- Находим функцию prompt
```powershell
## PROMPT ####################################################################

## PowerShell can support very rich prompts, this simple one prints the current
## working directory and updates the console window title to show the machine 
## name and directory.  

function prompt 
{ 
	$cwd = (get-location).Path
	$host.UI.RawUI.WindowTitle = ($CommonConnectFunctions_LocalizedStrings.res_0004 -f $global:connectedFqdn)
	$host.UI.Write("Yellow", $host.UI.RawUI.BackGroundColor, "[PS]")
	" $cwd>" 
```
-Полностью удаляем функцию prompt и вставляем код ниже

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
- закрываем EMS и запускаем заново.

