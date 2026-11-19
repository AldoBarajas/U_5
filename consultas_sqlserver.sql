-- UNIDAD 5.2 - CONSULTAS T-SQL SOBRE LAS TABLAS REALES DEL PROYECTO
-- Compatible con SQL Server 2022 / Express y esquema [biblioteca].
-- REQUISITOS: primero ejecutar schema_sqlserver.sql de Unidad 3.
-- Si la base no existe o las tablas estan vacias, revise la GUIA_ANTES_DE_EJECUTAR.md.
-- No modifica registros. Todas las consultas son SELECT.
IF DB_ID(N'BibliotecaEscolar_U3') IS NULL
    THROW 50001, N'No existe BibliotecaEscolar_U3. Ejecute primero schema_sqlserver.sql de la Unidad 3.', 1;
GO
USE [BibliotecaEscolar_U3];
GO
IF OBJECT_ID(N'biblioteca.libro', N'U') IS NULL OR OBJECT_ID(N'biblioteca.persona', N'U') IS NULL
    THROW 50002, N'No estan las tablas biblioteca.libro o biblioteca.persona. Verifique la Unidad 3.', 1;
GO

-- Q01 - Libros publicados desde 2020
-- Obtener ISBN y titulo de los libros publicados a partir de 2020.
SELECT DISTINCT l.isbn, l.titulo FROM biblioteca.libro AS l WHERE l.anio_publicacion >= 2020;
GO

-- Q02 - Estudiantes de quinto semestre o superior
-- Listar nombres y matriculas de estudiantes que cursan quinto semestre en adelante.
SELECT DISTINCT p.nombres, e.matricula FROM biblioteca.persona AS p JOIN biblioteca.estudiante AS e ON p.id_persona = e.id_persona WHERE e.semestre >= 5;
GO

-- Q03 - Libros con sus autores
-- Mostrar cada libro y los autores que lo escribieron, incluyendo los libros con varios autores.
SELECT DISTINCT l.titulo, a.nombre AS autor FROM biblioteca.libro AS l JOIN biblioteca.libro_autor AS la ON l.isbn = la.isbn JOIN biblioteca.autor AS a ON la.id_autor = a.id_autor;
GO

-- Q04 - Ejemplares disponibles para prestar
-- Identificar copias con estado DISPONIBLE que no tengan un prestamo activo.
SELECT DISTINCT e.id_ejemplar, e.codigo_inventario FROM biblioteca.ejemplar AS e WHERE e.estado = 'DISPONIBLE' AND NOT EXISTS (SELECT 1 FROM biblioteca.prestamo AS p WHERE p.id_ejemplar = e.id_ejemplar AND p.fecha_devolucion IS NULL);
GO

-- Q05 - Libros que nunca se han prestado
-- Localizar titulos que no registran ningun prestamo historico de cualquiera de sus ejemplares.
SELECT DISTINCT l.titulo FROM biblioteca.libro AS l WHERE NOT EXISTS (SELECT 1 FROM biblioteca.ejemplar AS e JOIN biblioteca.prestamo AS p ON p.id_ejemplar = e.id_ejemplar WHERE e.isbn = l.isbn);
GO

-- Q06 - Libros de Ciencia o Literatura (union)
-- Obtener titulos pertenecientes al menos a una de las colecciones Ciencia o Literatura.
SELECT DISTINCT l.titulo FROM biblioteca.libro AS l WHERE l.isbn IN (SELECT lc.isbn FROM biblioteca.libro_coleccion AS lc JOIN biblioteca.coleccion AS c ON c.id_coleccion = lc.id_coleccion WHERE c.nombre = 'Ciencia' UNION SELECT lc.isbn FROM biblioteca.libro_coleccion AS lc JOIN biblioteca.coleccion AS c ON c.id_coleccion = lc.id_coleccion WHERE c.nombre = 'Literatura');
GO

-- Q07 - Libros presentes en Ciencia y Literatura
-- Obtener titulos que pertenezcan simultaneamente a las dos colecciones.
SELECT DISTINCT l.titulo FROM biblioteca.libro AS l WHERE l.isbn IN (SELECT lc.isbn FROM biblioteca.libro_coleccion AS lc JOIN biblioteca.coleccion AS c ON c.id_coleccion = lc.id_coleccion WHERE c.nombre = 'Ciencia' INTERSECT SELECT lc.isbn FROM biblioteca.libro_coleccion AS lc JOIN biblioteca.coleccion AS c ON c.id_coleccion = lc.id_coleccion WHERE c.nombre = 'Literatura');
GO

