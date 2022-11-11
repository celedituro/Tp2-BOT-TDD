require "#{File.dirname(__FILE__)}/../lib/routing"
require "#{File.dirname(__FILE__)}/../lib/version"
require "#{File.dirname(__FILE__)}/tv/series"
require "#{File.dirname(__FILE__)}/tv/pedido"

require_relative '../app/presentador_menus.rb'
require_relative '../app/tv/menu.rb'

POSICION_DEL_COMANDO = 0

HTTP_CONFLICTO = 409
HTTP_PARAMETROS_INCORRECTO = 400
HTTP_NO_AUTORIZADO = 401
URL = ENV['API_URL'] || 'http://webapp:3000'

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
    bot.api.send_message(chat_id: message.chat.id, text: 'Uh? No te entiendo! Me repetis la pregunta?')
  end

  on_message '/version_api' do |bot, message|
    response = Faraday.get("#{URL}/health")
    body_hash = JSON.parse(response.body)

    bot.api.send_message(chat_id: message.chat.id, text: body_hash['version'])
  end

  on_message_pattern %r{/registrar (?<datos>.*)} do |bot, message, args|
    datos = args['datos'].split(',')
    if datos.length != 3
      text = 'Error: faltan campos para completar el registro'
    else
      body = { nombre: datos[0], direccion: datos[1], telefono: datos[2], id: message.chat.id.to_s }
      response = Faraday.post("#{URL}/registrar", body.to_json, 'Content-Type' => 'application/json')

      case response.status
      when HTTP_CONFLICTO
        text = 'Error: el telefono ya está en uso'
      when HTTP_PARAMETROS_INCORRECTO
        text = 'Error: faltan campos para completar el registro'
      else
        body_hash = JSON.parse(response.body)
        nombre = body_hash['nombre']
        text = "Bienvenido #{nombre}!"
      end
    end
    bot.api.send_message(chat_id: message.chat.id, text: text)
  end

  on_message '/menus' do |bot, message|
    response = Faraday.get("#{URL}/menus")
    body_hash = JSON.parse(response.body)

    bot.api.send_message(chat_id: message.chat.id, text: PresentadorMenus.new.presentar_menus(body_hash))
  end

  on_message '/pedir' do |bot, message|
    response = Faraday.get("#{URL}/menus")
    body_hash = JSON.parse(response.body)

    presentador = PresentadorMenus.new
    kb = body_hash.map do |menu|
      Telegram::Bot::Types::InlineKeyboardButton.new(text: presentador.generar_menu(menu), callback_data: menu['id'].to_s)
    end
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)

    bot.api.send_message(chat_id: message.chat.id, text: 'Que menu desea pedir?', reply_markup: markup)
  end

  on_response_to 'Que menu desea pedir?' do |bot, message|
    body = { id_usuario: message.message.chat.id.to_s, id_menu: Integer(message.data) }

    response = Faraday.post("#{URL}/pedido", body.to_json, 'Content-Type' => 'application/json')
    case response.status
    when HTTP_NO_AUTORIZADO
      text = 'No podemos procesar tu consulta, necesitas registrarte primero'
    else
      body_hash = JSON.parse(response.body)
      text = Menu.new.manejar_respuesta(body_hash['nombre_menu'], body_hash['id_pedido'])
    end

    bot.api.send_message(chat_id: message.message.chat.id, text: text)
  end

  on_message_pattern %r{/consultar (?<id_pedido>.*)} do |bot, message, args|
    response = Faraday.get("#{URL}/pedido/#{args['id_pedido']}")
    body_hash = JSON.parse(response.body)

    text = Pedido.new.manejar_respuesta(body_hash)
    bot.api.send_message(chat_id: message.chat.id, text: text)
  end
end
