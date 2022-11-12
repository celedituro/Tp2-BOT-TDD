# language: es
Característica: Cancelar un pedido
  Como cliente registrado
  Quiero cancelar un pedido

Dado que estoy registrado como el usuario "pepe"
Cuando ingreso "/cancelar 4"
Entonces recibo "Su pedido 4 fue cancelado" como mensaje