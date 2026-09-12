 /*
====================================================================
AXIAM CORE DB
Sistema de gestión de clientes, tiendas y pedidos
Implementación mediante Microsoft SQL Server

SECCIÓN       : PROCEDIMIENTOS ALMACENADOS
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
    Implementación de procedimientos almacenados para encapsular
    operaciones de consulta, creación y gestión de información
    dentro de AXIAM_CORE_DB.

    Los procedimientos incorporan validaciones de integridad,
    control de errores y consultas relacionadas con clientes,
    tiendas, productos, pedidos y administradores.

PROCEDIMIENTOS IMPLEMENTADOS:
    CORE
        - SP_CLIENTE_CREAR
        - SP_CLIENTE_OBTENER

    COMMERCE
        - SP_TIENDA_CREAR
        - SP_PRODUCTO_CREAR
        - SP_PRODUCTOS_POR_TIENDA
        - SP_PEDIDO_CREAR
        - SP_PEDIDO_AGREGAR_DETALLE
        - SP_PEDIDO_OBTENER

    SECURITY
        - SP_ASIGNAR_ADMINISTRADOR
        - SP_ADMINISTRADORES_POR_TIENDA

PROPÓSITO:
    Centralizar operaciones frecuentes de la base de datos,
    reducir la duplicación de lógica, aplicar validaciones
    y proporcionar una interfaz controlada para las operaciones
    sobre las entidades principales del sistema.

TECNOLOGÍA:
    Microsoft SQL Server / T-SQL
====================================================================
*/
 
 --  01. SP - CREAR CLIENTE

CREATE PROCEDURE CORE.SP_CLIENTE_CREAR
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(100),
    @Correo NVARCHAR(255),
    @Telefono NVARCHAR(30) = NULL
AS
BEGIN

    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM CORE.CLIENTE
        WHERE Correo = @Correo
    )
    BEGIN
        THROW 50001,
              'El correo del cliente ya existe.',
              1;
    END;

    INSERT INTO CORE.CLIENTE
    (
        Nombre,
        Apellido,
        Correo,
        Telefono
    )
    VALUES
    (
        @Nombre,
        @Apellido,
        @Correo,
        @Telefono
    );

    SELECT
        ClienteID,
        Nombre,
        Apellido,
        Correo,
        Telefono,
        FechaRegistro

    FROM CORE.CLIENTE

    WHERE ClienteID = SCOPE_IDENTITY();

END;
GO

-- 02. SP - OBTENER CLIENTE


CREATE PROCEDURE CORE.SP_CLIENTE_OBTENER
    @ClienteID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ClienteID,
        Nombre,
        Apellido,
        Correo,
        Telefono,
        FechaRegistro

    FROM CORE.CLIENTE

    WHERE ClienteID = @ClienteID;

END;
GO



 -- 03. SP - CREAR TIENDA


CREATE PROCEDURE COMMERCE.SP_TIENDA_CREAR
    @Nombre NVARCHAR(150),
    @Direccion NVARCHAR(250),
    @Ciudad NVARCHAR(100)
AS
BEGIN

    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM COMMERCE.TIENDA
        WHERE Nombre = @Nombre
    )
    BEGIN
        THROW 50002,
              'La tienda ya existe.',
              1;
    END;

    INSERT INTO COMMERCE.TIENDA
    (
        Nombre,
        Direccion,
        Ciudad
    )
    VALUES
    (
        @Nombre,
        @Direccion,
        @Ciudad
    );

    SELECT
        TiendaID,
        Nombre,
        Direccion,
        Ciudad

    FROM COMMERCE.TIENDA

    WHERE TiendaID = SCOPE_IDENTITY();

END;
GO



  -- 04. SP - CREAR PRODUCTO


CREATE PROCEDURE COMMERCE.SP_PRODUCTO_CREAR
    @TiendaID INT,
    @Nombre NVARCHAR(150),
    @Descripcion NVARCHAR(500) = NULL,
    @Precio DECIMAL(18,2),
    @Stock INT = 0
AS
BEGIN

    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM COMMERCE.TIENDA
        WHERE TiendaID = @TiendaID
    )
    BEGIN
        THROW 50003,
              'La tienda especificada no existe.',
              1;
    END;

    IF @Precio < 0
    BEGIN
        THROW 50004,
              'El precio no puede ser negativo.',
              1;
    END;

    IF @Stock < 0
    BEGIN
        THROW 50005,
              'El stock no puede ser negativo.',
              1;
    END;

    INSERT INTO COMMERCE.PRODUCTO
    (
        TiendaID,
        Nombre,
        Descripcion,
        Precio,
        Stock
    )
    VALUES
    (
        @TiendaID,
        @Nombre,
        @Descripcion,
        @Precio,
        @Stock
    );

    SELECT
        ProductoID,
        TiendaID,
        Nombre,
        Descripcion,
        Precio,
        Stock

    FROM COMMERCE.PRODUCTO

    WHERE ProductoID = SCOPE_IDENTITY();

END;
GO



 -- 05. SP - PRODUCTOS POR TIENDA


CREATE PROCEDURE COMMERCE.SP_PRODUCTOS_POR_TIENDA
    @TiendaID INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        P.ProductoID,
        P.TiendaID,
        T.Nombre AS Tienda,
        P.Nombre,
        P.Descripcion,
        P.Precio,
        P.Stock

    FROM COMMERCE.PRODUCTO P

    INNER JOIN COMMERCE.TIENDA T
        ON T.TiendaID = P.TiendaID

    WHERE P.TiendaID = @TiendaID

    ORDER BY P.Nombre;

