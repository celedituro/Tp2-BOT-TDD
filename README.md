Telegram Bot Salta
====================

### Integrantes del grupo
* [Dituro Celeste](https://gitlab.com/celedituro)
* [Lopez Victoria Abril](https://gitlab.com/vickyylopezz)
* [Pfaab Ivan Lautaro](https://gitlab.com/ipfaab)
* [Villores Alejo](https://gitlab.com/alejovillores)


### Ambientes:
`test`@FiubaMemo2Tp2SaltaTestBot\
`produccion` @FiubaMemo2Tp2SaltaProdBot

1. Registrar un nuevo bot con el BotFather de Telegram

* En Telegram https://web.telegram.org/#/im?p=@BotFather
* Enviarle el comando `/newbot`
* Seguir los pasos y al final el BotFather responde con un token

2. Copiar el archivo `.env.example` a `.env` y reemplazar `<YOUR_TELEGRAM_TOKEN>` con el token del paso anterior

3. Correr los tests con `rake`

4. Levantar la app localmente con `ruby app.rb`


# Testing

Los tests utilizan WebMock. Para testear el cliente, siempre usar `app.run_once` de lo contrario el bot se queda esperando mensajes y el test no finaliza nunca.

# Llamadas a otras API por HTTP

Se puede utilizar la gema incluida en el repo [Faraday](https://github.com/lostisland/faraday#faraday)

# Correr con docker en modo produccion

docker-compose -f docker-compose.prod.yml --env-file ./.env up --build


# Logging

La aplicación utiliza el logger estándar de Ruby.
El log level se especifica en la la configuracion con un número:

* DEBUG = 0
* INFO = 1
* WARN = 2
* ERROR = 3
* FATAL = 4

# Más información

Para utilizar otras funcionalidades de Telegram como los Keyboards especiales ver la doc en: https://github.com/atipugin/telegram-bot-ruby
