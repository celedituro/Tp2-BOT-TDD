# language: es
Característica: Registración del cliente
Para hacer un pedido
Como cliente
Quiero crear una cuenta para poder loguearme

Escenario: Registración exitosa
    Dado que ingreso "/registrar Juan, Cucha Cucha 1234, 5123-1234"
    Cuando me registro
    Entonces se muestra el mensaje "Bienvenido Juan!"

Escenario: Registración con campos faltantes
    Dado que ingreso "/registrar Juan, 5123-1234"
    Cuando intento registrarme
    Entonces la cuenta no se crea
    Y se muestra el mensaje "Error: faltan campos para completar el registro"

Escenario: Registración con teléfono existente
    Dado que existe un usuario con teléfono "5123-1234"
    Cuando ingreso "/registrar Juan, Cucha Cucha 1234, 5123-1234"
    Entonces la cuenta no se crea
    Y se muestra el mensaje "Error: el telefono ya está en uso"