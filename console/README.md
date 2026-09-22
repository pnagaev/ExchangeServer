# Инструкция по улучшению консоли EMS

*Применимо к **Microsoft Exchange Server***

**EMS** — Exchange Management Shell

## Установка последней версии модуля PSReadLine 2.4.5

### Вариант 1

```powershell
Install-Module PSReadLine -Force -Scope CurrentUser -SkipPublisherCheck
Install-Module PSReadLine -RequiredVersion 2.4.5 -Scope AllUsers -Force
```
### Вариант 2 
- Копируем папку с номером версии другого сервера в `C:\Program Files\WindowsPowerShell\Modules\PSReadLine`.

## Настройка профиля PowerShell
- Создаём папку WindowsPowerShell, если нет.
	   ```powershellNew-Item -Type Directory (Split-Path $PROFILE) -Force | Out-Null ```
- Копируем профиль
```powershell
 Invoke-WebRequest 'https://raw.githubusercontent.com/pnagaev/ExchangeServer/main/console/Microsoft.PowerShell_profile.ps1' -OutFile $PROFILE
```
- Просматриваем содержимое профиля
```powershell
  notepad $PROFILE
  #или
  ise $PROFILE
```
## Настройка отображения для get-mailbox 
* Создаём **c:\scripts**, если нет.
 `New-Item -Type Directory "C:\scripts" -Force | Out-Null`
* asdf 
