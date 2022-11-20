require_relative '../app/presentador_menus.rb'
require_relative '../app/presentador_errores.rb'

URL = ENV['API_URL'] || 'http://webapp:3000'

HTTP_CONFLICTO = 409
HTTP_PARAMETROS_INCORRECTO = 400
HTTP_NO_AUTORIZADO = 401
HTTP_NO_ENCONTRADO = 404

class NonnaApi
  def obtener_version
    response = Faraday.get("#{URL}/health")
    body_hash = JSON.parse(response.body)
    body_hash['version']
  end

  def obtener_menus(id)
    response = Faraday.get("#{URL}/menus/#{id}")
    raise NonnaError, PresentadorErrores.new.presentar_sin_registracion if response.status == HTTP_NO_AUTORIZADO

    JSON.parse(response.body)
  end

  def validate(datos)
    raise NonnaError, PresentadorErrores.new.presentar_registracion_campos_faltantes if datos.length != 3
  end

  def pedir_menu(mensaje)
    body = { id_usuario: mensaje.message.chat.id.to_s, id_menu: Integer(mensaje.data) }
    response = Faraday.post("#{URL}/pedido", body.to_json, 'Content-Type' => 'application/json')
    text = pedir(response)
    text
  rescue NonnaError => e
    raise NonnaError, PresentadorErrores.new.presentar(e.message)
  end

  def registrar_usuario(mensaje, argumentos)
    datos = argumentos['datos'].split(',')
    begin
      validate(datos)
      body = { nombre: datos[0], direccion: datos[1], telefono: datos[2], id: mensaje.chat.id.to_s }
      response = Faraday.post("#{URL}/registrar", body.to_json, 'Content-Type' => 'application/json')
      text = registrar(response)
      text
    rescue NonnaError => e
      raise NonnaError, PresentadorErrores.new.presentar(e.message)
    end
  end

  def consultar_pedido(id_pedido)
    response = Faraday.get("#{URL}/pedido/#{id_pedido}")
    raise NonnaError, PresentadorErrores.new.presentar_pedido_no_encontrado(id_pedido) if response.status == HTTP_NO_ENCONTRADO

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
    raise NonnaError, PresentadorErrores.new.presentar(e.message)
  end

  private

  def calificar(response)
    case response.status
    when HTTP_NO_AUTORIZADO
      raise NonnaError, PresentadorErrores.new.presentar_califacion_tipo_pedido
    else
      body_hash = JSON.parse(response.body)
      PresentadorPedidos.new.presentar_pedido_exitoso(body_hash['id_pedido'])
    end
  end

  def registrar(response)
    case response.status
    when HTTP_CONFLICTO
      raise NonnaError, PresentadorErrores.new.presentar_registracion_telefono
    when HTTP_PARAMETROS_INCORRECTO
      raise NonnaError, PresentadorErrores.new.presentar_registracion_campos_faltantes
    else
      body_hash = JSON.parse(response.body)
      nombre = body_hash['nombre']
      PresentadorEquipo.new.presentar_bienvenida(nombre)
    end
  end

  def pedir(response)
    case response.status
    when HTTP_NO_AUTORIZADO
      raise NonnaError, PresentadorErrores.new.presentar_registracion_campos_faltantes
    else
      body_hash = JSON.parse(response.body)
      Menu.new.manejar_respuesta(body_hash['nombre_menu'], body_hash['id_pedido'])
    end
  end
end
