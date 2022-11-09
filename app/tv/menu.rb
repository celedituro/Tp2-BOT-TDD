class Menu
  attr_reader :id, :name

  def manejar_respuesta(nombre_menu, id_pedido)
    "Su pedido de #{nombre_menu} fue recibido con éxito. Su número de pedido es : #{id_pedido}"
  end
end
