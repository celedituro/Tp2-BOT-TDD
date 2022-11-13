# language: es
Característica: Consultar el estado de un pedido
  Como cliente registrado
  Quiero consultar el estado de un pedido realizado

Escenario: Cliente consulta un pedido realizado
  Dado que realizo un pedido
  Y éste se encuentra en preparación
  Cuando ingreso "/consultar 3"
  Entonces obtengo el mensaje "Su pedido 3 esta en preparación"

Escenario: Cliente consulta un pedido realizado
  Dado que realizo un pedido 
  Y éste se encuentra en preparación
  Y ingreso "/consultar_pedido 3"
  Y obtengo el mensaje "Su pedido 3 esta en preparación"
  Cuando ingreso "/cancelar 4"
  Y ingreso "/consultar_pedido 4"
  Entonces obtengo el mensaje "Su pedido 4 esta cancelado"