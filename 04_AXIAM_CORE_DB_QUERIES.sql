/*
====================================================================
AXIAM CORE DB
Sistema de gestión de clientes, tiendas y pedidos
Implementación mediante Microsoft SQL Server

SECCIÓN       : CONSULTAS SQL
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
    Conjunto de consultas SQL orientadas a la explotación,
    análisis y presentación de la información almacenada
    en AXIAM_CORE_DB.

    Las consultas utilizan operaciones de selección, filtros,
    agrupaciones, funciones de agregación, relaciones entre
    tablas, subconsultas y funciones de ventana para obtener
    información relevante del sistema.

CONSULTAS IMPLEMENTADAS:
    - Clientes y sus direcciones.
    - Clientes con múltiples direcciones.
    - Productos por tienda.
    - Productos con stock bajo.
    - Pedidos asociados a clientes.
    - Detalle completo de pedidos.
    - Total de ventas por tienda.
    - Productos más vendidos.
    - Administradores asignados a tiendas.
    - Cantidad de productos por tienda.
    - Cantidad de pedidos por estado.
    - Pedidos superiores a un valor determinado.
    - Valor total comprado por cliente.
    - Producto de mayor precio por tienda.
    - Consulta de registros de auditoría.

PROPÓSITO:
    Demostrar la capacidad de consulta y análisis de la
    información almacenada, validando las relaciones del
    modelo y obteniendo indicadores relevantes para la
    operación y toma de decisiones del negocio.

TECNOLOGÍA:
    Microsoft SQL Server / T-SQL
====================================================================
*/

USE AXIAM_CORE_DB;
GO

--  1. CLIENTES CON SUS DIRECCIONES
  
SELECT
    C.ClienteID,
    C.Nombre,
    C.Apellido,
    C.Correo,
    D.Direccion,
    D.Ciudad,
    D.Departamento
FROM CORE.CLIENTE C
INNER JOIN CORE.DIRECCION D
    ON D.ClienteID = C.ClienteID
ORDER BY C.ClienteID;
GO

 -- 2. CLIENTES QUE TIENEN MÁS DE UNA DIRECCIÓN

SELECT
    C.ClienteID,
    C.Nombre,
    C.Apellido,
    COUNT(D.DireccionID) AS CantidadDirecciones
FROM CORE.CLIENTE C
INNER JOIN CORE.DIRECCION D
    ON D.ClienteID = C.ClienteID
GROUP BY
    C.ClienteID,
    C.Nombre,
    C.Apellido
HAVING COUNT(D.DireccionID) > 1;
GO

-- 3. PRODUCTOS Y LA TIENDA A LA QUE PERTENECEN

SELECT
    P.ProductoID,
    P.Nombre AS Producto,
    P.Precio,
    P.Stock,
    T.Nombre AS Tienda,
    T.Ciudad
FROM COMMERCE.PRODUCTO P
INNER JOIN COMMERCE.TIENDA T
    ON T.TiendaID = P.TiendaID
ORDER BY T.Nombre, P.Nombre;
GO

-- 4. PRODUCTOS CON STOCK BAJO

SELECT
    P.ProductoID,
    P.Nombre AS Producto,
    T.Nombre AS Tienda,
    P.Stock,
    P.Precio
FROM COMMERCE.PRODUCTO P
INNER JOIN COMMERCE.TIENDA T
    ON T.TiendaID = P.TiendaID
WHERE P.Stock <= 10
ORDER BY P.Stock ASC;
GO

-- 5. PEDIDOS CON INFORMACIÓN DEL CLIENTE

SELECT
    P.PedidoID,
    C.Nombre + ' ' + C.Apellido AS Cliente,
    C.Correo,
    P.FechaPedido,
    P.Total,
    P.Estado
FROM COMMERCE.PEDIDO P
INNER JOIN CORE.CLIENTE C
    ON C.ClienteID = P.ClienteID
ORDER BY P.FechaPedido DESC;
GO

-- 6. DETALLE COMPLETO DE LOS PEDIDOS

SELECT
    P.PedidoID,
    C.Nombre + ' ' + C.Apellido AS Cliente,
    P.FechaPedido,
    P.Estado,
    T.Nombre AS Tienda,
    PR.Nombre AS Producto,
    D.Cantidad,
    D.PrecioUnitario,
    D.Subtotal
FROM COMMERCE.PEDIDO P
    INNER JOIN CORE.CLIENTE C ON C.ClienteID = P.ClienteID
    INNER JOIN COMMERCE.DETALLE_PEDIDO D ON D.PedidoID = P.PedidoID
    INNER JOIN COMMERCE.PRODUCTO PR ON PR.ProductoID = D.ProductoID
    INNER JOIN COMMERCE.TIENDA T ON T.TiendaID = PR.TiendaID
ORDER BY P.PedidoID, D.DetallePedidoID;
GO

-- 7. TOTAL DE VENTAS POR TIENDA (EXCLUYENDO PEDIDOS CANCELADOS)

