URL = ENV['API_URL'] || 'http://webapp:3000'

HTTP_CONFLICTO = 409
HTTP_PARAMETROS_INCORRECTO = 400

class NonnaApi
  def obtener_version
    response = Faraday.get("#{URL}/health")
    body_hash = JSON.parse(response.body)
    body_hash['version']
  end

  # rubocop:disable Metrics/AbcSize
  def registrar_usuario(mensaje, argumentos)
    datos = argumentos['datos'].split(',')
    if datos.length != 3
      text = 'Error: faltan campos para completar el registro'
    else
      body = { nombre: datos[0], direccion: datos[1], telefono: datos[2], id: mensaje.chat.id.to_s }
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

    text
  end
  # rubocop:enable Metrics/AbcSize
end
