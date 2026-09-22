
# Инструкция по улучшению консоли EMS.
Применимо к Microsoft Exchange Server
EMS - Exchange Management Shell

## Установка последнего модуля PSReadLine 2.4.5
	1. Устанавливаем 
	    `Install-Module PSReadLine -Force -Scope CurrentUser -SkipPublisherCheck`
	2. Или копируем с другого сервера в  `C:\Program Files\WindowsPowerShell\Modules\PSReadLine` и смотрим номер версии
## Настройка профиля PowerShell
	1. notepad $PROFILE или `ise $PROFILE`
	2. Проверяем есть ли папка WindowsPowerShell и создаём, если нет.
	   `New-Item -Type Directory (Split-Path $PROFILE) -Force | Out-Null`
	3. Копируем профиль
## Настройка отображения для get-mailbox 
	1. Проверяем c:\scripts, если нет, то создаём 
	2. `New-Item -Type Directory "C:\scripts" -Force | Out-Null`
	3. 
