# language: es
Característica: Consultar el estado de un pedido
  Como cliente registrado
  Quiero consultar el estado de un pedido realizado

Escenario: Cliente consulta un pedido realizado
  Dado que realizo un pedido
  Y éste se encuentra en preparación
  Cuando ingreso "/consultar 3"
  Entonces obtengo el mensaje "Su pedido 3 esta en preparación"