-- Q08 - Division: libros en todas las colecciones exigidas
-- Buscar los libros incluidos en cada una de las colecciones requeridas: Ciencia y Literatura.
SELECT DISTINCT l.titulo FROM biblioteca.libro AS l WHERE NOT EXISTS (SELECT 1 FROM biblioteca.coleccion AS c WHERE c.nombre IN ('Ciencia', 'Literatura') AND NOT EXISTS (SELECT 1 FROM biblioteca.libro_coleccion AS lc WHERE lc.isbn = l.isbn AND lc.id_coleccion = c.id_coleccion));
GO

-- Q09 - Numero de ejemplares por libro (agrupacion)
-- Contar ejemplares por libro incluyendo titulos sin copias registradas.
SELECT l.titulo, COUNT(e.id_ejemplar) AS total_ejemplares FROM biblioteca.libro AS l LEFT JOIN biblioteca.ejemplar AS e ON e.isbn = l.isbn GROUP BY l.isbn, l.titulo;
GO

-- Q10 - Prestamos activos con lector y titulo
-- Identificar el prestamo activo, nombre del lector y titulo del libro correspondiente.
SELECT DISTINCT pr.id_prestamo, p.nombres, l.titulo FROM biblioteca.prestamo AS pr JOIN biblioteca.persona AS p ON p.id_persona = pr.id_persona JOIN biblioteca.ejemplar AS e ON e.id_ejemplar = pr.id_ejemplar JOIN biblioteca.libro AS l ON l.isbn = e.isbn WHERE pr.fecha_devolucion IS NULL;
GO

-- Q11 - Personas que no han solicitado prestamos
-- Encontrar personas sin movimientos historicos de prestamo.
SELECT DISTINCT p.nombres, p.apellido_paterno FROM biblioteca.persona AS p WHERE NOT EXISTS (SELECT 1 FROM biblioteca.prestamo AS pr WHERE pr.id_persona = p.id_persona);
GO

-- Q12 - Autores, incluso quienes no tienen libros
-- Conservar todos los autores registrados, aun si no tienen obras vinculadas.
SELECT DISTINCT a.nombre AS autor, l.titulo FROM biblioteca.autor AS a LEFT JOIN biblioteca.libro_autor AS la ON la.id_autor = a.id_autor LEFT JOIN biblioteca.libro AS l ON l.isbn = la.isbn;
GO

-- Q13 - Prestamos e incidencias (reunion externa)
-- Listar todos los prestamos, tengan o no incidencia reportada.
SELECT DISTINCT pr.id_prestamo, i.tipo AS incidencia FROM biblioteca.prestamo AS pr LEFT JOIN biblioteca.incidencia AS i ON i.id_prestamo = pr.id_prestamo;
GO

-- Q14 - Producto cartesiano de lectores y novedades
-- Generar combinaciones potenciales entre estudiantes de semestre 5+ y libros publicados desde 2023.
SELECT DISTINCT p.nombres, l.titulo FROM biblioteca.persona AS p JOIN biblioteca.estudiante AS e ON p.id_persona = e.id_persona CROSS JOIN biblioteca.libro AS l WHERE e.semestre >= 5 AND l.anio_publicacion >= 2023;
GO

-- Q15 - Proyeccion generalizada: antiguedad en 2026
-- Calcular los anos transcurridos entre el ano de publicacion y el ano 2026.
SELECT DISTINCT l.titulo, 2026 - l.anio_publicacion AS antiguedad FROM biblioteca.libro AS l;
GO

-- Q16 - Consulta compleja: titulos de Ciencia escritos por Ada desde 2020
-- Obtener titulos de Ciencia posteriores a 2019 en cuya autoria aparezca Ada Nieto.
SELECT DISTINCT l.titulo FROM biblioteca.libro AS l JOIN biblioteca.libro_coleccion AS lc ON lc.isbn = l.isbn JOIN biblioteca.coleccion AS c ON c.id_coleccion = lc.id_coleccion JOIN biblioteca.libro_autor AS la ON la.isbn = l.isbn JOIN biblioteca.autor AS a ON a.id_autor = la.id_autor WHERE c.nombre = 'Ciencia' AND a.nombre = 'Ada Nieto' AND l.anio_publicacion >= 2020;
GO
