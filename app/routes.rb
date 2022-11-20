require "#{File.dirname(__FILE__)}/../lib/routing"
require "#{File.dirname(__FILE__)}/../lib/version"
require "#{File.dirname(__FILE__)}/tv/pedido"
require "#{File.dirname(__FILE__)}/nonna_api"
require "#{File.dirname(__FILE__)}/errors/nonna_error"

require_relative '../app/presentador_menus.rb'
require_relative '../app/presentador_pedidos.rb'
require_relative '../app/presentador_equipo.rb'
require_relative '../app/presentador_errores.rb'
require_relative '../app/tv/menu.rb'

DEFAULT_MESSAGE = 'Uh? No te entiendo! Me repetis la pregunta?'.freeze

class Routes
  include Routing

  on_message '/start' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Hola, #{message.from.first_name}")
  end

  on_message '/stop' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Chau, #{message.from.username}")
  end

  on_message '/version' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: Version.current)
  end

  on_message '/equipo' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: PresentadorEquipo.new.presentar_equipo)
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: DEFAULT_MESSAGE)
  end

  on_message '/version_api' do |bot, message|
    respuesta = NonnaApi.new.obtener_version

    bot.api.send_message(chat_id: message.chat.id, text: respuesta)
  end

  on_message_pattern %r{/registrar (?<datos>.*)} do |bot, message, args|
    begin
      respuesta = NonnaApi.new.registrar_usuario(message, args)
    rescue StandardError => e
      respuesta = PresentadorErrores.new.presentar(e.message)
    end
    bot.api.send_message(chat_id: message.chat.id, text: respuesta)
  end

  on_message '/menus' do |bot, message|
    begin
      menus = NonnaApi.new.obtener_menus(message.chat.id)
      respuesta = PresentadorMenus.new.presentar_menus(menus)
    rescue StandardError => e
      respuesta = PresentadorErrores.new.presentar(e.message)
    end
    bot.api.send_message(chat_id: message.chat.id, text: respuesta)
  end

  on_message '/pedir' do |bot, message|
    begin
      menus = NonnaApi.new.obtener_menus(message.chat.id)

      presentador = PresentadorMenus.new
      kb = menus.map do |menu|
        Telegram::Bot::Types::InlineKeyboardButton.new(text: presentador.generar_menu(menu), callback_data: menu['id'].to_s)
      end
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
      text = PresentadorMenus.new.pregunta_menu
    rescue NonnaError => e
      text = PresentadorErrores.new.presentar(e.message)
      markup = nil
    end

    bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: markup)
  end

  on_response_to 'Que menu desea pedir?' do |bot, message|
    begin
      respuesta = NonnaApi.new.pedir_menu(message)
    rescue StandardError => e
      respuesta = PresentadorErrores.new.presentar(e.message)
    end
    bot.api.send_message(chat_id: message.message.chat.id, text: respuesta)
  end

  on_message_pattern %r{/consultar (?<id_pedido>.*)} do |bot, message, args|
    begin
      pedidos = NonnaApi.new.consultar_pedido(args['id_pedido'])
      respuesta = Pedido.new.manejar_respuesta(pedidos)
    rescue NonnaError => e
      respuesta = PresentadorErrores.new.presentar(e.message)
    end
    bot.api.send_message(chat_id: message.chat.id, text: respuesta)
  end

  on_message_pattern %r{/cancelar (?<id_pedido>.*)} do |bot, message, args|
    pedido_cancelado = NonnaApi.new.cancelar(args['id_pedido'])
    text = Pedido.new.manejar_respuesta(pedido_cancelado)
    bot.api.send_message(chat_id: message.chat.id, text: text)
  end

  on_message '/pedidos' do |bot, message|
    pedidos = NonnaApi.new.pedidos(message)
    if pedidos.empty?
      bot.api.send_message(chat_id: message.chat.id, text: 'Error')
    else
      text = PresentadorPedidos.new.presentar_pedidos(pedidos)
      bot.api.send_message(chat_id: message.chat.id, text: text)
    end
  end

  on_message_pattern %r{/calificar (?<id_pedido>.*),(?<calificacion>.*)} do |bot, message, args|
    begin
      text = NonnaApi.new.calificar_pedido(message, args)
    rescue NonnaError => e
      text = PresentadorErrores.new.presentar(e.message)
    end
    bot.api.send_message(chat_id: message.chat.id, text: text)
  end
end
