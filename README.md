# AXIAM CORE DB

Sistema de gestión de clientes, tiendas, productos y pedidos desarrollado sobre Microsoft SQL Server como propuesta de solución para una plataforma de comercio electrónico de una empresa emergente.

## 1. Descripción del proyecto

AXIAM CORE DB es una solución de base de datos relacional diseñada para soportar las operaciones principales de una plataforma de comercio electrónico con capacidad para manejar múltiples clientes, tiendas, productos, administradores, pedidos y direcciones de envío.

El proyecto surge como respuesta al caso de estudio:

> Diseñando la base de datos de una empresa emergente

La plataforma debe permitir gestionar miles de transacciones diarias y mantener relaciones consistentes entre clientes, direcciones, tiendas, productos, pedidos y administradores.

Para el núcleo transaccional del sistema se seleccionó Microsoft SQL Server debido a sus capacidades de:

* Integridad referencial.
* Transacciones ACID.
* Control de concurrencia.
* Indexación y optimización de consultas.
* Procedimientos almacenados.
* Triggers.
* Control de acceso mediante roles y permisos.
* Auditoría.
* Respaldo y recuperación.
* Escalabilidad vertical y posibilidades de escalamiento horizontal mediante arquitectura complementaria.

La solución utiliza un modelo relacional normalizado y organizado mediante esquemas para separar responsabilidades dentro de la base de datos.

---

# 2. Información académica

**Asignatura:** Administración de Bases de Datos

**Institución:** CUN - Corporación Unificada Nacional

**Programa:** Ingeniería de Sistemas

**Grupo:** 54426

**Bloque:** Primer Bloque

**Periodo:** 26P04

## Desarrolladores

* JHONATTAN HALCON CASALLAS FELIPE
* JUAN SEBASTIAN MUÑOZ ORDOÑEZ

---

# 3. Objetivos

## 3.1 Objetivo general

Diseñar e implementar una base de datos relacional para una plataforma de comercio electrónico, garantizando integridad, consistencia, trazabilidad y capacidad de consulta sobre la información generada por las operaciones del negocio.

## 3.2 Objetivos específicos

* Diseñar un modelo de datos normalizado.
* Definir las relaciones entre clientes, direcciones, tiendas, productos, pedidos y administradores.
* Implementar la base de datos utilizando Microsoft SQL Server.
* Establecer restricciones de integridad para proteger la información.
* Implementar índices para mejorar el rendimiento de las consultas.
* Utilizar procedimientos almacenados para centralizar operaciones frecuentes.
* Implementar triggers para automatizar procesos.
* Implementar mecanismos básicos de auditoría.
* Crear consultas SQL para explotación y análisis de información.
* Establecer una estrategia básica de seguridad, respaldo y recuperación.
* Analizar la utilización de SQL y NoSQL dentro de la arquitectura propuesta.

---

# 4. Selección del modelo de datos

Para AXIAM CORE se seleccionó un modelo relacional como núcleo principal de la solución.

La decisión se basa principalmente en la naturaleza transaccional de las operaciones.

El sistema requiere mantener relaciones consistentes entre:

* Clientes y sus direcciones.
* Clientes y sus pedidos.
* Pedidos y sus detalles.
* Productos y sus tiendas.
* Administradores y tiendas.
* Productos y detalles de pedidos.

Además, operaciones como la creación de pedidos y el registro de sus detalles requieren consistencia transaccional.

Por estas razones, SQL Server proporciona características adecuadas para el núcleo operacional de la plataforma.

## SQL frente a NoSQL

NoSQL no se considera una tecnología incompatible con la solución. Puede incorporarse posteriormente para escenarios donde exista información altamente variable, grandes volúmenes de datos no estructurados o necesidades específicas de distribución y escalabilidad.

Algunos posibles usos complementarios de NoSQL serían:

* Eventos de navegación.
* Historial de comportamiento de usuarios.
* Recomendaciones de productos.
* Datos utilizados por agentes de inteligencia artificial.
* Catálogos altamente variables.
* Datos temporales o semiestructurados.
* Sistemas distribuidos que requieran alta disponibilidad geográfica.

La decisión arquitectónica es utilizar SQL Server como núcleo transaccional y considerar NoSQL como complemento cuando las necesidades específicas lo justifiquen.

---

# 5. Arquitectura lógica de la base de datos

