# language: es
Característica: Cancelar un pedido
  Como cliente registrado
  Quiero cancelar un pedido

Dado que estoy registrado como el usuario "pepe"
Cuando ingreso "/cancelar 4"
Entonces recibo "Su pedido 4 fue cancelado" como mensaje

Escenario: Cliente cancela un pedido en camino
  Dado que ingreso "/registrar pepe, Cucha Cucha 1234, 5123-1234"
  Y me registro
  Y se muestra el mensaje "Bienvenido pepe!"
  Y selecciono la opción "1 - Menú individual ($100)"
  Y recibo "Su pedido de Menú individual fue recibido con éxito. Su número de pedido es : "4"
  Y ingreso "/consultar 4"
  Y rebico "Su pedido 4 esta en camino"
  Cuando ingreso "/cancelar 4"
  Entonces recibo "No puede cancelar un pedido en camino" como mensaje

Escenario: Cliente cancela un pedido en espera
  Dado que ingreso "/registrar pepe, Cucha Cucha 1234, 5123-1234"
  Y me registro
  Y se muestra el mensaje "Bienvenido pepe!"
  Y selecciono la opción "1 - Menú individual ($100)"
  Y recibo "Su pedido de Menú individual fue recibido con éxito. Su número de pedido es : "4"
  Y ingreso "/consultar 4"
  Y rebico "Su pedido 4 esta en espera"
  Cuando ingreso "/cancelar 4"
  Entonces recibo "No puede cancelar un pedido en espera" como mensaje

Escenario: Cliente cancela un pedido entregado
  Dado que ingreso "/registrar pepe, Cucha Cucha 1234, 5123-1234"
  Y me registro\
  Y se muestra el mensaje "Bienvenido pepe!"
  Y selecciono la opción "1 - Menú individual ($100)"
  Y recibo "Su pedido de Menú individual fue recibido con éxito. Su número de pedido es : "4"
  Y ingreso "/consultar 4"
  Y rebico "Su pedido 4 esta entregado"
  Cuando ingreso "/cancelar 4"
  Entonces recibo "No puede cancelar un pedido entregado" como mensaje