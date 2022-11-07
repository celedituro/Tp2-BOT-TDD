class PresentadorMenus
  def presentar_menus(menus)
    menu_presentacion = ''
    menus.each do |menu|
      menu_presentacion.concat(generar_menu(menu))
    end
    menu_presentacion
  end

  protected

  def generar_menu(menu)
    "#{menu['id']}-#{menu['nombre']} ($#{menu['precio']})\n"
  end
end
