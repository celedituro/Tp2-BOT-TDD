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
    menus = NonnaApi.new.obtener_menus
    respuesta = PresentadorMenus.new.presentar_menus(menus)
    bot.api.send_message(chat_id: message.chat.id, text: respuesta)
  end

  on_message '/pedir' do |bot, message|
    menus = NonnaApi.new.obtener_menus

    presentador = PresentadorMenus.new
    kb = menus.map do |menu|
      Telegram::Bot::Types::InlineKeyboardButton.new(text: presentador.generar_menu(menu), callback_data: menu['id'].to_s)
    end
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)

    bot.api.send_message(chat_id: message.chat.id, text: 'Que menu desea pedir?', reply_markup: markup)
  end

  on_response_to 'Que menu desea pedir?' do |bot, message|
    respuesta = NonnaApi.new.pedir_menu(message)

    bot.api.send_message(chat_id: message.message.chat.id, text: respuesta)
  end

  on_message_pattern %r{/consultar (?<id_pedido>.*)} do |bot, message, args|
    pedidos = NonnaApi.new.consultar_pedido(args['id_pedido'])
    respuesta = Pedido.new.manejar_respuesta(pedidos)
    bot.api.send_message(chat_id: message.chat.id, text: respuesta)
  end

  on_message_pattern %r{/cancelar (?<id_pedido>.*)} do |bot, message, args|
    pedido_cancelado = NonnaApi.new.cancelar(args['id_pedido'])
    text = Pedido.new.manejar_respuesta(pedido_cancelado)
    bot.api.send_message(chat_id: message.chat.id, text: text)
  end

  on_message '/pedidos' do |bot, message|
    pedidos = NonnaApi.new.pedidos(message)
    text = PresentadorPedidos.new.presentar_pedidos(pedidos)
    bot.api.send_message(chat_id: message.chat.id, text: text)
  end
end
