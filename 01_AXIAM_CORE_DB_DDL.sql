/*
====================================================================
AXIAM CORE DB
Sistema de gestión de clientes, tiendas y pedidos
Implementación mediante Microsoft SQL Server

SECCIÓN       : DDL - Data Definition Language
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
    Definición de la estructura física de AXIAM_CORE_DB,
    incluyendo la creación de la base de datos, esquemas,
    tablas, restricciones, claves, índices y mecanismos
    de auditoría.

TECNOLOGÍA:
    Microsoft SQL Server
    T-SQL

ESQUEMAS:
    CORE
    COMMERCE
    SECURITY
    AUDIT

====================================================================
*/

-- 1. CREACIÓN DE BASE DE DATOS 

IF DB_ID('AXIAM_CORE_DB') IS NULL
BEGIN
    CREATE DATABASE AXIAM_CORE_DB;
END;
GO

USE AXIAM_CORE_DB;
GO

--  2. CREACIÓN DE SCHEMAS

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'CORE'
)
BEGIN
    EXEC('CREATE SCHEMA CORE');
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'COMMERCE'
)
BEGIN
    EXEC('CREATE SCHEMA COMMERCE');
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'SECURITY'
)
BEGIN
    EXEC('CREATE SCHEMA SECURITY');
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'AUDIT'
)
BEGIN
    EXEC('CREATE SCHEMA AUDIT');
END;
GO

--   3. TABLA CORE.CLIENTE
CREATE TABLE CORE.CLIENTE
(
    ClienteID INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(100) NOT NULL,
    Apellido NVARCHAR(100) NOT NULL,
    Correo NVARCHAR(255) NOT NULL,
    Telefono NVARCHAR(30) NULL,
    FechaRegistro DATETIME2(0) NOT NULL
    CONSTRAINT DF_CLIENTE_FechaRegistro DEFAULT SYSDATETIME(),
    CONSTRAINT PK_CLIENTE PRIMARY KEY (ClienteID),
    CONSTRAINT UQ_CLIENTE_Correo UNIQUE (Correo)
);
GO

--   4. TABLA CORE.DIRECCION
CREATE TABLE CORE.DIRECCION
(
    DireccionID INT IDENTITY(1,1) NOT NULL,
    ClienteID INT NOT NULL,
    Direccion NVARCHAR(250) NOT NULL,
    Ciudad NVARCHAR(100) NOT NULL,
    Departamento NVARCHAR(100) NOT NULL,
    CodigoPostal NVARCHAR(20) NULL,
    CONSTRAINT PK_DIRECCION PRIMARY KEY (DireccionID),
    CONSTRAINT FK_DIRECCION_CLIENTE 
        FOREIGN KEY (ClienteID)
    REFERENCES CORE.CLIENTE(ClienteID)
);
GO

CREATE INDEX IX_DIRECCION_ClienteID
ON CORE.DIRECCION(ClienteID);
GO

-- 5. TABLA CORE.ADMINISTRADOR

CREATE TABLE CORE.ADMINISTRADOR
(
    AdministradorID INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(100) NOT NULL,
    Apellido NVARCHAR(100) NOT NULL,
    Correo NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_ADMINISTRADOR
        PRIMARY KEY (AdministradorID),
    CONSTRAINT UQ_ADMINISTRADOR_Correo
        UNIQUE (Correo)
);
GO

--   6. TABLA COMMERCE.TIENDA

CREATE TABLE COMMERCE.TIENDA
(
    TiendaID INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(150) NOT NULL,
    Direccion NVARCHAR(250) NOT NULL,
    Ciudad NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_TIENDA
        PRIMARY KEY (TiendaID),
    CONSTRAINT UQ_TIENDA_Nombre
        UNIQUE (Nombre)
);
GO

 -- 7. TABLA COMMERCE.PRODUCTO

CREATE TABLE COMMERCE.PRODUCTO
(
    ProductoID INT IDENTITY(1,1) NOT NULL,
    TiendaID INT NOT NULL,
    Nombre NVARCHAR(150) NOT NULL,
    Descripcion NVARCHAR(500) NULL,
    Precio DECIMAL(18,2) NOT NULL,
    Stock INT NOT NULL
    CONSTRAINT DF_PRODUCTO_Stock
        DEFAULT 0,
    CONSTRAINT PK_PRODUCTO
        PRIMARY KEY (ProductoID),
    CONSTRAINT FK_PRODUCTO_TIENDA
        FOREIGN KEY (TiendaID)
        REFERENCES COMMERCE.TIENDA(TiendaID),
    CONSTRAINT CK_PRODUCTO_Precio
        CHECK (Precio >= 0),
    CONSTRAINT CK_PRODUCTO_Stock
        CHECK (Stock >= 0)
);
GO

