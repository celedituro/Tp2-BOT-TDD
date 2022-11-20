# language: es

Característica: Calificar repartidores
    Como cliente registrado
    Quiero calificar al repartidor de mi pedido

Escenario: Cliente califica al repartidor de un pedido entregado
    Dado que estoy registrado como "pepe"
    Y tengo un pedido numero 123 entregado
    Y que recibí mi pedido
    Cuando ingreso "/calificar 123, 3"
    Entonces recibo "Su pedido 123 fue calificado!"

Escenario: Cliente califica al repartidor de un pedido recibido
    Dado que ingreso "/registrar pepe, Cucha Cucha 1234, 5123-1234"
    Y me registro
    Y se muestra el mensaje "Bienvenido pepe!"
    Y selecciono la opción "1 - Menú individual ($100)"
    Y recibo "Su pedido de Menú individual fue recibido con éxito. Su número de pedido es : "4"
    Y ingreso "/consultar 4"
    Y recibo "Su pedido 4 esta recibido"
    Cuando ingreso "/calificar 4,3"
    Entonces recibo "No puede calificar un pedido recibido"

Escenario: Cliente califica al repartidor de un pedido en preparacion
    Dado que ingreso "/registrar pepe, Cucha Cucha 1234, 5123-1234"
    Y me registro
    Y se muestra el mensaje "Bienvenido pepe!"
    Y selecciono la opción "1 - Menú individual ($100)"
    Y recibo "Su pedido de Menú individual fue recibido con éxito. Su número de pedido es : "4"
    Y ingreso "/consultar 4"
    Y recibo "Su pedido 4 esta en preparacion"
    Cuando ingreso "/calificar 4,3"
    Entonces recibo "No puede calificar un pedido en preparacion"

Escenario: Cliente califica al repartidor de un pedido en camino
    Dado que ingreso "/registrar pepe, Cucha Cucha 1234, 5123-1234"
    Y me registro
    Y se muestra el mensaje "Bienvenido pepe!"
    Y selecciono la opción "1 - Menú individual ($100)"
    Y recibo "Su pedido de Menú individual fue recibido con éxito. Su número de pedido es : "4"
    Y ingreso "/consultar 4"
    Y recibo "Su pedido 4 esta en camino"
    Cuando ingreso "/calificar 4,3"
    Entonces recibo "No puede calificar un pedido en camino"

Escenario: Cliente califica al repartidor con campos faltantes
    Dado que ingreso "/registrar pepe, Cucha Cucha 1234, 5123-1234"
    Y me registro
    Y se muestra el mensaje "Bienvenido pepe!"
    Y selecciono la opción "1 - Menú individual ($100)"
    Y recibo "Su pedido de Menú individual fue recibido con éxito. Su número de pedido es : "4"
    Y ingreso "/consultar 4"
    Y recibo "Su pedido 4 esta entregado"
    Cuando ingreso "/calificar 4"
    Entonces recibo "Error: faltan campos para completar la calificacion"

Escenario: Cliente califica al repartidor con campos faltantes
    Dado que ingreso "/registrar pepe, Cucha Cucha 1234, 5123-1234"
    Y me registro
    Y se muestra el mensaje "Bienvenido pepe!"
    Y selecciono la opción "1 - Menú individual ($100)"
    Y recibo "Su pedido de Menú individual fue recibido con éxito. Su número de pedido es : "4"
    Y ingreso "/consultar 4"
    Y recibo "Su pedido 4 esta entregado"
    Cuando ingreso "/calificar 4,10"
    Entonces recibo "Error: la calificacion debe ser de 1 a 5"