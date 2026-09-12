/*
====================================================================
AXIAM CORE DB
Sistema de gestión de clientes, tiendas y pedidos
Implementación mediante Microsoft SQL Server

SECCIÓN       : DML - Data Manipulation Language
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
    Carga y manipulación de datos iniciales para AXIAM_CORE_DB.
    Se incluyen registros representativos de clientes, direcciones,
    tiendas, productos, administradores, relaciones entre tiendas
    y administradores, pedidos y detalles de pedidos.

PROPÓSITO:
    Proporcionar un conjunto de datos representativo que permita
    validar las relaciones, restricciones, operaciones transaccionales,
    consultas, triggers y procedimientos almacenados implementados
    en la base de datos.

TECNOLOGÍA:
    Microsoft SQL Server / T-SQL
====================================================================
*/

USE AXIAM_CORE_DB;
GO

--   CLIENTES

INSERT INTO CORE.CLIENTE
(
    Nombre,
    Apellido,
    Correo,
    Telefono
)
VALUES
('Santiago', 'Cárdenas', 'santiago.cardenas@gmail.com', '3104587291'),
('Valentina', 'Rojas', 'valentina.rojas@gmail.com', '3156721840'),
('Andrés', 'Mendoza', 'andres.mendoza@outlook.com', '3005841937'),
('Camila', 'Torres', 'camila.torres@hotmail.com', '3184219560'),
('Sebastián', 'Pardo', 'sebastian.pardo@gmail.com', '3117392845'),
('Natalia', 'Herrera', 'natalia.herrera@outlook.com', '3165084729'),
('Daniel', 'Gómez', 'daniel.gomez@gmail.com', '3018642957'),
('Mariana', 'Castro', 'mariana.castro@gmail.com', '3204751836'),
('Felipe', 'Navarro', 'felipe.navarro@hotmail.com', '3126938471'),
('Laura', 'Restrepo', 'laura.restrepo@gmail.com', '3175284069');
GO


--  DIRECCIONES

INSERT INTO CORE.DIRECCION
(
    ClienteID,
    Direccion,
    Ciudad,
    Departamento,
    CodigoPostal
)
VALUES
(1, 'Carrera 15 # 93-47 Apto 502', 'Bogotá', 'Cundinamarca', '110221'),
(1, 'Calle 127 # 19-18 Casa 12', 'Bogotá', 'Cundinamarca', '110121'),
(2, 'Carrera 7 # 72-41 Apto 804', 'Bogotá', 'Cundinamarca', '110231'),
(3, 'Calle 10 # 35-22 Apto 301', 'Medellín', 'Antioquia', '050021'),
(4, 'Carrera 43A # 16 Sur-35', 'Medellín', 'Antioquia', '050030'),
(5, 'Calle 80 # 11-42 Apto 703', 'Bogotá', 'Cundinamarca', '110221'),
(6, 'Carrera 52 # 76-18 Apto 404', 'Barranquilla', 'Atlántico', '080001'),
(7, 'Calle 18 # 122-45 Casa 8', 'Cali', 'Valle del Cauca', '760031'),
(8, 'Carrera 33 # 49-24 Apto 601', 'Bucaramanga', 'Santander', '680002'),
(9, 'Calle 93 # 13-27 Apto 502', 'Bogotá', 'Cundinamarca', '110221'),
(10, 'Carrera 38 # 10-54 Apto 302', 'Medellín', 'Antioquia', '050021');
GO


--  TIENDAS

INSERT INTO COMMERCE.TIENDA
(
    Nombre,
    Direccion,
    Ciudad
)
VALUES
('TecnoAndes', 'Carrera 13 # 78-45', 'Bogotá'),
('Casa Digital', 'Calle 52 # 45-18', 'Medellín'),
('Mundo Oficina', 'Carrera 53 # 80-121', 'Barranquilla'),
('Conexión Tecnológica', 'Calle 9 # 64-18', 'Cali'),
('ElectroNova', 'Carrera 27 # 36-52', 'Bucaramanga');
GO


-- PRODUCTOS

