require_relative '../app/presentador_menus.rb'

URL = ENV['API_URL'] || 'http://webapp:3000'

HTTP_CONFLICTO = 409
HTTP_PARAMETROS_INCORRECTO = 400

class NonnaApi
  def obtener_version
    response = Faraday.get("#{URL}/health")
    body_hash = JSON.parse(response.body)
    body_hash['version']
  end

  def obtener_menus
    response = Faraday.get("#{URL}/menus")
    PresentadorMenus.new.presentar_menus(JSON.parse(response.body))
  end

  def validate(datos)
    raise NonnaError, 'Error: faltan campos para completar el registro' if datos.length != 3
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
end
