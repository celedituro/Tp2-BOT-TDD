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