CREATE INDEX IX_PRODUCTO_TiendaID
ON COMMERCE.PRODUCTO(TiendaID);
GO

-- 8. TABLA SECURITY.ADMINISTRADOR_TIENDA

CREATE TABLE SECURITY.ADMINISTRADOR_TIENDA
(
    AdministradorTiendaID INT IDENTITY(1,1) NOT NULL,
    AdministradorID INT NOT NULL,
    TiendaID INT NOT NULL,
    CONSTRAINT PK_ADMINISTRADOR_TIENDA
        PRIMARY KEY (AdministradorTiendaID),
    CONSTRAINT FK_ADMINISTRADOR_TIENDA_ADMINISTRADOR
        FOREIGN KEY (AdministradorID)
        REFERENCES CORE.ADMINISTRADOR(AdministradorID),
    CONSTRAINT FK_ADMINISTRADOR_TIENDA_TIENDA
        FOREIGN KEY (TiendaID)
        REFERENCES COMMERCE.TIENDA(TiendaID),
    CONSTRAINT UQ_ADMINISTRADOR_TIENDA
        UNIQUE (AdministradorID, TiendaID)
);
GO

CREATE INDEX IX_ADMINISTRADOR_TIENDA_AdministradorID
ON SECURITY.ADMINISTRADOR_TIENDA(AdministradorID);

CREATE INDEX IX_ADMINISTRADOR_TIENDA_TiendaID
ON SECURITY.ADMINISTRADOR_TIENDA(TiendaID);
GO

--  9. TABLA COMMERCE.PEDIDO

CREATE TABLE COMMERCE.PEDIDO
(
    PedidoID INT IDENTITY(1,1) NOT NULL,
    ClienteID INT NOT NULL,
    FechaPedido DATETIME2(0) NOT NULL
        CONSTRAINT DF_PEDIDO_FechaPedido
        DEFAULT SYSDATETIME(),
    Total DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_PEDIDO_Total
        DEFAULT 0,
    Estado NVARCHAR(30) NOT NULL
        CONSTRAINT DF_PEDIDO_Estado
        DEFAULT 'PENDIENTE',
    CONSTRAINT PK_PEDIDO
        PRIMARY KEY (PedidoID),
    CONSTRAINT FK_PEDIDO_CLIENTE
        FOREIGN KEY (ClienteID)
        REFERENCES CORE.CLIENTE(ClienteID),
    CONSTRAINT CK_PEDIDO_Total
        CHECK (Total >= 0),
    CONSTRAINT CK_PEDIDO_Estado
        CHECK
        (
            Estado IN
            (
                'PENDIENTE',
                'CONFIRMADO',
                'ENVIADO',
                'ENTREGADO',
                'CANCELADO'
            )
        )
);
GO

CREATE INDEX IX_PEDIDO_ClienteID
ON COMMERCE.PEDIDO(ClienteID);

CREATE INDEX IX_PEDIDO_Estado
ON COMMERCE.PEDIDO(Estado);

CREATE INDEX IX_PEDIDO_FechaPedido
ON COMMERCE.PEDIDO(FechaPedido);
GO

--   10. TABLA COMMERCE.DETALLE_PEDIDO

CREATE TABLE COMMERCE.DETALLE_PEDIDO
(
    DetallePedidoID INT IDENTITY(1,1) NOT NULL,
    PedidoID INT NOT NULL,
    ProductoID INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(18,2) NOT NULL,
    Subtotal AS(Cantidad * PrecioUnitario) PERSISTED,
    CONSTRAINT PK_DETALLE_PEDIDO
        PRIMARY KEY (DetallePedidoID),
    CONSTRAINT FK_DETALLE_PEDIDO_PEDIDO
        FOREIGN KEY (PedidoID)
        REFERENCES COMMERCE.PEDIDO(PedidoID),
    CONSTRAINT FK_DETALLE_PEDIDO_PRODUCTO
        FOREIGN KEY (ProductoID)
        REFERENCES COMMERCE.PRODUCTO(ProductoID),
    CONSTRAINT CK_DETALLE_PEDIDO_Cantidad
        CHECK (Cantidad > 0),
    CONSTRAINT CK_DETALLE_PEDIDO_Precio
        CHECK (PrecioUnitario >= 0)
);
GO