La base de datos se organiza mediante cuatro esquemas:

```text
AXIAM_CORE_DB
│
├── CORE
│   ├── CLIENTE
│   ├── DIRECCION
│   └── ADMINISTRADOR
│
├── COMMERCE
│   ├── TIENDA
│   ├── PRODUCTO
│   ├── PEDIDO
│   └── DETALLE_PEDIDO
│
├── SECURITY
│   └── ADMINISTRADOR_TIENDA
│
└── AUDIT
    └── LOG_OPERACION
```

## CORE

Contiene las entidades principales relacionadas con clientes, direcciones y administradores.

## COMMERCE

Contiene las entidades relacionadas directamente con la operación comercial:

* Tiendas.
* Productos.
* Pedidos.
* Detalles de pedidos.

## SECURITY

Contiene las estructuras relacionadas con asignaciones y control de acceso dentro del modelo.

## AUDIT

Contiene la información generada por los mecanismos de auditoría.

---

# 6. Modelo relacional

Las principales relaciones del sistema son:

| Relación                  | Cardinalidad |
| ------------------------- | ------------ |
| CLIENTE - DIRECCION       | 1:N          |
| CLIENTE - PEDIDO          | 1:N          |
| PEDIDO - DETALLE_PEDIDO   | 1:N          |
| PRODUCTO - DETALLE_PEDIDO | 1:N          |
| TIENDA - PRODUCTO         | 1:N          |
| ADMINISTRADOR - TIENDA    | N:M          |

La relación entre ADMINISTRADOR y TIENDA se implementa mediante la tabla intermedia:

```text
ADMINISTRADOR
      |
      | 1:N
      |
ADMINISTRADOR_TIENDA
      |
      | N:1
      |
    TIENDA
```

La tabla `ADMINISTRADOR_TIENDA` permite que:

* Un administrador pueda estar asignado a varias tiendas.
* Una tienda pueda tener varios administradores.
* No se puedan registrar asignaciones duplicadas.

---

# 7. Normalización

El modelo se encuentra estructurado siguiendo principios de normalización.

## Primera Forma Normal

Las entidades mantienen atributos atómicos y no almacenan múltiples valores dentro de una misma columna.

Por ejemplo, las diferentes direcciones de un cliente se almacenan como registros independientes en `DIRECCION`.

## Segunda Forma Normal

Los atributos dependen de la totalidad de la clave primaria correspondiente.

La información relacionada con los detalles de los pedidos se mantiene separada de la información general del pedido.

## Tercera Forma Normal

Se evita almacenar información redundante o dependencias transitivas.

Por ejemplo:

* La información del cliente pertenece a `CLIENTE`.
* La información de la tienda pertenece a `TIENDA`.
* El producto referencia a la tienda mediante `TiendaID`.
* El pedido referencia al cliente mediante `ClienteID`.

Esto permite reducir duplicidad y facilitar el mantenimiento de la información.

---

# 8. Componentes implementados

El proyecto contiene los siguientes componentes principales:

## DDL

Define la estructura de la base de datos:

* Base de datos.
* Esquemas.
* Tablas.
* Claves primarias.
* Claves foráneas.
* Restricciones.
* Índices.
* Triggers.
* Tabla de auditoría.

## DML

Contiene datos representativos para validar el modelo.

Se incluyen:

* Clientes.
* Direcciones.
* Tiendas.
* Productos.
* Administradores.
* Asignaciones administrador-tienda.
* Pedidos.
* Detalles de pedidos.

Los datos fueron diseñados para representar diferentes relaciones y escenarios del modelo.

## Procedimientos almacenados

Se implementaron procedimientos para encapsular operaciones frecuentes sobre las principales entidades del sistema.

## Consultas SQL

Se implementaron consultas orientadas a:

* Relaciones entre entidades.
* Filtrado.
* Agrupación.
* Agregación.
* Análisis de ventas.
* Análisis de productos.
* Pedidos.
* Administradores.
* Auditoría.

## Triggers

Se implementaron mecanismos automáticos para:

* Registrar operaciones realizadas sobre determinadas entidades.
* Mantener actualizado el total de los pedidos cuando se modifican sus detalles.

---

# 9. Estructura recomendada del repositorio

La organización del repositorio puede mantenerse de la siguiente manera:

