# Консольные шрифты для Windows и Linux

В этой папке собраны два моноширинных шрифта, которые делают работу в терминале удобнее: улучшают читаемость кода и команд, а также корректно отображают специальные символы, значки и стрелки в приглашениях командной строки.

## Содержимое

| Шрифт | Где используется | Назначение |
|-------|------------------|------------|
| **Cascadia Code** | Windows Terminal (Windows 11) | Шрифт по умолчанию для Windows Terminal, поддерживает программные лигатуры |
| **Hack Nerd Font** | Терминалы Linux, PowerShell (Posh) | Моноширинный шрифт Hack с набором Nerd Fonts: тысячи дополнительных иконок и символов |

## Описание шрифтов

### Cascadia Code

- Разработан Microsoft специально для Windows Terminal и редакторов кода
- Поддерживает программные лигатуры (`=>`, `!=`, `->`, `==` и др.)
- Входит в состав Windows Terminal, но здесь представлен для ручной установки, например на Windows 10 или других системах

### Hack Nerd Font

- Патченная версия шрифта [Hack](https://sourcefoundry.org/hack/) со значками из проекта [Nerd Fonts](https://www.nerdfonts.com/)
- Содержит иконки Font Awesome, Devicons, Powerline, Octicons и других наборов
- Необходим для корректного отображения тем оформления приглашения командной строки, таких как [Oh My Posh](https://ohmyposh.dev/) и [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- Без него вместо иконок отображаются пустые квадраты или символы-заменители

## Установка

### Windows

1. Откройте папку со шрифтом и выделите нужные файлы (`.ttf` или `.otf`).
2. Щёлкните правой кнопкой мыши и выберите **Установить** (или **Установить для всех пользователей**).
3. Перезапустите терминал.

### Linux

```bash
# Создайте каталог для пользовательских шрифтов
mkdir -p ~/.local/share/fonts

# Скопируйте файлы шрифтов
cp *.ttf ~/.local/share/fonts/

# Обновите кэш шрифтов
fc-cache -fv
```

## Настройка терминала

### Windows Terminal

Откройте **Параметры** → **Профили** → **Внешний вид** → **Шрифт** и выберите нужный шрифт.

Или добавьте в `settings.json`:

```json
{
  "profiles": {
    "defaults": {
      "font": {
        "face": "CaskaydiaCove Nerd Font"
      }
    }
  }
}
```

Для Hack Nerd Font укажите `"face": "Hack Nerd Font"`.

### Терминалы Linux

В настройках вашего эмулятора терминала (GNOME Terminal, Konsole, Alacritty и др.) выберите шрифт **Hack Nerd Font** (или **Hack Nerd Font Mono**).

### VS Code (встроенный терминал)

```json
{
  "terminal.integrated.fontFamily": "Hack Nerd Font"
}
```

## Проверка отображения

Выполните команду, чтобы убедиться, что значки отображаются корректно:

```bash
echo -e "\ue0b0 \u00b1 \ue0a0 \u27a6 \u2718 \u26a1 \uf09b \uf015"
```

Если вы видите значки Powerline, Git и иконки, а не пустые квадраты, шрифт установлен и настроен правильно.

## Лицензии

- **Cascadia Code** распространяется по лицензии [SIL Open Font License 1.1](https://github.com/microsoft/cascadia-code/blob/main/LICENSE)
- **Hack** распространяется по лицензии MIT и Bitstream Vera License; Nerd Fonts добавляют собственные патчи под лицензией MIT

> **Примечание.** Если в репозитории лежит именно Cascadia Code (без Nerd Font), укажите в `settings.json` имя `"Cascadia Code"` или `"Cascadia Mono"`. Для значков в стиле Oh My Posh подойдёт вариант `CaskaydiaCove Nerd Font`.
