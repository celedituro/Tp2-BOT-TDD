class Pedido
  def manejar_respuesta(pedido)
    "Su pedido #{pedido['id_pedido']} esta #{pedido['estado']}"
  end
end