```text
AXIAM-CORE-DB/
│
├── README.md
│
├── SQL/
│   ├── 01_DDL.sql
│   ├── 02_DML.sql
│   ├── 03_Procedimientos_Almacenados.sql
│   ├── 04_Consultas.sql
│   └── 05_Pruebas_Triggers.sql
│
├── Diagrams/
│   ├── Modelo_ER
│   ├── Arquitectura
│   ├── Triggers
│   └── Procedimientos
│
└── Documentation/
    └── Documento_Academico.pdf
```

Los nombres pueden modificarse según la estructura final del repositorio, pero se recomienda mantener la numeración para conservar el orden de ejecución.

---

# 10. Orden de ejecución

Los scripts deben ejecutarse en el siguiente orden:

```text
01_DDL.sql
        ↓
02_DML.sql
        ↓
03_Procedimientos_Almacenados.sql
        ↓
04_Consultas.sql
        ↓
05_Pruebas_Triggers.sql
```

Este orden es importante porque cada etapa depende de la anterior.

---

# 11. Paso 1 - DDL

Archivo:

```text
01_DDL.sql
```

Este script crea la estructura completa de `AXIAM_CORE_DB`.

Incluye:

* Creación de la base de datos.
* Creación de esquemas.
* Creación de tablas.
* Claves primarias.
* Claves foráneas.
* Restricciones `CHECK`.
* Restricciones `UNIQUE`.
* Índices.
* Tabla de auditoría.
* Triggers.

La ejecución del DDL debe realizarse primero porque los siguientes scripts requieren que las tablas y estructuras ya existan.

---

# 12. Paso 2 - DML

Archivo:

```text
02_DML.sql
```

Este script realiza la carga inicial de datos representativos.

La información permite comprobar:

* Clientes con una o varias direcciones.
* Varias tiendas.
* Productos asociados a tiendas.
* Administradores asociados a una o varias tiendas.
* Tiendas con varios administradores.
* Pedidos en diferentes estados.
* Pedidos con múltiples detalles.
* Diferentes cantidades y precios.

Los datos no tienen únicamente el propósito de llenar las tablas, sino de permitir demostrar el comportamiento de las relaciones implementadas.

---

# 13. Paso 3 - Procedimientos almacenados

Archivo:

```text
03_Procedimientos_Almacenados.sql
```

Se implementan los siguientes procedimientos:

## CORE

### SP_CLIENTE_CREAR

Permite crear un nuevo cliente realizando validaciones antes de la inserción.

### SP_CLIENTE_OBTENER

Permite consultar un cliente mediante su identificador.

## COMMERCE

### SP_TIENDA_CREAR

Permite registrar una nueva tienda.

### SP_PRODUCTO_CREAR

Permite crear productos validando la existencia de la tienda y los valores correspondientes.

### SP_PRODUCTOS_POR_TIENDA

Obtiene los productos asociados a una tienda determinada.

### SP_PEDIDO_CREAR

Permite crear un nuevo pedido asociado a un cliente.

### SP_PEDIDO_AGREGAR_DETALLE

Permite agregar productos a un pedido validando la información correspondiente y utilizando el precio actual del producto.

### SP_PEDIDO_OBTENER

Permite consultar la información general de un pedido y sus detalles.

## SECURITY

### SP_ASIGNAR_ADMINISTRADOR

Permite asignar un administrador a una tienda validando la existencia de ambas entidades y evitando asignaciones duplicadas.

### SP_ADMINISTRADORES_POR_TIENDA

Obtiene los administradores asociados a una tienda.

---

# 14. Paso 4 - Consultas SQL

Archivo:

```text
04_Consultas.sql
```

El script contiene consultas diseñadas para demostrar diferentes capacidades de SQL Server.

Las consultas se ejecutan en el siguiente orden:

### 1. Clientes con sus direcciones

Demuestra la relación entre `CLIENTE` y `DIRECCION`.

### 2. Clientes con más de una dirección

Utiliza:

* `GROUP BY`
* `COUNT`
* `HAVING`

Permite identificar clientes que tienen múltiples direcciones registradas.

### 3. Productos y tienda

Relaciona productos con la tienda a la que pertenecen.

### 4. Productos con stock bajo

Permite identificar productos cuyo stock se encuentra por debajo del límite establecido en la consulta.

