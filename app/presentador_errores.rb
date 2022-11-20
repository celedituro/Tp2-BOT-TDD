class PresentadorErrores
  MSG_ERROR_SIN_REGISTRACION = 'No podemos procesar tu consulta, necesitas registrarte primero'.freeze
  MSG_ERROR_FALTAN_CAMPOS = 'Error: faltan campos para completar el registro'.freeze
  MSG_ERROR_USUARIO_YA_REGISTRADO = 'Error: el usuario ya esta registrado'.freeze
  MSG_ERROR_TIPO_PEDIDO = 'Error: solo se pueden calificar pedidos entregados o cancelados'.freeze

  def presentar(error)
    error
  end

  def presentar_sin_registracion
    presentar(MSG_ERROR_SIN_REGISTRACION)
  end

  def presentar_pedido_no_encontrado(id_pedido)
    "No se encuentra el pedido #{id_pedido}"
  end

  def presentar_califacion_tipo_pedido
    presentar(MSG_ERROR_TIPO_PEDIDO)
  end

  def presentar_registracion_id_usuario
    presentar(MSG_ERROR_USUARIO_YA_REGISTRADO)
  end

  def presentar_registracion_campos_faltantes
    presentar(MSG_ERROR_FALTAN_CAMPOS)
  end
end
