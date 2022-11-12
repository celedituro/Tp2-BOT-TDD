require "#{File.dirname(__FILE__)}/../lib/routing"
require "#{File.dirname(__FILE__)}/../lib/version"
require "#{File.dirname(__FILE__)}/tv/series"
require "#{File.dirname(__FILE__)}/tv/pedido"
require "#{File.dirname(__FILE__)}/nonna_api"
require "#{File.dirname(__FILE__)}/errors/nonna_error"

require_relative '../app/presentador_menus.rb'
require_relative '../app/tv/menu.rb'

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
    respuesta = NonnaApi.new.obtener_version

    bot.api.send_message(chat_id: message.chat.id, text: respuesta)
  end

  on_message_pattern %r{/registrar (?<datos>.*)} do |bot, message, args|
    begin
      respuesta = NonnaApi.new.registrar_usuario(message, args)
    rescue StandardError => e
      respuesta = e.message
    end
    bot.api.send_message(chat_id: message.chat.id, text: respuesta)
  end

  on_message '/menus' do |bot, message|
    respuesta = NonnaApi.new.obtener_menus
    bot.api.send_message(chat_id: message.chat.id, text: respuesta)
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

  on_message_pattern %r{/cancelar (?<id_pedido>.*)} do |bot, message, args|
    response = Faraday.patch("#{URL}/cancelacion?id=#{args['id_pedido']}")
    body_hash = JSON.parse(response.body)

    text = Pedido.new.manejar_respuesta(body_hash)
    bot.api.send_message(chat_id: message.chat.id, text: text)
  end
end
