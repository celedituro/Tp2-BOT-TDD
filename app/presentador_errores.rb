class PresentadorErrores
  MSG_ERROR_SIN_REGISTRACION = 'No podemos procesar tu consulta, necesitas registrarte primero'.freeze
  MSG_ERROR_FALTAN_CAMPOS = 'Error: faltan campos para completar el registro'.freeze
  MSG_ERROR_TELEFONO_YA_USADO = 'Error: el telefono ya está en uso'.freeze
  MSG_ERROR_TIPO_PEDIDO = 'Error: solo se pueden calificar pedidos entregados o cancelados'.freeze
  MSG_ERROR_FALTAN_CAMPOS_CALIFICACION = 'Error: faltan campos para completar la calificacion'.freeze
  MSG_ERROR_CALIFICACION_RANGO_INCORRECTO = 'Error: la calificacion tiene que ser entre 1 y 5'.freeze

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

  def presentar_registracion_telefono
    presentar(MSG_ERROR_TELEFONO_YA_USADO)
  end

  def presentar_registracion_campos_faltantes
    presentar(MSG_ERROR_FALTAN_CAMPOS)
  end

  def presentar_calificacion_campos_faltantes
    presentar(MSG_ERROR_FALTAN_CAMPOS_CALIFICACION)
  end

  def presentar_calificacion_rango_incorrecto
    presentar(MSG_ERROR_CALIFICACION_RANGO_INCORRECTO)
  end
end
