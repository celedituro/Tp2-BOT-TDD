require 'spec_helper'
require 'web_mock'
require_relative '../app/presentadores/presentador_menus.rb'

# Uncomment to use VCR
# require 'vcr_helper'

require "#{File.dirname(__FILE__)}/../app/bot_client"
URL = 'http://webapp:3000'.freeze
def when_i_send_text(token, message_text)
  body = { "ok": true, "result": [{ "update_id": 693_981_718,
                                    "message": { "message_id": 11,
                                                 "from": { "id": 141_733_544, "is_bot": false, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "language_code": 'en' },
                                                 "chat": { "id": 141_733_544, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "type": 'private' },
                                                 "date": 1_557_782_998, "text": message_text,
                                                 "entities": [{ "offset": 0, "length": 6, "type": 'bot_command' }] } }] }

  stub_request(:any, "https://api.telegram.org/bot#{token}/getUpdates")
    .to_return(body: body.to_json, status: 200, headers: { 'Content-Length' => 3 })
end

def when_i_send_keyboard_updates(token, message_text, inline_selection)
  body = {
    "ok": true, "result": [{
      "update_id": 866_033_907,
      "callback_query": { "id": '608740940475689651', "from": { "id": 141_733_544, "is_bot": false, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "language_code": 'en' },
                          "message": {
                            "message_id": 626,
                            "from": { "id": 715_612_264, "is_bot": true, "first_name": 'fiuba-memo2-prueba', "username": 'fiuba_memo2_bot' },
                            "chat": { "id": 141_733_544, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "type": 'private' },
                            "date": 1_595_282_006,
                            "text": message_text,
                            "reply_markup": {
                              "inline_keyboard": [
                                [{ "text": '1-Menu individual ($100)', "callback_data": '1' }],
                                [{ "text": '2-Menu parejas ($175)\n', "callback_data": '2' }],
                                [{ "text": '3-Menu familiar ($250)\n', "callback_data": '3' }]
                              ]
                            }
                          },
                          "chat_instance": '2671782303129352872',
                          "data": inline_selection }
    }]
  }

  stub_request(:any, "https://api.telegram.org/bot#{token}/getUpdates")
    .to_return(body: body.to_json, status: 200, headers: { 'Content-Length' => 3 })
end

def then_i_get_text(token, message_text)
  body = { "ok": true,
           "result": { "message_id": 12,
                       "from": { "id": 715_612_264, "is_bot": true, "first_name": 'fiuba-memo2-prueba', "username": 'fiuba_memo2_bot' },
                       "chat": { "id": 141_733_544, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "type": 'private' },
                       "date": 1_557_782_999, "text": message_text } }

  stub_request(:post, "https://api.telegram.org/bot#{token}/sendMessage")
    .with(
      body: { 'chat_id' => '141733544', 'text' => message_text }
    )
    .to_return(status: 200, body: body.to_json, headers: {})
end

def then_i_get_keyboard_message(token, message_text, markup)
  body = { "ok": true,
           "result": { "message_id": 12,
                       "from": { "id": 715_612_264, "is_bot": true, "first_name": 'fiuba-memo2-prueba', "username": 'fiuba_memo2_bot' },
                       "chat": { "id": 141_733_544, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "type": 'private' },
                       "date": 1_557_782_999, "text": message_text } }

  stub_request(:post, "https://api.telegram.org/bot#{token}/sendMessage")
    .with(
      body: { 'chat_id' => '141733544',
              'reply_markup' => markup,
              'text' => message_text }
    )
    .to_return(status: 200, body: body.to_json, headers: {})
end

def mock_get_request_api(body, path, status)
  stub_request(:get, URL + path)
    .with(
      headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Faraday v0.15.4' }
    )
    .to_return(status: status, body: body.to_json, headers: {})
end

def mock_patch_request_api(body, path, status)
  stub_request(:patch, URL + path)
    .with(
      headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Faraday v0.15.4' }
    )
    .to_return(status: status, body: body.to_json, headers: {})
end

