# language: es
Característica: Consultar pedido realizados
  Como cliente registrado
  Quiero consultar mis pedidos realizados

Escenario: Cliente realizó 3 pedidos y consulta por sus pedidos realizados
  Dado que estoy registrado como el usuario "pepe" y
  Y tengo 3 pedidos realizados
  Cuando ingreso "/pedidos"
  Entonces recibo "Pedido 1, 1-Menú individual ($100) y estado: entregado\n Pedido 2, 1-Menú individual ($100) y estado: en preparacion, Pedido 4, 1-Menú individual ($100) y estado: recibido\n" como mensaje

Escenario: Cliente no realizó pedidos y consulta por sus pedidos realizados
  Dado que ingreso "/registrar pepe, Cucha Cucha 1234, 5123-1234"
  Y tengo 0 pedidos realizados
  Cuando ingreso "/pedidos"
  Entonces recibo "Por el momento no se registró ningún pedido" como mensaje