SELECT
    T.TiendaID,
    T.Nombre AS Tienda,
    SUM(D.Subtotal) AS TotalVentas
    FROM COMMERCE.TIENDA T
        INNER JOIN COMMERCE.PRODUCTO PR ON PR.TiendaID = T.TiendaID
        INNER JOIN COMMERCE.DETALLE_PEDIDO D ON D.ProductoID = PR.ProductoID
        INNER JOIN COMMERCE.PEDIDO P ON P.PedidoID = D.PedidoID
    WHERE P.Estado <> 'CANCELADO'
        GROUP BY
            T.TiendaID,
            T.Nombre
    ORDER BY TotalVentas DESC;
GO

 --  8. PRODUCTOS MÁS VENDIDOS

SELECT
    PR.ProductoID,
    PR.Nombre AS Producto,
    SUM(D.Cantidad) AS UnidadesVendidas
  FROM COMMERCE.PRODUCTO PR
      INNER JOIN COMMERCE.DETALLE_PEDIDO D ON D.ProductoID = PR.ProductoID
      INNER JOIN COMMERCE.PEDIDO P ON P.PedidoID = D.PedidoID
  WHERE P.Estado <> 'CANCELADO'
  GROUP BY
    PR.ProductoID,
    PR.Nombre
  ORDER BY UnidadesVendidas DESC;
GO

-- 9. ADMINISTRADORES ASIGNADOS A CADA TIENDA

SELECT
    T.TiendaID,
    T.Nombre AS Tienda,
    A.AdministradorID,
    A.Nombre + ' ' + A.Apellido AS Administrador,
    A.Correo
FROM SECURITY.ADMINISTRADOR_TIENDA AT
INNER JOIN CORE.ADMINISTRADOR A ON A.AdministradorID = AT.AdministradorID
INNER JOIN COMMERCE.TIENDA T ON T.TiendaID = AT.TiendaID
ORDER BY T.Nombre, A.Apellido;
GO


-- 10. CANTIDAD DE PRODUCTOS POR TIENDA

SELECT
    T.TiendaID,
    T.Nombre AS Tienda,
    COUNT(P.ProductoID) AS CantidadProductos
    FROM COMMERCE.TIENDA T
    LEFT JOIN COMMERCE.PRODUCTO P ON P.TiendaID = T.TiendaID
    GROUP BY
        T.TiendaID,
        T.Nombre
    ORDER BY CantidadProductos DESC;
GO

-- 11. CANTIDAD DE PEDIDOS POR ESTADO

SELECT
    Estado,
    COUNT(*) AS CantidadPedidos
FROM COMMERCE.PEDIDO
    GROUP BY Estado
    ORDER BY CantidadPedidos DESC;
GO

 -- 12. PEDIDOS SUPERIORES A $2.000.000

SELECT
    P.PedidoID,
    C.Nombre + ' ' + C.Apellido AS Cliente,
    P.FechaPedido,
    P.Total,
    P.Estado
FROM COMMERCE.PEDIDO P
    INNER JOIN CORE.CLIENTE C ON C.ClienteID = P.ClienteID
WHERE P.Total > 2000000
ORDER BY P.Total DESC;
GO

-- 13. VALOR TOTAL COMPRADO POR CADA CLIENTE

SELECT
    C.ClienteID,
    C.Nombre + ' ' + C.Apellido AS Cliente,
    COUNT(P.PedidoID) AS CantidadPedidos,
    COALESCE(SUM(
        CASE
            WHEN P.Estado <> 'CANCELADO'
            THEN P.Total
            ELSE 0
        END
    ), 0) AS TotalComprado
FROM CORE.CLIENTE C
LEFT JOIN COMMERCE.PEDIDO P ON P.ClienteID = C.ClienteID
GROUP BY
    C.ClienteID,
    C.Nombre,
    C.Apellido
ORDER BY TotalComprado DESC;
GO

-- 14. PRODUCTO MÁS CARO DE CADA TIENDA

WITH ProductosOrdenados AS
(
    SELECT
        P.ProductoID,
        P.TiendaID,
        P.Nombre AS Producto,
        P.Precio,

        ROW_NUMBER() OVER
        (
            PARTITION BY P.TiendaID
            ORDER BY P.Precio DESC
        ) AS Posicion

    FROM COMMERCE.PRODUCTO P
)

SELECT
    T.Nombre AS Tienda,
    PO.Producto,
    PO.Precio
FROM ProductosOrdenados PO
    INNER JOIN COMMERCE.TIENDA T ON T.TiendaID = PO.TiendaID
WHERE PO.Posicion = 1
ORDER BY T.Nombre;
GO

-- 15. AUDITORÍA

SELECT
    LogID,
    Tabla,
    Operacion,
    RegistroID,
    FechaOperacion,
    UsuarioSQL,
    Detalle
FROM AUDIT.LOG_OPERACION
ORDER BY FechaOperacion DESC;
GO