END;
GO

-- 06. SP - CREAR PEDIDO


CREATE PROCEDURE COMMERCE.SP_PEDIDO_CREAR
    @ClienteID INT
AS
BEGIN

    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM CORE.CLIENTE
        WHERE ClienteID = @ClienteID
    )
    BEGIN
        THROW 50006,
              'El cliente especificado no existe.',
              1;
    END;

    INSERT INTO COMMERCE.PEDIDO
    (
        ClienteID
    )
    VALUES
    (
        @ClienteID
    );

    SELECT
        PedidoID,
        ClienteID,
        FechaPedido,
        Total,
        Estado

    FROM COMMERCE.PEDIDO

    WHERE PedidoID = SCOPE_IDENTITY();

END;
GO

 -- 07. SP - AGREGAR PRODUCTO AL PEDIDO

CREATE PROCEDURE COMMERCE.SP_PEDIDO_AGREGAR_DETALLE
    @PedidoID INT,
    @ProductoID INT,
    @Cantidad INT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @Precio DECIMAL(18,2);

    IF NOT EXISTS
    (
        SELECT 1
        FROM COMMERCE.PEDIDO
        WHERE PedidoID = @PedidoID
    )
    BEGIN
        THROW 50007,
              'El pedido especificado no existe.',
              1;
    END;

    SELECT @Precio = Precio

    FROM COMMERCE.PRODUCTO

    WHERE ProductoID = @ProductoID;

    IF @Precio IS NULL
    BEGIN
        THROW 50008,
              'El producto especificado no existe.',
              1;
    END;

    IF @Cantidad <= 0
    BEGIN
        THROW 50009,
              'La cantidad debe ser mayor que cero.',
              1;
    END;

    INSERT INTO COMMERCE.DETALLE_PEDIDO
    (
        PedidoID,
        ProductoID,
        Cantidad,
        PrecioUnitario
    )
    VALUES
    (
        @PedidoID,
        @ProductoID,
        @Cantidad,
        @Precio
    );

    SELECT
        D.DetallePedidoID,
        D.PedidoID,
        D.ProductoID,
        P.Nombre AS Producto,
        D.Cantidad,
        D.PrecioUnitario,
        D.Subtotal

    FROM COMMERCE.DETALLE_PEDIDO D

    INNER JOIN COMMERCE.PRODUCTO P
        ON P.ProductoID = D.ProductoID

    WHERE D.DetallePedidoID = SCOPE_IDENTITY();

END;
GO

--  08. SP - CONSULTAR PEDIDO COMPLETO


CREATE PROCEDURE COMMERCE.SP_PEDIDO_OBTENER
    @PedidoID INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        P.PedidoID,
        P.ClienteID,
        CONCAT(C.Nombre, ' ', C.Apellido) AS Cliente,
        C.Correo,
        P.FechaPedido,
        P.Total,
        P.Estado

    FROM COMMERCE.PEDIDO P

    INNER JOIN CORE.CLIENTE C
        ON C.ClienteID = P.ClienteID

    WHERE P.PedidoID = @PedidoID;

    SELECT
        D.DetallePedidoID,
        D.ProductoID,
        PR.Nombre AS Producto,
        T.Nombre AS Tienda,
        D.Cantidad,
        D.PrecioUnitario,
        D.Subtotal

    FROM COMMERCE.DETALLE_PEDIDO D

    INNER JOIN COMMERCE.PRODUCTO PR
        ON PR.ProductoID = D.ProductoID

    INNER JOIN COMMERCE.TIENDA T
        ON T.TiendaID = PR.TiendaID

    WHERE D.PedidoID = @PedidoID

    ORDER BY D.DetallePedidoID;

END;
GO



 -- 09. SP - ASIGNAR ADMINISTRADOR A TIENDA

CREATE PROCEDURE SECURITY.SP_ASIGNAR_ADMINISTRADOR
    @AdministradorID INT,
    @TiendaID INT
AS
BEGIN

    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM CORE.ADMINISTRADOR
        WHERE AdministradorID = @AdministradorID
    )
    BEGIN
        THROW 50010,
              'El administrador especificado no existe.',
              1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM COMMERCE.TIENDA
        WHERE TiendaID = @TiendaID
    )
    BEGIN
        THROW 50011,
              'La tienda especificada no existe.',
              1;
    END;

    IF EXISTS
    (
        SELECT 1

        FROM SECURITY.ADMINISTRADOR_TIENDA

        WHERE AdministradorID = @AdministradorID
          AND TiendaID = @TiendaID
    )
    BEGIN
        THROW 50012,
              'El administrador ya está asignado a esta tienda.',
              1;
    END;

    INSERT INTO SECURITY.ADMINISTRADOR_TIENDA
    (
        AdministradorID,
        TiendaID
    )
    VALUES
    (
        @AdministradorID,
        @TiendaID
    );

END;
GO

 -- 10. SP - ADMINISTRADORES DE UNA TIENDA

CREATE PROCEDURE SECURITY.SP_ADMINISTRADORES_POR_TIENDA
    @TiendaID INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        A.AdministradorID,
        A.Nombre,
        A.Apellido,
        A.Correo

    FROM SECURITY.ADMINISTRADOR_TIENDA AT

    INNER JOIN CORE.ADMINISTRADOR A
        ON A.AdministradorID = AT.AdministradorID

    WHERE AT.TiendaID = @TiendaID

    ORDER BY A.Apellido, A.Nombre;

END;
GO