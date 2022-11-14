# language: es
Característica: Consultar por los menús disponibles
    Para hacer un pedido
    Como cliente
    Puedo consultar por los menús disponibles

Escenario: Cliente registrado consulta por los menús disponibles
    Dado que estoy registrado como el usuario "pepe"
    Cuando ingreso "/menus"
    Entonces recibo "1-Menú individual ($100), 2-Menú parejas ($175), 3-Menú familiar ($250)" como mensaje

Escenario: Cliente no registrado consulta por los menús disponibles
    Dado que no estoy registrado
    Cuando ingreso "/menus"
    Entonces obtengo un mensaje que dice “No podemos procesar tu consulta, necesitas registrarte primero”