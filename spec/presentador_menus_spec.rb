require_relative '../app/presentador_menus.rb'

describe 'PresentadorMenus' do
  it 'cuando recibo 3 menus debo obtener un string de 3 menus' do
    presentador_menus = PresentadorMenus.new
    menus = [{ 'id' => 1, 'nombre' => 'Menu individual', 'precio' => 100 }, { 'id' => 2, 'nombre' => 'Menu parejas', 'precio' => 175 }, { 'id' => 3, 'nombre' => 'Menu familiar', 'precio' => 250 }]

    expect(presentador_menus.presentar_menus(menus)).to eq "1-Menu individual ($100)\n2-Menu parejas ($175)\n3-Menu familiar ($250)\n"
  end
end
