require "#{File.dirname(__FILE__)}/../lib/routing"
require "#{File.dirname(__FILE__)}/../lib/version"
require "#{File.dirname(__FILE__)}/tv/series"

ERRORES = {
  '/unknown' => 'Uh? No te entiendo! Me repetis la pregunta?',
  '/registrar' => 'Error: faltan campos para completar el registro'
}.freeze
POSICION_DEL_MANDO = 0

HTTP_CREADO_CORRECTAMENTE = 201

class Routes
  include Routing

  on_message '/start' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Hola, #{message.from.first_name}")
  end

  on_message_pattern %r{/say_hi (?<name>.*)} do |bot, message, args|
    bot.api.send_message(chat_id: message.chat.id, text: "Hola, #{args['name']}")
  end

  on_message '/stop' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Chau, #{message.from.username}")
  end

  on_message '/time' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "La hora es, #{Time.now}")
  end

  on_message '/tv' do |bot, message|
    kb = Tv::Series.all.map do |tv_serie|
      Telegram::Bot::Types::InlineKeyboardButton.new(text: tv_serie.name, callback_data: tv_serie.id.to_s)
    end
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)

    bot.api.send_message(chat_id: message.chat.id, text: 'Quien se queda con el trono?', reply_markup: markup)
  end

  on_message '/busqueda_centro' do |bot, message|
    kb = [
      Telegram::Bot::Types::KeyboardButton.new(text: 'Compartime tu ubicacion', request_location: true)
    ]
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)
    bot.api.send_message(chat_id: message.chat.id, text: 'Busqueda por ubicacion', reply_markup: markup)
  end

  on_location_response do |bot, message|
    response = "Ubicacion es Lat:#{message.location.latitude} - Long:#{message.location.longitude}"
    puts response
    bot.api.send_message(chat_id: message.chat.id, text: response)
  end

  on_response_to 'Quien se queda con el trono?' do |bot, message|
    response = Tv::Series.handle_response message.data
    bot.api.send_message(chat_id: message.message.chat.id, text: response)
  end

  on_message '/version' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: Version.current)
  end

  on_message '/equipo' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: 'Hola, somos el equipo Salta')
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: ERRORES[message.to_s.split[POSICION_DEL_MANDO]])
  end

  on_message '/version_api' do |bot, message|
    response = Faraday.get('http://webapp:3000/health')
    body_hash = JSON.parse(response.body)

    bot.api.send_message(chat_id: message.chat.id, text: body_hash['version'])
  end

  on_message_pattern %r{/registrar (?<nombre>.*),(?<direccion>.*),(?<telefono>.*)} do |bot, message, args|
    response = Faraday.post('http://webapp:3000/registrar', args.to_json, 'Content-Type' => 'application/json')

    if response.status != HTTP_CREADO_CORRECTAMENTE
      text = 'Error: el telefono ya está en uso'
    else
      body_hash = JSON.parse(response.body)
      nombre = body_hash['nombre']
      text = "Bienvenido #{nombre}!"
    end

    bot.api.send_message(chat_id: message.chat.id, text: text)
  end
end
