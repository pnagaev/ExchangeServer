# Инструкция по улучшению консоли EMS (Статус:DRAFT)


*Применимо к **Microsoft Exchange Server 2019***

**EMS** — Exchange Management Shell

## Установка последней версии модуля PSReadLine 2.4.5

### Вариант 1

```powershell
Install-Module PSReadLine -Force -Scope CurrentUser -SkipPublisherCheck
Install-Module PSReadLine -RequiredVersion 2.4.5 -Scope AllUsers -Force
```
### Вариант 2 
- Папка с PSReadLine находится в `C:\Program Files\WindowsPowerShell\Modules\PSReadLine\2.4.5`
- Копируем вручную папку с установленным PSReadLine на свой сервер по этому же пути.

## Настройка профиля PowerShell
- Создаём папку WindowsPowerShell, если нет.
```powershell
  New-Item -Type Directory (Split-Path $PROFILE) -Force | Out-Null
```
- Копируем профиль(Внимание, данная операция перезапишет существующий профиль)
```powershell
 Invoke-WebRequest 'https://raw.githubusercontent.com/pnagaev/ExchangeServer/main/console/Microsoft.PowerShell_profile.ps1' -OutFile $PROFILE
```
- Просматриваем содержимое профиля
```powershell
  notepad $PROFILE
  #или
  ise $PROFILE
```
## Настройка "правильного" отображения для get-mailbox 
- Создаём **c:\scripts**, если нет.
```powershell
 New-Item -Type Directory "C:\scripts" -Force | Out-Null
 ```
- Копируем файл 
```powershell
 Invoke-WebRequest 'https://raw.githubusercontent.com/pnagaev/ExchangeServer/main/console/myexchange.ps1xml' -OutFile 'C:\Scripts\myexchange.ps1xml'
```
## Настройка консоли
### Ярлык
- Находим местоположение ярлыка **C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Exchange Server**
- Изменяем в свойствах **Properties\Advanced\Run as Administrator** или запускаем консоль EMS удерживая **Ctrl+Enter**
- Нажимаем ПКМ над ярлыком и нажимаем **Pin to Taskbar**
### Шрифт
- 
- Запускаем консоль

### Прозрачность

