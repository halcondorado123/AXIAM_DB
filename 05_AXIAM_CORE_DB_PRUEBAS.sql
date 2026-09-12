/*
====================================================================
AXIAM CORE DB
Sistema de gestión de clientes, tiendas y pedidos
Implementación mediante Microsoft SQL Server

SECCIÓN       : PRUEBAS DE TRIGGERS
DESARROLLADORES:
    - JHONATTAN HALCON CASALLAS FELIPE
    - JUAN SEBASTIAN MUÑOZ ORDOÑEZ

ASIGNATURA    : Administración de Bases de Datos
DOCENTE       : JOHN HENRY NAUSA ALARCÓN
INSTITUCIÓN   : CUN - Corporación Unificada Nacional
PROGRAMA      : Ingeniería de Sistemas
GRUPO         : 54426
BLOQUE        : Primer Bloque
PERIODO       : 26P04

DESCRIPCIÓN:
    Pruebas funcionales de los triggers implementados en
    AXIAM_CORE_DB.

    Las pruebas verifican el funcionamiento de los mecanismos
    de auditoría y actualización automática implementados
    mediante triggers sobre las tablas principales del sistema.

PRUEBAS IMPLEMENTADAS:
    - Registro automático de operaciones realizadas sobre CLIENTE.
    - Actualización automática del total de un pedido al
      insertar un detalle de pedido.

PROPÓSITO:
    Validar que los triggers respondan correctamente ante
    operaciones de modificación de datos y que los cambios
    automáticos esperados sean reflejados en las tablas
    correspondientes.

TECNOLOGÍA:
    Microsoft SQL Server / T-SQL
====================================================================
*/

--  PRUEBA 1 - AUDITORÍA DE CLIENTE
  
UPDATE CORE.CLIENTE
SET Telefono = '3009998877'
WHERE ClienteID = 1;
GO

SELECT *
FROM AUDIT.LOG_OPERACION
WHERE Tabla = 'CORE.CLIENTE'
ORDER BY LogID DESC;
GO

-- PRUEBA 2 - ACTUALIZACIÓN AUTOMÁTICA DEL TOTAL DEL PEDIDO
  
INSERT INTO COMMERCE.DETALLE_PEDIDO
(
    PedidoID,
    ProductoID,
    Cantidad,
    PrecioUnitario
)
VALUES
(4, 8, 1, 629900);
GO

SELECT
    PedidoID,
    ClienteID,
    Total,
    Estado
FROM COMMERCE.PEDIDO
WHERE PedidoID = 4;
GO