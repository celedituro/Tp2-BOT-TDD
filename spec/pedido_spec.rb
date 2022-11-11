require_relative '../app/tv/pedido.rb'

describe 'Pedido' do
  it 'cuando recibo un id de pedido y un estado deberia obtener un mensaje con ambos datos' do
    manejador_pedido = Pedido.new
    pedido = { 'id_pedido' => 1, 'estado' => 'en preparacion' }

    expect(manejador_pedido.manejar_respuesta(pedido)).to eq 'Su pedido 1 esta en preparacion'
  end
end
