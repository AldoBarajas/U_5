/*
  UNIDAD 3 - BIBLIOTECA ESCOLAR - ESQUEMA FISICO PARA MICROSOFT SQL SERVER 2022 / EXPRESS
  Adaptacion del archivo original schema.sql (PostgreSQL 14+) a T-SQL.
  Uso: abrir en SQL Server Management Studio y ejecutar en una instancia SQL Server.
  SEGURIDAD: crea una base de datos solo si no existe; NO borra bases ni tablas.
  IMPORTANTE: ejecutar en una base sin tablas previas de este proyecto.

  Alcance: 12 tablas, 11 claves foraneas, restricciones CHECK, claves unicas,
  indice filtrado de prestamo activo, 5 indices secundarios y 3 vistas.
  Conserva la especializacion DISJUNTA mediante FK compuesta mas CHECK.
  SQL Server no ofrece triggers diferibles hasta COMMIT. Las obligaciones de
  existencia TOTAL del subtipo y de al menos un autor por libro requieren
  operaciones de registro controladas por transaccion/procedimientos.
*/

IF DB_ID(N'BibliotecaEscolar_U3') IS NULL
    EXEC(N'CREATE DATABASE [BibliotecaEscolar_U3]');
GO
USE [BibliotecaEscolar_U3];
GO

IF SCHEMA_ID(N'biblioteca') IS NULL
    EXEC(N'CREATE SCHEMA biblioteca');
GO

-- 1. SUPERTIPO: PERSONA
CREATE TABLE biblioteca.persona (
    id_persona BIGINT IDENTITY(1,1) NOT NULL,
    nombres VARCHAR(80) NOT NULL,
    apellido_paterno VARCHAR(80) NOT NULL,
    apellido_materno VARCHAR(80) NULL,
    correo VARCHAR(254) NOT NULL,
    tipo_persona VARCHAR(12) NOT NULL,
    CONSTRAINT pk_persona PRIMARY KEY (id_persona),
    CONSTRAINT uq_persona_correo UNIQUE (correo),
    CONSTRAINT uq_persona_id_tipo UNIQUE (id_persona, tipo_persona),
    CONSTRAINT ck_persona_nombres CHECK (
        LEN(LTRIM(RTRIM(nombres))) > 0 AND
        LEN(LTRIM(RTRIM(apellido_paterno))) > 0
    ),
    CONSTRAINT ck_persona_tipo CHECK (tipo_persona IN ('ESTUDIANTE', 'DOCENTE'))
);
GO

-- 2. SUBTIPO ESTUDIANTE
CREATE TABLE biblioteca.estudiante (
    id_persona BIGINT NOT NULL,
    tipo_persona VARCHAR(12) NOT NULL CONSTRAINT df_estudiante_tipo DEFAULT ('ESTUDIANTE'),
    matricula VARCHAR(20) NOT NULL,
    semestre SMALLINT NOT NULL,
    CONSTRAINT pk_estudiante PRIMARY KEY (id_persona),
    CONSTRAINT uq_estudiante_matricula UNIQUE (matricula),
    CONSTRAINT ck_estudiante_tipo CHECK (tipo_persona = 'ESTUDIANTE'),
    CONSTRAINT ck_estudiante_semestre CHECK (semestre BETWEEN 1 AND 16),
    CONSTRAINT fk_estudiante_persona FOREIGN KEY (id_persona, tipo_persona)
        REFERENCES biblioteca.persona (id_persona, tipo_persona)
        ON UPDATE NO ACTION ON DELETE CASCADE
);
GO

-- 3. SUBTIPO DOCENTE
CREATE TABLE biblioteca.docente (
    id_persona BIGINT NOT NULL,
    tipo_persona VARCHAR(12) NOT NULL CONSTRAINT df_docente_tipo DEFAULT ('DOCENTE'),
    numero_empleado VARCHAR(20) NOT NULL,
    departamento VARCHAR(100) NOT NULL,
    CONSTRAINT pk_docente PRIMARY KEY (id_persona),
    CONSTRAINT uq_docente_numero UNIQUE (numero_empleado),
    CONSTRAINT ck_docente_tipo CHECK (tipo_persona = 'DOCENTE'),
    CONSTRAINT ck_docente_departamento CHECK (LEN(LTRIM(RTRIM(departamento))) > 0),
    CONSTRAINT fk_docente_persona FOREIGN KEY (id_persona, tipo_persona)
        REFERENCES biblioteca.persona (id_persona, tipo_persona)
        ON UPDATE NO ACTION ON DELETE CASCADE
);
GO