### 5. Pedidos con información del cliente

Relaciona los pedidos con sus respectivos clientes.

### 6. Detalle completo de pedidos

Relaciona:

```text
PEDIDO
CLIENTE
DETALLE_PEDIDO
PRODUCTO
TIENDA
```

Permite consultar la información completa de una operación comercial.

### 7. Total de ventas por tienda

Calcula el valor total de las ventas por tienda excluyendo pedidos cancelados.

Utiliza funciones de agregación y agrupación.

### 8. Productos más vendidos

Calcula la cantidad total de unidades vendidas por producto.

### 9. Administradores asignados a cada tienda

Demuestra la relación N:M entre administradores y tiendas mediante la tabla intermedia.

### 10. Cantidad de productos por tienda

Utiliza `LEFT JOIN` y `COUNT` para obtener la cantidad de productos asociados a cada tienda.

### 11. Cantidad de pedidos por estado

Agrupa los pedidos según su estado.

### 12. Pedidos superiores a un valor determinado

Permite identificar pedidos cuyo valor supera el monto establecido en la consulta.

### 13. Valor total comprado por cada cliente

Calcula la cantidad de pedidos y el valor comprado por cada cliente, excluyendo pedidos cancelados del cálculo.

### 14. Producto más caro de cada tienda

Utiliza una función de ventana:

```sql
ROW_NUMBER()
```

para determinar el producto de mayor precio dentro de cada tienda.

### 15. Auditoría

Consulta los registros generados en:

```text
AUDIT.LOG_OPERACION
```

Permitiendo revisar las operaciones registradas por los mecanismos de auditoría.

---

# 15. Paso 5 - Pruebas de triggers

Archivo:

```text
05_Pruebas_Triggers.sql
```

Este script debe ejecutarse después de los anteriores porque utiliza los datos previamente cargados.

Las pruebas se ejecutan en el mismo orden en que aparecen en el archivo.

## Prueba 1 - Auditoría de cliente

Se actualiza el teléfono del cliente con `ClienteID = 1`.

La operación:

```sql
UPDATE CORE.CLIENTE
SET Telefono = '3009998877'
WHERE ClienteID = 1;
```

debe activar el trigger de auditoría correspondiente.

Posteriormente se consulta:

```sql
SELECT *
FROM AUDIT.LOG_OPERACION
WHERE Tabla = 'CORE.CLIENTE'
ORDER BY LogID DESC;
```

El resultado esperado es la aparición de un nuevo registro de auditoría correspondiente a la operación `UPDATE`.

## Prueba 2 - Actualización automática del total del pedido

Se agrega un nuevo detalle al pedido con `PedidoID = 4`.

```sql
INSERT INTO COMMERCE.DETALLE_PEDIDO
(
    PedidoID,
    ProductoID,
    Cantidad,
    PrecioUnitario
)
VALUES
(4, 8, 1, 629900);
```

Esta operación debe activar el trigger encargado de mantener actualizado el total del pedido.

Posteriormente se consulta:

```sql
SELECT
    PedidoID,
    ClienteID,
    Total,
    Estado
FROM COMMERCE.PEDIDO
WHERE PedidoID = 4;
```

El valor de `Total` debe reflejar el nuevo detalle agregado.

---

# 16. Auditoría

AXIAM CORE DB incorpora una estructura de auditoría mediante:

```text
AUDIT.LOG_OPERACION
```

La tabla almacena información como:

* Identificador del registro de auditoría.
* Tabla afectada.
* Operación realizada.
* Identificador del registro afectado.
* Fecha de operación.
* Usuario de SQL Server.
* Detalle de la operación.

Esta estructura permite mantener trazabilidad sobre determinadas operaciones realizadas en la base de datos.

---

# 17. Triggers

Los triggers implementados permiten automatizar procesos que deben ejecutarse como consecuencia de determinadas modificaciones.

Entre ellos se encuentran:

```text
CORE.TR_CLIENTE_AUDIT
COMMERCE.TR_TIENDA_AUDIT
COMMERCE.TR_DETALLE_PEDIDO_TOTAL
```

## Auditoría

Los triggers de auditoría registran operaciones de:

```text
INSERT
UPDATE
DELETE
```

sobre las entidades configuradas.

## Actualización del total del pedido

