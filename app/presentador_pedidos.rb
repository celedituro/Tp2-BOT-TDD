class PresentadorPedidos
  def presentar_pedidos(pedidos)
    pedidos_presentacion = ''
    pedidos.each do |pedido|
      pedidos_presentacion.concat(generar_pedido(pedido))
    end
    pedidos_presentacion
  end

  def generar_pedido(pedido)
    "Pedido #{pedido['id_pedido']}, #{pedido['id']}-#{pedido['nombre']} ($#{pedido['precio']}), estado: #{pedido['estado']}\n "
  end
end
