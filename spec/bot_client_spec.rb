require 'spec_helper'
require 'web_mock'
require_relative '../app/presentador_menus.rb'

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
                                [{ "text": 'Jon Snow', "callback_data": '1' }],
                                [{ "text": 'Daenerys Targaryen', "callback_data": '2' }],
                                [{ "text": 'Ned Stark', "callback_data": '3' }]
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

def then_i_get_keyboard_message(token, message_text)
  body = { "ok": true,
           "result": { "message_id": 12,
                       "from": { "id": 715_612_264, "is_bot": true, "first_name": 'fiuba-memo2-prueba', "username": 'fiuba_memo2_bot' },
                       "chat": { "id": 141_733_544, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "type": 'private' },
                       "date": 1_557_782_999, "text": message_text } }

  stub_request(:post, "https://api.telegram.org/bot#{token}/sendMessage")
    .with(
      body: { 'chat_id' => '141733544',
              'reply_markup' => '{"inline_keyboard":[[{"text":"Jon Snow","callback_data":"1"}],[{"text":"Daenerys Targaryen","callback_data":"2"}],[{"text":"Ned Stark","callback_data":"3"}]]}',
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

  it 'should get a /say_hi message and respond with Hola Emilio' do
    token = 'fake_token'

    when_i_send_text(token, '/say_hi Emilio')
    then_i_get_text(token, 'Hola, Emilio')

    app = BotClient.new(token)

    app.run_once
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

  it 'should get a /tv message and respond with an inline keyboard' do
    token = 'fake_token'

    when_i_send_text(token, '/tv')
    then_i_get_keyboard_message(token, 'Quien se queda con el trono?')

    app = BotClient.new(token)

    app.run_once
  end

  it 'should get a "Quien se queda con el trono?" message and respond with' do
    token = 'fake_token'

    when_i_send_keyboard_updates(token, 'Quien se queda con el trono?', 2)
    then_i_get_text(token, 'A mi también me encantan los dragones!')

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
    mock_post_request_api({ "nombre": 'Alejo', "direccion": '9 de Julio 222', "telefono": '5435-4535' }, '/registrar', 201)

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
    mock_post_request_api({ "nombre": 'Alejo', "direccion": '9 de Julio 222', "telefono": '5435-4535' }, '/registrar', 409)

    when_i_send_text(token, '/registrar Alejo, 9 de Julio 222, 5435-4535')
    then_i_get_text(token, 'Error: el telefono ya está en uso')

    BotClient.new(token).run_once
  end

  # rubocop:disable RSpec/ExampleLength
  it 'debo obtener una lista con los menus disponibles al enviar /menus' do
    token = 'fake_token'
    menus = [{ 'id' => 1, 'nombre' => 'Menu individual', 'precio' => 100 }, { 'id' => 2, 'nombre' => 'Menu parejas', 'precio' => 175 }, { 'id' => 3, 'nombre' => 'Menu familiar', 'precio' => 250 }]

    mock_get_request_api({ "menus": menus }, '/menus', 200)

    when_i_send_text(token, '/menus')
    then_i_get_text(token, PresentadorMenus.new.presentar_menus(menus))
    BotClient.new(token).run_once
  end
  # rubocop:enable RSpec/ExampleLength
end