El trigger asociado a `DETALLE_PEDIDO` recalcula el total correspondiente del pedido cuando se producen operaciones sobre sus detalles.

Conceptualmente:

```text
INSERT / UPDATE / DELETE
          |
          v
   DETALLE_PEDIDO
          |
          v
       TRIGGER
          |
          v
SUM(Cantidad x PrecioUnitario)
          |
          v
     PEDIDO.Total
```

Esto evita depender exclusivamente de la aplicación para mantener actualizado el total almacenado.

---

# 18. Seguridad

La estrategia de seguridad propuesta utiliza el principio de mínimo privilegio.

Se contemplan diferentes roles:

| Rol         | Responsabilidad                             |
| ----------- | ------------------------------------------- |
| DBA         | Administración completa de la base de datos |
| Application | Operaciones requeridas por la aplicación    |
| Operator    | Operaciones comerciales controladas         |
| Auditor     | Consulta de información y auditoría         |
| Development | Acceso controlado a ambientes de desarrollo |

Se recomienda mantener separados los ambientes:

```text
DESARROLLO
     |
     v
UAT / PRUEBAS
     |
     v
PRODUCCIÓN
```

Los usuarios y permisos deben asignarse de acuerdo con las responsabilidades reales de cada ambiente.

---

# 19. Estrategia de backups

Para garantizar la recuperación de la información se propone una estrategia basada en diferentes tipos de respaldo.

## Backup completo

Se recomienda realizar respaldos completos periódicos de la base de datos.

## Backup diferencial

Permite reducir el tiempo necesario para recuperar los cambios realizados desde el último backup completo.

## Backup del log de transacciones

Puede realizarse con una frecuencia mayor para reducir la pérdida potencial de información.

Una estrategia inicial puede contemplar:

```text
Backup completo
Semanal

Backup diferencial
Diario

Backup de log
Cada 15 - 30 minutos
```

La frecuencia definitiva debe establecerse de acuerdo con los requerimientos de disponibilidad del sistema.

También se recomienda aplicar una estrategia 3-2-1 y realizar pruebas periódicas de restauración.

---

# 20. Rendimiento y prevención de cuellos de botella

El diseño contempla diferentes mecanismos para reducir posibles problemas de rendimiento.

## Principales riesgos

* Consultas sin índices adecuados.
* Escaneos completos de tablas.
* Transacciones excesivamente largas.
* Bloqueos.
* Exceso de conexiones simultáneas.
* Consultas que recuperan información innecesaria.
* Crecimiento excesivo de la tabla de auditoría.
* Procesamiento elevado durante periodos de alta demanda.

## Estrategias propuestas

* Crear índices sobre columnas utilizadas frecuentemente en filtros y relaciones.
* Evitar `SELECT *` en consultas de aplicación.
* Utilizar transacciones cortas.
* Optimizar consultas.
* Controlar la cantidad de conexiones.
* Revisar planes de ejecución.
* Monitorear bloqueos.
* Aplicar estrategias de mantenimiento de índices.
* Evaluar archivado o particionamiento de información histórica cuando el volumen lo justifique.
* Controlar el crecimiento de la tabla de auditoría.

La arquitectura busca que la base de datos pueda crecer progresivamente sin comprometer las operaciones principales.

---

# 21. Arquitectura general

La operación propuesta puede representarse de la siguiente manera:

```text
Usuarios
   |
   v
Aplicación Web / Móvil
   |
   v
Autenticación y Autorización
   |
   v
API / Capa de Aplicación
   |
   v
Pool de Conexiones
   |
   v
SQL Server
   |
   v
AXIAM_CORE_DB
   |
   +-------------------+
   |                   |
   v                   v
CORE              COMMERCE
   |                   |
   +---------+---------+
             |
             v
         SECURITY
             |
             v
           AUDIT
```

La base de datos se complementa con:

```text
AXIAM_CORE_DB
   |
   +--> Backups
   |
   +--> Monitoreo
   |
   +--> Auditoría
   |
   +--> Índices
   |
   +--> Recuperación
```

---

# 22. Requisitos

Para ejecutar el proyecto se requiere:

* Microsoft SQL Server.
* SQL Server Management Studio (SSMS) o herramienta compatible.
* Permisos suficientes para crear una base de datos y sus objetos.
* Capacidad para ejecutar scripts T-SQL.

