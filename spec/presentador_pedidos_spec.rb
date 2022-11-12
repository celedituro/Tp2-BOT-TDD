require_relative '../app/presentador_pedidos.rb'
describe 'PresentadorPedidos' do
  # rubocop:disable Metrics/LineLength
  it 'cuando realizo 3 pedidos debo obtener una lista de 3 pedidos' do
    presentador_pedidos = PresentadorPedidos.new
    pedidos = [{ 'id_pedido' => 1, 'id' => 1, 'nombre' => 'Menu individual', 'precio' => 100, 'estado' => 'entregado' }, { 'id_pedido' => 2, 'id' => 1, 'nombre' => 'Menu individual', 'precio' => 100, 'estado' => 'en preparacion' }, { 'id_pedido' => 4, 'id' => 3, 'nombre' => 'Menu familiar', 'precio' => 250, 'estado' => 'recibido' }]

    expect(presentador_pedidos.presentar_pedidos(pedidos)).to eq "Pedido 1\n\t\tMenu: \n\t\tPrecio: $100\n\t\tEstado: entregado\n\nPedido 2\n\t\tMenu: \n\t\tPrecio: $100\n\t\tEstado: en preparacion\n\nPedido 4\n\t\tMenu: \n\t\tPrecio: $250\n\t\tEstado: recibido\n\n"
  end
  # rubocop:enable Metrics/LineLength
end
