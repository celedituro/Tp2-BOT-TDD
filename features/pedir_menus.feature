# language: es

Característica: Realizar un pedido
Como cliente
Quiero realizar un pedido

  Escenario: Cliente registrado pide un menú disponible
    Dado que estoy registrado como el usuario "pepe"
    Cuando ingreso "/pedir"
    Y selecciono la opción "1 - Menú individual ($100)"
    Entonces recibo "Su pedido de Menú individual fue recibido con éxito. Su número de pedido es : "2"