Se recomienda utilizar una instancia de SQL Server destinada a desarrollo o pruebas.

---

# 23. Instalación y ejecución

## Paso 1

Abrir SQL Server Management Studio y conectarse a la instancia de SQL Server.

## Paso 2

Abrir:

```text
01_DDL.sql
```

Ejecutar el script completo.

Verificar que se haya creado:

```text
AXIAM_CORE_DB
```

junto con sus esquemas, tablas, restricciones, índices y triggers.

## Paso 3

Abrir:

```text
02_DML.sql
```

Ejecutar el script completo para cargar los datos representativos.

## Paso 4

Abrir:

```text
03_Procedimientos_Almacenados.sql
```

Ejecutar el script para crear los procedimientos almacenados.

## Paso 5

Abrir:

```text
04_Consultas.sql
```

Ejecutar las consultas en el orden establecido.

## Paso 6

Abrir:

```text
05_Pruebas_Triggers.sql
```

Ejecutar las pruebas de funcionamiento de los triggers.

---

# 24. Dependencias entre scripts

El orden de ejecución debe mantenerse:

```text
01_DDL
  |
  | Crea estructura
  v
02_DML
  |
  | Inserta información
  v
03_PROCEDIMIENTOS
  |
  | Crea lógica encapsulada
  v
04_CONSULTAS
  |
  | Consulta información
  v
05_PRUEBAS_TRIGGERS
  |
  | Verifica automatizaciones
  v
RESULTADO FINAL
```

No se recomienda ejecutar los scripts de forma aleatoria porque existen dependencias entre las estructuras creadas y los datos utilizados posteriormente.

---

# 25. Resultado esperado

Al finalizar la ejecución de los scripts se debe disponer de una base de datos funcional con:

* Modelo relacional implementado.
* Relaciones entre entidades.
* Restricciones de integridad.
* Índices.
* Datos representativos.
* Procedimientos almacenados.
* Triggers.
* Auditoría.
* Consultas de análisis.
* Pruebas funcionales de triggers.

El resultado permite demostrar tanto el diseño estructural como la utilización práctica de las capacidades de Microsoft SQL Server.

---

# 26. Evidencias recomendadas

Para la documentación académica se recomienda incluir capturas de:

1. Creación de `AXIAM_CORE_DB`.
2. Estructura de los esquemas.
3. Tablas creadas.
4. Datos cargados.
5. Ejecución de procedimientos almacenados.
6. Consultas SQL.
7. Registro generado por el trigger de auditoría.
8. Actualización automática de `PEDIDO.Total`.
9. Modelo entidad-relación.
10. Arquitectura general.

Las capturas deben mostrar tanto el código ejecutado como el resultado cuando sea necesario.

---

# 27. Tecnologías utilizadas

| Tecnología                   | Uso                              |
| ---------------------------- | -------------------------------- |
| Microsoft SQL Server         | Sistema gestor de bases de datos |
| T-SQL                        | Lenguaje de implementación       |
| SQL Server Management Studio | Administración y ejecución       |
| Mermaid                      | Diagramación                     |
| Git                          | Control de versiones             |
| GitHub                       | Repositorio y documentación      |

---

# 28. Conclusión

AXIAM CORE DB propone una arquitectura relacional orientada a garantizar la integridad, consistencia y trazabilidad de la información generada por las operaciones principales de una plataforma de comercio electrónico.

Microsoft SQL Server fue seleccionado como SGBD principal debido a sus capacidades transaccionales, integridad referencial, seguridad, optimización, procedimientos almacenados, triggers y mecanismos de respaldo y recuperación.

El modelo implementado permite gestionar clientes, direcciones, tiendas, productos, pedidos y administradores mediante una estructura normalizada y organizada por esquemas.

La solución también contempla auditoría, control de acceso, estrategias de respaldo y medidas para prevenir problemas de rendimiento.

Aunque NoSQL puede aportar ventajas para determinadas necesidades futuras, como datos semiestructurados, eventos, recomendaciones o cargas distribuidas, el modelo relacional constituye una base adecuada para el núcleo transaccional de AXIAM CORE.

---

# 29. Autores

**JHONATTAN HALCON CASALLAS FELIPE**

**JUAN SEBASTIAN MUÑOZ ORDOÑEZ**

CUN - Corporación Unificada Nacional

Programa de Ingeniería de Sistemas
