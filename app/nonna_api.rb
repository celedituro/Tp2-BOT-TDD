require_relative '../app/presentador_menus.rb'

URL = ENV['API_URL'] || 'http://webapp:3000'

HTTP_CONFLICTO = 409
HTTP_PARAMETROS_INCORRECTO = 400
HTTP_NO_AUTORIZADO = 401

class NonnaApi
  def obtener_version
    response = Faraday.get("#{URL}/health")
    body_hash = JSON.parse(response.body)
    body_hash['version']
  end

  def obtener_menus(id)
    response = Faraday.get("#{URL}/menus/#{id}")
    raise NonnaError, 'No podemos procesar tu consulta, necesitas registrarte primero' if response.status == HTTP_NO_AUTORIZADO

    JSON.parse(response.body)
  end

  def validate(datos)
    raise NonnaError, 'Error: faltan campos para completar el registro' if datos.length != 3
  end

  def pedir_menu(mensaje)
    body = { id_usuario: mensaje.message.chat.id.to_s, id_menu: Integer(mensaje.data) }
    response = Faraday.post("#{URL}/pedido", body.to_json, 'Content-Type' => 'application/json')
    text = pedir(response)
    text
  rescue NonnaError => e
    raise NonnaError, e.message
  end

  def registrar_usuario(mensaje, argumentos)
    datos = argumentos['datos'].split(',')
    begin
      validate(datos)
      body = { nombre: datos[0], direccion: datos[1], telefono: datos[2], id: mensaje.chat.id.to_s }
      response = Faraday.post("#{URL}/registrar", body.to_json, 'Content-Type' => 'application/json')
      text = registrar(response)
      return text
    rescue NonnaError => e
      raise NonnaError, e.message
    end
  end

  def consultar_pedido(id_pedido)
    response = Faraday.get("#{URL}/pedido/#{id_pedido}")
    JSON.parse(response.body)
  end

  def cancelar(id_pedido)
    response = Faraday.patch("#{URL}/cancelacion?id=#{id_pedido}")
    JSON.parse(response.body)
  end

  def pedidos(mensaje)
    id_usuario = mensaje.chat.id
    response = Faraday.get("#{URL}/pedidos/#{id_usuario}")
    JSON.parse(response.body)
  end

  def calificar_pedido(mensaje, argumentos)
    body = { id_usuario: mensaje.chat.id, id_pedido: argumentos['id_pedido'], calificacion: argumentos['calificacion'] }
    response = Faraday.patch("#{URL}/calificacion", body.to_json, 'Content-Type' => 'application/json')
    calificar(response)
  rescue NonnaError => e
    raise NonnaError, e.message
  end

  private

  def calificar(response)
    case response.status
    when HTTP_NO_AUTORIZADO
      raise NonnaError, 'Error: solo se pueden calificar pedidos entregados o cancelados'
    else
      body_hash = JSON.parse(response.body)
      "Su pedido #{body_hash['id_pedido']} fue calificado!"
    end
  end

  def registrar(response)
    case response.status
    when HTTP_CONFLICTO
      raise NonnaError, 'Error: el telefono ya está en uso'
    when HTTP_PARAMETROS_INCORRECTO
      raise NonnaError, 'Error: faltan campos para completar el registro'
    else
      body_hash = JSON.parse(response.body)
      nombre = body_hash['nombre']
      "Bienvenido #{nombre}!"
    end
  end

  def pedir(response)
    case response.status
    when HTTP_NO_AUTORIZADO
      raise NonnaError, 'No podemos procesar tu consulta, necesitas registrarte primero'
    else
      body_hash = JSON.parse(response.body)
      Menu.new.manejar_respuesta(body_hash['nombre_menu'], body_hash['id_pedido'])
    end
  end
end