CREATE INDEX IX_DETALLE_PEDIDO_PedidoID
ON COMMERCE.DETALLE_PEDIDO(PedidoID);

CREATE INDEX IX_DETALLE_PEDIDO_ProductoID
ON COMMERCE.DETALLE_PEDIDO(ProductoID);
GO

--  11. TABLA DE AUDITORÍA


CREATE TABLE AUDIT.LOG_OPERACION
(
    LogID BIGINT IDENTITY(1,1) NOT NULL,
    Tabla NVARCHAR(128) NOT NULL,
    Operacion NVARCHAR(20) NOT NULL,
    RegistroID INT NULL,
    FechaOperacion DATETIME2(0) NOT NULL
        CONSTRAINT DF_LOG_FechaOperacion
        DEFAULT SYSDATETIME(),
    UsuarioSQL NVARCHAR(128) NOT NULL
        CONSTRAINT DF_LOG_UsuarioSQL
        DEFAULT SUSER_SNAME(),
    Detalle NVARCHAR(MAX) NULL,
    CONSTRAINT PK_LOG_OPERACION
        PRIMARY KEY (LogID)
);
GO

CREATE INDEX IX_LOG_OPERACION_Tabla
ON AUDIT.LOG_OPERACION(Tabla);

CREATE INDEX IX_LOG_OPERACION_Fecha
ON AUDIT.LOG_OPERACION(FechaOperacion);
GO

--   12. TRIGGER DE AUDITORÍA - CLIENTE

CREATE TRIGGER CORE.TR_CLIENTE_AUDIT
ON CORE.CLIENTE
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AUDIT.LOG_OPERACION
    (
        Tabla,
        Operacion,
        RegistroID,
        Detalle
    )
    SELECT
        'CORE.CLIENTE',

        CASE
            WHEN i.ClienteID IS NOT NULL
             AND d.ClienteID IS NOT NULL
                THEN 'UPDATE'

            WHEN i.ClienteID IS NOT NULL
                THEN 'INSERT'

            ELSE 'DELETE'
        END,

        COALESCE(i.ClienteID, d.ClienteID),

        'Operación realizada sobre CLIENTE'

    FROM inserted i

    FULL OUTER JOIN deleted d
        ON i.ClienteID = d.ClienteID;
END;
GO

-- 13. TRIGGER DE AUDITORÍA - TIENDA

CREATE TRIGGER COMMERCE.TR_TIENDA_AUDIT
ON COMMERCE.TIENDA
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AUDIT.LOG_OPERACION
    (
        Tabla,
        Operacion,
        RegistroID,
        Detalle
    )
    SELECT
        'COMMERCE.TIENDA',

        CASE
            WHEN i.TiendaID IS NOT NULL
             AND d.TiendaID IS NOT NULL
                THEN 'UPDATE'

            WHEN i.TiendaID IS NOT NULL
                THEN 'INSERT'

            ELSE 'DELETE'
        END,

        COALESCE(i.TiendaID, d.TiendaID),

        'Operación realizada sobre TIENDA'

    FROM inserted i

    FULL OUTER JOIN deleted d
        ON i.TiendaID = d.TiendaID;

END;
GO

--  14. TRIGGER - ACTUALIZACIÓN TOTAL PEDIDO

CREATE TRIGGER COMMERCE.TR_DETALLE_PEDIDO_TOTAL
ON COMMERCE.DETALLE_PEDIDO
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

    SET NOCOUNT ON;
    UPDATE P
    SET P.Total =
    (
        SELECT COALESCE(SUM(D.Subtotal), 0)
        FROM COMMERCE.DETALLE_PEDIDO D
        WHERE D.PedidoID = P.PedidoID
    )

    FROM COMMERCE.PEDIDO P
        WHERE P.PedidoID IN
    (
        SELECT PedidoID
        FROM inserted

        UNION

        SELECT PedidoID
        FROM deleted
    );

END;
GO