INSERT INTO COMMERCE.PRODUCTO
(
    TiendaID,
    Nombre,
    Descripcion,
    Precio,
    Stock
)
VALUES
(1, 'Portátil Lenovo IdeaPad 3', 'Portátil de 15.6 pulgadas para productividad y estudio.', 2899900, 14),
(1, 'Monitor LG UltraGear 24GN60R','Monitor gaming de 24 pulgadas con alta frecuencia de actualización.', 899900, 22),
(1, 'Teclado Logitech MX Keys S', 'Teclado inalámbrico para productividad profesional.', 449900, 18),
(2, 'iPhone 15 128GB', 'Smartphone Apple con almacenamiento de 128 GB.', 3299900, 11),
(2, 'Samsung Galaxy S24', 'Smartphone Samsung de gama alta con pantalla AMOLED.', 3199900, 9),
(2, 'Apple AirPods Pro 2', 'Audífonos inalámbricos con cancelación activa de ruido.', 1099900, 17),
(3, 'Silla Ergonómica Executive', 'Silla de oficina con soporte lumbar ajustable.', 749900, 16),
(3, 'Escritorio Modular 120 cm', 'Escritorio modular para oficina y teletrabajo.', 629900, 8),
(3, 'Archivador Metálico 4 Gavetas', 'Archivador metálico para documentos empresariales.', 589900, 6),
(4, 'MacBook Air M3', 'Portátil Apple con procesador M3 y pantalla Retina.', 4899900, 7),
(4, 'iPad Air M2', 'Tableta Apple para productividad y entretenimiento.', 2899900, 12),
(5, 'Smart TV Samsung 55 pulgadas', 'Televisor inteligente Samsung de 55 pulgadas.', 2399900, 10),
(5, 'Barra de Sonido JBL Cinema', 'Sistema de sonido para entretenimiento en el hogar.', 1299900, 13);
GO


--   ADMINISTRADORES

INSERT INTO CORE.ADMINISTRADOR
(
    Nombre,
    Apellido,
    Correo
)
VALUES
('Ricardo', 'Salazar', 'ricardo.salazar@axiam.co'),
('Paula', 'Vargas', 'paula.vargas@axiam.co'),
('Mauricio', 'Londoño', 'mauricio.londono@axiam.co'),
('Carolina', 'Becerra', 'carolina.becerra@axiam.co'),
('Julián', 'Suárez', 'julian.suarez@axiam.co');
GO


--  ADMINISTRADOR - TIENDA

INSERT INTO SECURITY.ADMINISTRADOR_TIENDA
(
    AdministradorID,
    TiendaID
)
VALUES
(1, 1),
(1, 2),
(2, 2),
(2, 3),
(3, 3),
(4, 4),
(4, 5),
(5, 1),
(5, 5);
GO


--  PEDIDOS
  
INSERT INTO COMMERCE.PEDIDO
(
    ClienteID,
    FechaPedido,
    Estado
)
VALUES
(1, '2026-08-20 09:15:00', 'ENTREGADO'),
(2, '2026-08-22 14:30:00', 'CONFIRMADO'),
(3, '2026-08-24 10:45:00', 'ENVIADO'),
(4, '2026-08-25 16:20:00', 'PENDIENTE'),
(5, '2026-08-26 11:10:00', 'ENTREGADO'),
(6, '2026-08-27 13:40:00', 'CONFIRMADO'),
(7, '2026-08-28 09:50:00', 'ENVIADO'),
(8, '2026-08-29 15:25:00', 'CANCELADO'),
(9, '2026-08-30 12:05:00', 'ENTREGADO'),
(10, '2026-08-31 17:10:00', 'PENDIENTE');
GO


--  DETALLE DE PEDIDOS

INSERT INTO COMMERCE.DETALLE_PEDIDO
(
    PedidoID,
    ProductoID,
    Cantidad,
    PrecioUnitario
)
VALUES
(1, 1, 1, 2899900),
(1, 3, 1, 449900),
(2, 4, 1, 3299900),
(2, 6, 2, 1099900),
(3, 5, 1, 3199900),
(3, 2, 1, 899900),
(4, 7, 2, 749900),
(5, 10, 1, 4899900),
(5, 11, 1, 2899900),
(6, 12, 1, 2399900),
(6, 13, 1, 1299900),
(7, 8, 1, 629900),
(7, 9, 1, 589900),
(8, 6, 1, 1099900),
(9, 2, 2, 899900),
(9, 3, 1, 449900),
(10, 11, 1, 2899900);
GO