-- 4. TELEFONOS: ATRIBUTO MULTIVALORADO DE PERSONA
CREATE TABLE biblioteca.persona_telefono (
    id_persona BIGINT NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    CONSTRAINT pk_persona_telefono PRIMARY KEY (id_persona, telefono),
    CONSTRAINT ck_telefono_no_vacio CHECK (
        LEN(LTRIM(RTRIM(telefono))) BETWEEN 7 AND 20
    ),
    CONSTRAINT fk_telefono_persona FOREIGN KEY (id_persona)
        REFERENCES biblioteca.persona (id_persona)
        ON UPDATE CASCADE ON DELETE CASCADE
);
GO

-- 5. LIBRO
-- Se admite ISBN-13 (13 digitos) o ISBN-10 (9 digitos y uno final 0-9/X).
CREATE TABLE biblioteca.libro (
    isbn VARCHAR(17) NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    anio_publicacion SMALLINT NOT NULL,
    CONSTRAINT pk_libro PRIMARY KEY (isbn),
    CONSTRAINT ck_libro_isbn CHECK (
        (DATALENGTH(isbn) = 13 AND isbn NOT LIKE '%[^0-9]%') OR
        (DATALENGTH(isbn) = 10 AND LEFT(isbn, 9) NOT LIKE '%[^0-9]%' AND
         RIGHT(isbn, 1) LIKE '[0-9X]')
    ),
    CONSTRAINT ck_libro_titulo CHECK (LEN(LTRIM(RTRIM(titulo))) > 0),
    CONSTRAINT ck_libro_anio CHECK (anio_publicacion BETWEEN 1450 AND 2100)
);
GO

-- 6. AUTOR
CREATE TABLE biblioteca.autor (
    id_autor BIGINT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(160) NOT NULL,
    CONSTRAINT pk_autor PRIMARY KEY (id_autor),
    CONSTRAINT ck_autor_nombre CHECK (LEN(LTRIM(RTRIM(nombre))) > 0)
);
GO

-- 7. RELACION N:M LIBRO-AUTOR
CREATE TABLE biblioteca.libro_autor (
    isbn VARCHAR(17) NOT NULL,
    id_autor BIGINT NOT NULL,
    CONSTRAINT pk_libro_autor PRIMARY KEY (isbn, id_autor),
    CONSTRAINT fk_la_libro FOREIGN KEY (isbn)
        REFERENCES biblioteca.libro (isbn)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_la_autor FOREIGN KEY (id_autor)
        REFERENCES biblioteca.autor (id_autor)
        ON UPDATE CASCADE ON DELETE CASCADE
);
GO

-- 8. COLECCION
CREATE TABLE biblioteca.coleccion (
    id_coleccion BIGINT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    CONSTRAINT pk_coleccion PRIMARY KEY (id_coleccion),
    CONSTRAINT uq_coleccion_nombre UNIQUE (nombre),
    CONSTRAINT ck_coleccion_nombre CHECK (LEN(LTRIM(RTRIM(nombre))) > 0)
);
GO

-- 9. RELACION N:M LIBRO-COLECCION
CREATE TABLE biblioteca.libro_coleccion (
    isbn VARCHAR(17) NOT NULL,
    id_coleccion BIGINT NOT NULL,
    CONSTRAINT pk_libro_coleccion PRIMARY KEY (isbn, id_coleccion),
    CONSTRAINT fk_lc_libro FOREIGN KEY (isbn)
        REFERENCES biblioteca.libro (isbn)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_lc_coleccion FOREIGN KEY (id_coleccion)
        REFERENCES biblioteca.coleccion (id_coleccion)
        ON UPDATE CASCADE ON DELETE CASCADE
);
GO