def mock_post_request_api(body, path, status)
  stub_request(:post, URL + path)
    .with(
      headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Faraday v0.15.4' }
    )
    .to_return(status: status, body: body.to_json, headers: {})
end

describe 'BotClient' do
  it 'should get a /version message and respond with current version' do
    token = 'fake_token'

    when_i_send_text(token, '/version')
    then_i_get_text(token, Version.current)

    app = BotClient.new(token)

    app.run_once
  end

  it 'should get a /version_api message and respond with current version api' do
    token = 'fake_token'
    mock_get_request_api({ "status": 'ok', "version": '0.0.36' }, '/health', 200)

    when_i_send_text(token, '/version_api')
    then_i_get_text(token, '0.0.36')

    BotClient.new(token).run_once
  end

  it 'should get a /start message and respond with Hola' do
    token = 'fake_token'

    when_i_send_text(token, '/start')
    then_i_get_text(token, 'Hola, Emilio')

    app = BotClient.new(token)

    app.run_once
  end

  it 'should get a /stop message and respond with Chau' do
    token = 'fake_token'

    when_i_send_text(token, '/stop')
    then_i_get_text(token, 'Chau, egutter')

    app = BotClient.new(token)

    app.run_once
  end

  it 'should get an unknown message message and respond with Do not understand' do
    token = 'fake_token'

    when_i_send_text(token, '/unknown')
    then_i_get_text(token, 'Uh? No te entiendo! Me repetis la pregunta?')

    app = BotClient.new(token)

    app.run_once
  end

  it 'should get a /equipo message and respond with team name and team members' do
    token = 'fake_token'

    when_i_send_text(token, '/equipo')
    then_i_get_text(token, 'Hola, somos el equipo Salta')

    app = BotClient.new(token)

    app.run_once
  end

  it 'debo obtener Bienvenido Juan! al enviar /registrar Juan, Cucha Cucha 1234, 5435-4535' do
    token = 'fake_token'
    mock_post_request_api({ "nombre": 'Juan', "direccion": 'Cucha Cucha 1234', "telefono": '5435-4535' }, '/registrar', 201)
    when_i_send_text(token, '/registrar Juan, Cucha Cucha 1234, 5435-4535')
    then_i_get_text(token, 'Bienvenido Juan!')

    BotClient.new(token).run_once
  end

  it 'debo obtener Bienvenido Alejo! al enviar /registrar Alejo, 9 de Julio 222, 5435-4535' do
    token = 'fake_token'
    mock_post_request_api({ "nombre": 'Alejo', "direccion": '9 de Julio 222', "telefono": '5435-4535', "id": 123 }, '/registrar', 201)

    when_i_send_text(token, '/registrar Alejo, 9 de Julio 222, 5435-4535')
    then_i_get_text(token, 'Bienvenido Alejo!')

    BotClient.new(token).run_once
  end

  it 'debo obtener un mensaje de error al enviar /registrar con un campo faltante' do
    token = 'fake_token'
    when_i_send_text(token, '/registrar Alejo, 5435-4535')
    then_i_get_text(token, 'Error: faltan campos para completar el registro')

    BotClient.new(token).run_once
  end

  it 'debo obtener un mensaje de error al enviar /registrar con un telefono repetido' do
    token = 'fake_token'
    mock_post_request_api({ "nombre": 'Alejo', "direccion": '9 de Julio 222', "telefono": '5435-4535', "id": 123 }, '/registrar', 409)

    when_i_send_text(token, '/registrar Alejo, 9 de Julio 222, 5435-4535')
    then_i_get_text(token, 'Error: el usuario ya esta registrado')

    BotClient.new(token).run_once
  end

  it 'debo obtener un mensaje de error al enviar /menus con un id no registrado' do
    token = 'fake_token'

    mock_get_request_api([], '/menus/141733544', 401)

    when_i_send_text(token, '/menus')
    then_i_get_text(token, 'No podemos procesar tu consulta, necesitas registrarte primero')
    BotClient.new(token).run_once
  end

  it 'debo obtener una lista con los menus disponibles al enviar /menus' do
    token = 'fake_token'
    menus = [{ 'id' => 1, 'nombre' => 'Menu individual', 'precio' => 100 }, { 'id' => 2, 'nombre' => 'Menu parejas', 'precio' => 175 }, { 'id' => 3, 'nombre' => 'Menu familiar', 'precio' => 250 }]

    mock_get_request_api(menus, '/menus/141733544', 200)

    when_i_send_text(token, '/menus')
    then_i_get_text(token, PresentadorMenus.new.presentar_menus(menus))
    BotClient.new(token).run_once
  end

  it 'al enviar /pedir debo obtener las opciones de menus disponibles' do
    token = 'fake_token'
    menus = [{ 'id' => 1, 'nombre' => 'Menu individual', 'precio' => 100 }, { 'id' => 2, 'nombre' => 'Menu parejas', 'precio' => 175 }, { 'id' => 3, 'nombre' => 'Menu familiar', 'precio' => 250 }]
    mock_get_request_api(menus, '/menus/141733544', 200)

    markup = '[{"text":"1-Menu individual ($100)\n","callback_data":"1"}],[{"text":"2-Menu parejas ($175)\n","callback_data":"2"}],[{"text":"3-Menu familiar ($250)\n","callback_data":"3"}]'

    when_i_send_text(token, '/pedir')

    then_i_get_keyboard_message(token, 'Que menu desea pedir?', "{\"inline_keyboard\":[#{markup}]}")

    app = BotClient.new(token)

    app.run_once
  end

  it 'debo obtener un mensaje de error al enviar /pedir con un id usuario no registrado' do
    token = 'fake_token'

    mock_get_request_api([], '/menus/141733544', 401)
    when_i_send_text(token, '/pedir')
    then_i_get_keyboard_message(token, 'No podemos procesar tu consulta, necesitas registrarte primero', nil)
    BotClient.new(token).run_once
  end

  it 'should get a "Que menu desea pedir?" message and respond with' do
    token = 'fake_token'

    mock_post_request_api({ "nombre_menu": 'Menu individual', "id_pedido": 4 }, '/pedidos', 201)

    when_i_send_keyboard_updates(token, 'Que menu desea pedir?', 1)
    then_i_get_text(token, 'Su pedido de Menu individual fue recibido con éxito. Su número de pedido es : 4')

    app = BotClient.new(token)

    app.run_once
  end

  it 'debo obtener el estado de mi pedido al enviar /consultar 3' do
    token = 'fake_token'
    pedido = { 'id_pedido' => 3, 'estado' => 'recibido' }

    mock_get_request_api(pedido, "/pedidos/#{pedido['id_pedido']}", 200)

    when_i_send_text(token, '/consultar 3')
    then_i_get_text(token, Pedido.new.manejar_respuesta(pedido))
    BotClient.new(token).run_once
  end

  it 'debo obtener No se encuentra el pedido 3 al enviar /consultar 3' do
    token = 'fake_token'

    mock_get_request_api({ 'message' => 'Not found' }, '/pedidos/3', 404)

    when_i_send_text(token, '/consultar 3')
    then_i_get_text(token, 'No se encuentra el pedido 3')
    BotClient.new(token).run_once
  end

  it 'debo obtener un cambio de estado en mi pedido cuando realizo un pedido y luego lo cancelo' do
    token = 'fake_token'
    pedido_recibido = { 'id_pedido' => 3, 'estado' => 'recibido' }
    pedido_cancelado = { 'id_pedido' => 3, 'estado' => 'cancelado' }

    mock_get_request_api(pedido_recibido, "/pedidos/#{pedido_recibido['id_pedido']}", 200)

    when_i_send_text(token, '/consultar 3')
    then_i_get_text(token, Pedido.new.manejar_respuesta(pedido_recibido))

    mock_patch_request_api(pedido_cancelado, "/cancelaciones?id=#{pedido_cancelado['id_pedido']}", 202)

    when_i_send_text(token, '/cancelar 3')
    then_i_get_text(token, Pedido.new.manejar_respuesta(pedido_cancelado))

    mock_get_request_api(pedido_cancelado, "/pedidos/#{pedido_cancelado['id_pedido']}", 200)

    when_i_send_text(token, '/consultar 3')
    then_i_get_text(token, Pedido.new.manejar_respuesta(pedido_cancelado))

    BotClient.new(token).run_once
  end

  it 'debo obtener el estado cancelado de mi pedido al enviar /cancelar 4' do
    token = 'fake_token'
    pedido = { 'id_pedido' => 4, 'estado' => 'cancelado' }

    mock_patch_request_api(pedido, "/cancelaciones?id=#{pedido['id_pedido']}", 202)

    when_i_send_text(token, '/cancelar 4')
    then_i_get_text(token, Pedido.new.manejar_respuesta(pedido))
    BotClient.new(token).run_once
  end

  it 'debo obtener "Error: un pedido solo se puede cancelar en estado recibido o en preparación" al enviar /cancelar 4' do
    token = 'fake_token'

    mock_patch_request_api([], '/cancelaciones?id=4', 401)

    when_i_send_text(token, '/cancelar 4')
    then_i_get_text(token, PresentadorErrores.new.presentar_cancelacion_estado_incorrecto)
    BotClient.new(token).run_once
  end

  # rubocop:disable Metrics/LineLength
  it 'debo obtener mis pedidos al enviar /pedidos' do
    token = 'fake_token'
    pedidos = [{ 'id_pedido' => 1, 'id' => 1, 'nombre' => 'Menu individual', 'precio' => 100, 'estado' => 'entregado' }, { 'id_pedido' => 2, 'id' => 1, 'nombre' => 'Menu individual', 'precio' => 100, 'estado' => 'en preparacion' }, { 'id_pedido' => 4, 'id' => 3, 'nombre' => 'Menu familiar', 'precio' => 250, 'estado' => 'recibido' }]
    mock_get_request_api(pedidos, '/todos/141733544', 200)

    when_i_send_text(token, '/pedidos')
    then_i_get_text(token, PresentadorPedidos.new.presentar_pedidos(pedidos))
    BotClient.new(token).run_once
  end

  it 'debo obtener "Por el momento no se registró ningún pedido" al enviar /pedidos y no hice ningun pedido' do
    token = 'fake_token'
    pedidos = []
    mock_get_request_api(pedidos, '/todos/141733544', 200)

    when_i_send_text(token, '/pedidos')
    then_i_get_text(token, PresentadorPedidos.new.presentar_pedidos(pedidos))
    BotClient.new(token).run_once
  end
  # rubocop:enable Metrics/LineLength

  it 'debo obtener "Su pedido 123 fue calificado!" al enviar /calificar 123,4' do
    token = 'fake_token'
    mock_patch_request_api({ 'id_usuario' => 15, 'id_pedido' => 123, 'calificacion' => 4 }, '/calificaciones', 200)

    when_i_send_text(token, '/calificar 123,4')
    then_i_get_text(token, 'Su pedido 123 fue calificado!')
    BotClient.new(token).run_once
  end

  it 'debo obtener "Error: solo se pueden calificar pedidos entregados o cancelados" al enviar /calificar 123,4' do
    token = 'fake_token'
    mock_patch_request_api({ 'message' => 'Unauthorized' }, '/calificaciones', 401)

    when_i_send_text(token, '/calificar 123,4')
    then_i_get_text(token, 'Error: solo se pueden calificar pedidos entregados o cancelados')
    BotClient.new(token).run_once
  end

  it 'debo obtener "Error: faltan campos para completar la calificacion" al enviar /calificar 123' do
    token = 'fake_token'
    mock_patch_request_api({ 'message' => 'Unauthorized' }, '/calificaciones', 401)

    when_i_send_text(token, '/calificar 123')
    then_i_get_text(token, 'Error: faltan campos para completar la calificacion')

    BotClient.new(token).run_once
  end
end
