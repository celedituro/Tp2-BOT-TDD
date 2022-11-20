class PresentadorPedidos
  def presentar_pedidos(pedidos)
    pedidos_presentacion = ''
    pedidos.each do |pedido|
      pedidos_presentacion.concat(generar_pedido(pedido))
    end
    pedidos_presentacion
  end

  def generar_pedido(pedido)
    "Pedido #{pedido['id_pedido']}\n\t\tMenu: #{pedido['nombre_menu']}\n\t\tPrecio: $#{pedido['precio']}\n\t\tEstado: #{pedido['estado']}\n\n"
  end

  def presentar_pedido_exitoso(id_pedido)
    "Su pedido #{id_pedido} fue calificado!"
  end
end
