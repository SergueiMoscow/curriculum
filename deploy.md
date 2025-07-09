## Клонирование с темой
```bash
git clone --recursive https://github.com/SergueiMoscow/curriculum

```

## Если уже склонирован без темы
```bash
git submodule update --init --recursive

```

### После клонирования, перед запуском контейнера проверить наличие темы:
```bash
ls -la themes/ananke/
```