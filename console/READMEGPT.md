# Улучшение консоли EMS (Exchange Management Shell)

**Статус:** рекомендованная конфигурация
**Применимо к:** Microsoft Exchange Server 2019 (Windows Server 2019/2022, Windows PowerShell 5.1)

Набор настроек, который делает работу в EMS удобнее:

| Что | Результат |
|---|---|
| PSReadLine 2.4.x | подсказки, поиск по истории, цветной ввод |
| Профиль PowerShell | поиск по истории стрелками (как в Linux), алиас `ll`, переход в `C:\scripts` |
| `myexchange.ps1xml` | информативный вывод `Get-Mailbox` |
| Оформление окна | запуск от администратора, шрифт, прозрачность |
| Отключение баннера и Tips | чистый старт консоли |
| Кастомный prompt | путь, пользователь, сервер, красный цвет при правах администратора |

## Содержание

0. [Подготовка](#0-подготовка)
1. [PSReadLine](#1-psreadline)
2. [Каталог скриптов и файл форматирования](#2-каталог-скриптов-и-файл-форматирования)
3. [Профиль PowerShell](#3-профиль-powershell)
4. [Оформление консоли](#4-оформление-консоли)
5. [Отключение баннера и Tips&Tricks](#5-отключение-баннера-и-tipstricks)
6. [Кастомный prompt](#6-кастомный-prompt)
7. [Откат изменений](#7-откат-изменений)
8. [Устранение неполадок](#8-устранение-неполадок)

---

## 0. Подготовка

- Запускайте EMS **от имени администратора**: ярлык → ПКМ → *Запуск от имени администратора*
  (или выберите ярлык в меню «Пуск» и нажмите **Ctrl+Shift+Enter**).
- Разделы 5 и 6 изменяют системные файлы Exchange. Сначала проверьте всё на тестовом сервере.
- Настройки нужно повторить **на каждом сервере** Exchange отдельно.

> [!WARNING]
> Профиль и файлы из этого репозитория выполняются в консоли администратора на боевом сервере.
> Перед применением **прочитайте их содержимое** и по возможности скачивайте не из ветки `main`,
> а из конкретного коммита или тега (замените `main` в ссылках на хеш коммита).

Ускорить `Invoke-WebRequest` в Windows PowerShell 5.1 (отключает медленный индикатор загрузки):

```powershell
$ProgressPreference = 'SilentlyContinue'
```

## 1. PSReadLine

Модуль PSReadLine отвечает за расширенный ввод: подсказки, историю, автодополнение.
В Windows PowerShell 5.1 по умолчанию встроена версия 2.0.0 — её и заменяем.

Проверить текущую версию:

```powershell
Get-Module PSReadLine
```

### Вариант A. Сервер с доступом в интернет

На чистом Windows Server 2019 может понадобиться провайдер NuGet и обновлённый PowerShellGet
(команда предложит установить его сама).

Для всех пользователей сервера (требуются права администратора):

```powershell
Install-Module PSReadLine -Scope AllUsers -Force -SkipPublisherCheck
```

Только для текущего пользователя:

```powershell
Install-Module PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck
```

Чтобы поставить конкретную версию, добавьте `-RequiredVersion 2.4.5`.
Актуальную версию смотрите в [PowerShell Gallery](https://www.powershellgallery.com/packages/PSReadLine).

### Вариант B. Сервер без интернета

На машине с интернетом и PowerShellGet скачайте модуль:

```powershell
Save-Module PSReadLine -RequiredVersion 2.4.5 -Path C:\Temp
```

Скопируйте папку `C:\Temp\PSReadLine` на целевой сервер в один из каталогов модулей:

- для всех пользователей: `C:\Program Files\WindowsPowerShell\Modules\`
- для текущего пользователя: `$HOME\Documents\WindowsPowerShell\Modules\`
  (если «Документы» перенаправлены, узнайте путь через `$env:PSModulePath`)

Предыдущие версии удалять не нужно — PowerShell загрузит самую новую.
Если файлы были скачаны из интернета архивом, снимите блокировку:

```powershell
Get-ChildItem 'C:\Program Files\WindowsPowerShell\Modules\PSReadLine' -Recurse | Unblock-File
```

### Проверка

Закройте и заново откройте EMS:

```powershell
Get-Module PSReadLine   # Version должна быть 2.4.x
```

## 2. Каталог скриптов и файл форматирования

Файл `myexchange.ps1xml` меняет вывод `Get-Mailbox` (добавляет важные поля).
Каталог `C:\scripts` создаём **до** установки профиля: профиль переходит в него и подгружает из него файл форматирования.

1. Создайте каталог:

   ```powershell
   New-Item -Type Directory 'C:\scripts' -Force | Out-Null
   ```

2. Скачайте файл:

   ```powershell
   Invoke-WebRequest 'https://raw.githubusercontent.com/pnagaev/ExchangeServer/main/console/myexchange.ps1xml' -OutFile 'C:\scripts\myexchange.ps1xml'
   ```

   или скопируйте с эталонного сервера:

   ```powershell
   Copy-Item '\\MyServer\C$\scripts\myexchange.ps1xml' 'C:\scripts\' -Force
   ```

Подключается файл командой `Update-FormatData` из профиля (следующий раздел).
Проверить вручную: `Update-FormatData -PrependPath C:\scripts\myexchange.ps1xml; Get-Mailbox -ResultSize 3`.

## 3. Профиль PowerShell

Профиль — скрипт, который выполняется при каждом запуске оболочки. Что делает наш профиль:

- переходит в `C:\scripts`;
- включает поиск по истории стрелками ↑/↓ (вводите начало команды, стрелки перебирают только совпадения);
- подключает `myexchange.ps1xml`;
- добавляет функцию `ll` — список файлов с размерами в KB/MB/GB.

1. Создайте каталог профиля, если его нет:

   ```powershell
   New-Item -Type Directory (Split-Path $PROFILE) -Force | Out-Null
   ```

2. Сделайте резервную копию существующего профиля (если он есть):

   ```powershell
   if (Test-Path $PROFILE) { Copy-Item $PROFILE "$PROFILE.bak" -Force }
   ```

3. Установите профиль. **Существующий профиль будет перезаписан.**

   ```powershell
   Invoke-WebRequest 'https://raw.githubusercontent.com/pnagaev/ExchangeServer/main/console/Microsoft.PowerShell_profile.ps1' -OutFile $PROFILE
   ```

   или скопируйте с эталонного сервера:

   ```powershell
   Copy-Item '\\MyServer\C$\Users\MyUser\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1' $PROFILE -Force
   ```

4. Проверьте содержимое:

   ```powershell
   notepad $PROFILE
   ```

> [!NOTE]
> Профиль загружается для каждого запуска `powershell.exe` этим пользователем, в том числе из
> планировщика заданий и скриптов (если не указан `-NoProfile`). Он выводит текст и меняет текущий каталог.
> Для автоматических задач запускайте PowerShell с ключом `-NoProfile`.

## 4. Оформление консоли

### Ярлык и права

1. Ярлык EMS находится в `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Exchange Server`.
2. Свойства ярлыка → вкладка **Ярлык** → **Дополнительно / Advanced** → включите
   **«Запускать от имени администратора» / Run as administrator**.
3. Закрепите ярлык на панели задач: ПКМ → **Pin to taskbar**.
4. Альтернатива без изменения ярлыка — запуск через **Ctrl+Shift+Enter** из меню «Пуск».

### Шрифты

Cascadia Mono нужен для корректного отображения символов рамки в prompt (`┌ ─ └`).
Hack Nerd Font Mono — по желанию, если позже понадобятся иконки/Powerline-символы.

1. Скачайте шрифты (нужен доступ в интернет; иначе скачайте на другом компьютере и скопируйте архивы):

   ```powershell
   $ProgressPreference = 'SilentlyContinue'

   # Cascadia Mono
   $Release = Invoke-RestMethod 'https://api.github.com/repos/microsoft/cascadia-code/releases/latest'
   $Url = ($Release.assets | Where-Object name -like '*.zip' | Select-Object -First 1).browser_download_url
   Invoke-WebRequest $Url -OutFile "$env:TEMP\CascadiaCode.zip"
   Expand-Archive "$env:TEMP\CascadiaCode.zip" "$env:TEMP\CascadiaCode" -Force

   # Hack Nerd Font
   Invoke-WebRequest 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip' -OutFile "$env:TEMP\Hack.zip"
   Expand-Archive "$env:TEMP\Hack.zip" "$env:TEMP\Hack" -Force

   explorer.exe $env:TEMP
   ```

2. Установите шрифты: выделите файлы `.ttf` → ПКМ → **Установить для всех пользователей**.
3. Перезапустите EMS, ПКМ по заголовку окна → **Свойства** (только для этого ярлыка) или **По умолчанию**
   (для всех консолей пользователя) → вкладка **Шрифт**.
4. Выберите **Cascadia Mono** и размер по вкусу (в эталонной настройке — 24; подберите под свой монитор).
5. Вкладка **Цвета** → непрозрачность 90 %.

## 5. Отключение баннера и Tips&Tricks

Убирает лишние текстовые блоки при запуске EMS.

1. Сделайте резервную копию (не перезаписывая уже существующую):

   ```powershell
   $bin = Join-Path $env:ExchangeInstallPath 'bin'
   if (-not (Test-Path "$bin\RemoteExchange-old.ps1")) {
       Copy-Item "$bin\RemoteExchange.ps1" "$bin\RemoteExchange-old.ps1"
   }
   ```

2. Откройте файл:

   ```powershell
   notepad "$bin\RemoteExchange.ps1"
   ```

3. Найдите блок `## FILTERS` и закомментируйте вызовы `get-exbanner` и `get-tip`:

   ```powershell
   ## FILTERS #################################################################
   ## Assembles a message and writes it to file from many sequential BinaryFileDataObject instances
   Filter AssembleMessage ([String] $Path) { Add-Content -Path:"$Path" -Encoding:"Byte" -Value:$_.FileData }

   ## now actually call the functions

   #get-exbanner
   #get-tip
   ```

4. Сохраните файл **в исходной кодировке** (не меняйте её в диалоге «Сохранить как») и закройте блокнот.

## 6. Кастомный prompt

Строка приглашения показывает пользователя, сервер и полный путь; при правах администратора имя подсвечивается красным.

```
┌──(user-SERVER)[C:\scripts]
└─$
```

> [!IMPORTANT]
> Для отображения цветов и символов рамки нужны Windows Server 2019 или новее, PSReadLine 2.x (раздел 1) и шрифт Cascadia Mono (раздел 4).
> На старых консолях вместо цветов будут видны последовательности вида `←[38;5;240m`.

1. Сделайте резервную копию:

   ```powershell
   $bin = Join-Path $env:ExchangeInstallPath 'bin'
   if (-not (Test-Path "$bin\CommonConnectFunctions-old.ps1")) {
       Copy-Item "$bin\CommonConnectFunctions.ps1" "$bin\CommonConnectFunctions-old.ps1"
   }
   ```

2. Откройте файл:

   ```powershell
   notepad "$bin\CommonConnectFunctions.ps1"
   ```

3. Найдите функцию `prompt { ... }`, **полностью удалите её** и вставьте на её место код ниже:

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

4. Сохраните файл, закройте все окна EMS и запустите EMS заново.

## 7. Откат изменений

Восстановление оригинальных системных файлов из резервных копий:

```powershell
$bin = Join-Path $env:ExchangeInstallPath 'bin'
Copy-Item "$bin\RemoteExchange-old.ps1"        "$bin\RemoteExchange.ps1"        -Force
Copy-Item "$bin\CommonConnectFunctions-old.ps1" "$bin\CommonConnectFunctions.ps1" -Force
```

Если EMS не запускается совсем, откройте обычный `powershell.exe` и выполните эти же команды, указав путь явно:
`C:\Program Files\Microsoft\Exchange Server\V15\bin`.

Профиль можно отключить, вернув копию `$PROFILE.bak` или запустив консоль с `-NoProfile`.

> [!WARNING]
> Файлы `RemoteExchange.ps1` и `CommonConnectFunctions.ps1` перезаписываются при установке
> накопительных обновлений (CU) и Security Update. После обновления разделы 5 и 6 нужно **выполнить заново**.
> Меняя эти файлы, вы выходите за рамки штатной конфигурации Exchange — учитывайте это при обращении в поддержку.

## 8. Устранение неполадок

| Симптом | Причина и решение |
|---|---|
| При запуске: `Set-Location : Cannot find path 'C:\scripts'` | Не создан каталог. Выполните раздел 2. |
| При запуске: ошибка `Update-FormatData` про отсутствующий файл | Нет `C:\scripts\myexchange.ps1xml`. Выполните раздел 2. |
| В prompt видны `←[38;5;240m` и «кракозябры» | Консоль не поддерживает ANSI. Проверьте версию ОС, `Get-Module PSReadLine` и шрифт. |
| Вместо рамки — «?» или пустые квадраты | Шрифт без символов рамки. Выберите Cascadia Mono. |
| Стрелки ↑/↓ не ищут по истории | PSReadLine не загружен или версия 2.0.0. Раздел 1, затем перезапуск EMS. |
| Prompt снова стандартный после обновления Exchange | Файл перезаписан обновлением. Повторите раздел 6. |
| Скрипты из планировщика печатают «Custom profile loaded» | Добавьте `-NoProfile` в команду запуска задания. |

## Ссылки

- [PSReadLine — документация](https://learn.microsoft.com/powershell/module/psreadline/)
- [about_Profiles](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_profiles)
- [Cascadia Code](https://github.com/microsoft/cascadia-code)
- [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)