-- 10. EJEMPLAR: CADA COPIA FISICA PERTENECE A UN LIBRO
CREATE TABLE biblioteca.ejemplar (
    id_ejemplar BIGINT IDENTITY(1,1) NOT NULL,
    isbn VARCHAR(17) NOT NULL,
    codigo_inventario VARCHAR(30) NOT NULL,
    estado VARCHAR(20) NOT NULL CONSTRAINT df_ejemplar_estado DEFAULT ('DISPONIBLE'),
    CONSTRAINT pk_ejemplar PRIMARY KEY (id_ejemplar),
    CONSTRAINT uq_ejemplar_codigo UNIQUE (codigo_inventario),
    CONSTRAINT ck_ejemplar_estado CHECK (estado IN ('DISPONIBLE', 'EN_REPARACION', 'BAJA')),
    CONSTRAINT fk_ejemplar_libro FOREIGN KEY (isbn)
        REFERENCES biblioteca.libro (isbn)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- 11. PRESTAMO: CONSERVA HISTORIAL (SIN BORRADO CASCADA)
CREATE TABLE biblioteca.prestamo (
    id_prestamo BIGINT IDENTITY(1,1) NOT NULL,
    id_persona BIGINT NOT NULL,
    id_ejemplar BIGINT NOT NULL,
    fecha_salida DATE NOT NULL,
    fecha_limite DATE NOT NULL,
    fecha_devolucion DATE NULL,
    CONSTRAINT pk_prestamo PRIMARY KEY (id_prestamo),
    CONSTRAINT ck_prestamo_fechas CHECK (
        fecha_limite >= fecha_salida AND
        (fecha_devolucion IS NULL OR fecha_devolucion >= fecha_salida)
    ),
    CONSTRAINT fk_prestamo_persona FOREIGN KEY (id_persona)
        REFERENCES biblioteca.persona (id_persona)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_prestamo_ejemplar FOREIGN KEY (id_ejemplar)
        REFERENCES biblioteca.ejemplar (id_ejemplar)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Impide dos prestamos simultaneos del mismo ejemplar.
CREATE UNIQUE INDEX ux_prestamo_ejemplar_activo
    ON biblioteca.prestamo (id_ejemplar)
    WHERE fecha_devolucion IS NULL;
GO

-- 12. INCIDENCIA: CONSERVA HISTORIAL
CREATE TABLE biblioteca.incidencia (
    id_incidencia BIGINT IDENTITY(1,1) NOT NULL,
    id_prestamo BIGINT NOT NULL,
    tipo VARCHAR(12) NOT NULL,
    fecha DATE NOT NULL,
    observacion VARCHAR(MAX) NOT NULL,
    CONSTRAINT pk_incidencia PRIMARY KEY (id_incidencia),
    CONSTRAINT ck_incidencia_tipo CHECK (tipo IN ('DANO', 'PERDIDA', 'RETRASO', 'OTRA')),
    CONSTRAINT ck_incidencia_observacion CHECK (LEN(LTRIM(RTRIM(observacion))) > 0),
    CONSTRAINT fk_incidencia_prestamo FOREIGN KEY (id_prestamo)
        REFERENCES biblioteca.prestamo (id_prestamo)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Indices adicionales para consultas y combinaciones (JOIN).
CREATE INDEX ix_prestamo_persona ON biblioteca.prestamo (id_persona);
CREATE INDEX ix_incidencia_prestamo ON biblioteca.incidencia (id_prestamo);
CREATE INDEX ix_ejemplar_isbn ON biblioteca.ejemplar (isbn);
CREATE INDEX ix_la_autor ON biblioteca.libro_autor (id_autor);
CREATE INDEX ix_lc_coleccion ON biblioteca.libro_coleccion (id_coleccion);
GO

-- Subtipos: SQL Server no puede aplazar la verificacion hasta COMMIT como PostgreSQL.
-- Estas operaciones transaccionales insertan Persona y subtipo juntos.
-- Para una garantia TOTAL universal, deben limitarse las inserciones directas
-- y obligarse a registrar Personas mediante estos procedimientos.
CREATE OR ALTER PROCEDURE biblioteca.registrar_estudiante
    @nombres VARCHAR(80),
    @apellido_paterno VARCHAR(80),
    @apellido_materno VARCHAR(80) = NULL,
    @correo VARCHAR(254),
    @matricula VARCHAR(20),
    @semestre SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO biblioteca.persona
            (nombres, apellido_paterno, apellido_materno, correo, tipo_persona)
        VALUES (@nombres, @apellido_paterno, @apellido_materno, @correo, 'ESTUDIANTE');
        DECLARE @id_persona BIGINT = CONVERT(BIGINT, SCOPE_IDENTITY());
        INSERT INTO biblioteca.estudiante (id_persona, tipo_persona, matricula, semestre)
        VALUES (@id_persona, 'ESTUDIANTE', @matricula, @semestre);
        COMMIT TRANSACTION;
        SELECT @id_persona AS id_persona;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE biblioteca.registrar_docente
    @nombres VARCHAR(80),
    @apellido_paterno VARCHAR(80),
    @apellido_materno VARCHAR(80) = NULL,
    @correo VARCHAR(254),
    @numero_empleado VARCHAR(20),
    @departamento VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO biblioteca.persona
            (nombres, apellido_paterno, apellido_materno, correo, tipo_persona)
        VALUES (@nombres, @apellido_paterno, @apellido_materno, @correo, 'DOCENTE');
        DECLARE @id_persona BIGINT = CONVERT(BIGINT, SCOPE_IDENTITY());
        INSERT INTO biblioteca.docente (id_persona, tipo_persona, numero_empleado, departamento)
        VALUES (@id_persona, 'DOCENTE', @numero_empleado, @departamento);
        COMMIT TRANSACTION;
        SELECT @id_persona AS id_persona;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Registra un Libro con su primer Autor en la misma transaccion.
-- Para garantizar totalmente la regla de >=1 autor deben restringirse
-- las operaciones directas sobre las tablas y usarse operaciones controladas.
CREATE OR ALTER PROCEDURE biblioteca.registrar_libro_con_autor
    @isbn VARCHAR(17),
    @titulo VARCHAR(200),
    @anio_publicacion SMALLINT,
    @id_autor BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO biblioteca.libro (isbn, titulo, anio_publicacion)
        VALUES (@isbn, @titulo, @anio_publicacion);
        INSERT INTO biblioteca.libro_autor (isbn, id_autor)
        VALUES (@isbn, @id_autor);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Vistas de datos derivados, sin columnas redundantes.
CREATE VIEW biblioteca.vw_libro_antiguedad
AS
SELECT isbn, titulo, anio_publicacion,
       YEAR(GETDATE()) - anio_publicacion AS edad_obra
FROM biblioteca.libro;
GO

CREATE VIEW biblioteca.vw_prestamo_atraso
AS
SELECT id_prestamo, id_persona, id_ejemplar,
       fecha_salida, fecha_limite, fecha_devolucion,
       CASE
           WHEN DATEDIFF(DAY, fecha_limite, ISNULL(fecha_devolucion, CAST(GETDATE() AS DATE))) > 0
               THEN DATEDIFF(DAY, fecha_limite, ISNULL(fecha_devolucion, CAST(GETDATE() AS DATE)))
           ELSE 0
       END AS dias_atraso
FROM biblioteca.prestamo;
GO

CREATE VIEW biblioteca.vw_disponibilidad
AS
SELECT e.id_ejemplar, e.codigo_inventario, e.isbn, e.estado,
       CAST(CASE
           WHEN e.estado = 'DISPONIBLE' AND NOT EXISTS (
               SELECT 1 FROM biblioteca.prestamo AS p
               WHERE p.id_ejemplar = e.id_ejemplar AND p.fecha_devolucion IS NULL
           ) THEN 1 ELSE 0
       END AS BIT) AS disponible
FROM biblioteca.ejemplar AS e;
GO

-- RESUMEN DE VALIDACION (deben aparecer 12 tablas y 11 claves foraneas).
SELECT COUNT(*) AS tablas_biblioteca
FROM sys.tables AS t
JOIN sys.schemas AS s ON s.schema_id = t.schema_id
WHERE s.name = 'biblioteca';

SELECT COUNT(*) AS llaves_foraneas
FROM sys.foreign_keys AS f
JOIN sys.tables AS t ON t.object_id = f.parent_object_id
JOIN sys.schemas AS s ON s.schema_id = t.schema_id
WHERE s.name = 'biblioteca';

SELECT s.name AS esquema, t.name AS tabla
FROM sys.tables AS t
JOIN sys.schemas AS s ON s.schema_id = t.schema_id
WHERE s.name = 'biblioteca'
ORDER BY t.name;
GO
