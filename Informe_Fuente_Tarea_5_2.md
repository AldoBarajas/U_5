# Unidad 5 · Tarea 5.2 | Catálogo de 16 consultas

**Contexto:** Biblioteca escolar. Esquema de referencia: `Referencias_U3/schema_sqlserver_unidad3.sql`.
**Método:** construcción formal, relación intermedia por etapa, ejemplo de datos ficticios, comprobación con SQLite y versión T-SQL para SSMS.

> Los resultados son sobre datos sintéticos. No son una ejecución real de Microsoft SQL Server.

## Q01 — Libros publicados desde 2020
**Dificultad:** Basica
**Requerimiento:** Obtener ISBN y titulo de los libros publicados a partir de 2020.

**Expresión y pasos:**
- S = σ_{anio_publicacion ≥ 2020}(Libro)
- R = π_{isbn,titulo}(S)

**Relaciones intermedias comprobadas:**
- S: seleccion de libros: 5 filas; columnas isbn, titulo, anio_publicacion.
- R: proyeccion final: 5 filas; columnas isbn, titulo.
**Salida esperada en datos de prueba:** 5 filas; columnas isbn, titulo.
**Equivalente SQL:** `consultas_sqlserver.sql`, sección Q01.
**CSV de resultados:** `resultados_csv/Q01_resultado.csv`.

## Q02 — Estudiantes de quinto semestre o superior
**Dificultad:** Intermedia
**Requerimiento:** Listar nombres y matriculas de estudiantes que cursan quinto semestre en adelante.

**Expresión y pasos:**
- S = σ_{semestre ≥ 5}(Estudiante)
- R = π_{Persona.nombres, Estudiante.matricula}(Persona ⋈_{id_persona} S)

**Relaciones intermedias comprobadas:**
- S: filtro de subtipos: 2 filas; columnas id_persona, matricula, semestre.
- R: union con supertipo: 2 filas; columnas nombres, matricula.
**Salida esperada en datos de prueba:** 2 filas; columnas nombres, matricula.
**Equivalente SQL:** `consultas_sqlserver.sql`, sección Q02.
**CSV de resultados:** `resultados_csv/Q02_resultado.csv`.

## Q03 — Libros con sus autores
**Dificultad:** Intermedia
**Requerimiento:** Mostrar cada libro y los autores que lo escribieron, incluyendo los libros con varios autores.

**Expresión y pasos:**
- J1 = Libro ⋈_{Libro.isbn=LibroAutor.isbn} LibroAutor
- J2 = J1 ⋈_{LibroAutor.id_autor=Autor.id_autor} Autor
- R = π_{Libro.titulo,Autor.nombre}(J2)

**Relaciones intermedias comprobadas:**
- J1: libro con puente: 8 filas; columnas isbn, titulo, id_autor.
- J2: libro con autor: 8 filas; columnas titulo, nombre.
**Salida esperada en datos de prueba:** 8 filas; columnas titulo, autor.
**Equivalente SQL:** `consultas_sqlserver.sql`, sección Q03.
**CSV de resultados:** `resultados_csv/Q03_resultado.csv`.

## Q04 — Ejemplares disponibles para prestar
**Dificultad:** Compleja
**Requerimiento:** Identificar copias con estado DISPONIBLE que no tengan un prestamo activo.

**Expresión y pasos:**
- D = π_{id_ejemplar}(σ_{estado="DISPONIBLE"}(Ejemplar))
- O = π_{id_ejemplar}(σ_{fecha_devolucion IS NULL}(Prestamo))
- R = π_{id_ejemplar,codigo_inventario}(Ejemplar ⋈_{id_ejemplar} (D − O))

**Relaciones intermedias comprobadas:**
- D: copias en estado disponible: 7 filas; columnas id_ejemplar, codigo_inventario.
- O: copias ocupadas: 3 filas; columnas id_ejemplar.
- R: diferencia aplicada: 4 filas; columnas id_ejemplar, codigo_inventario.
**Salida esperada en datos de prueba:** 4 filas; columnas id_ejemplar, codigo_inventario.
**Equivalente SQL:** `consultas_sqlserver.sql`, sección Q04.
**CSV de resultados:** `resultados_csv/Q04_resultado.csv`.

## Q05 — Libros que nunca se han prestado
**Dificultad:** Compleja
**Requerimiento:** Localizar titulos que no registran ningun prestamo historico de cualquiera de sus ejemplares.

**Expresión y pasos:**
- T = π_{isbn}(Libro)
- U = π_{Ejemplar.isbn}(Ejemplar ⋈_{id_ejemplar} Prestamo)
- R = π_{titulo}(Libro ⋈_{isbn} (T − U))

**Relaciones intermedias comprobadas:**
- T: ISBN catalogados: 6 filas; columnas isbn.
- U: ISBN que se prestaron: 5 filas; columnas isbn.
- R: titulos sin movimientos: 1 filas; columnas titulo.
**Salida esperada en datos de prueba:** 1 filas; columnas titulo.
**Equivalente SQL:** `consultas_sqlserver.sql`, sección Q05.
**CSV de resultados:** `resultados_csv/Q05_resultado.csv`.

## Q06 — Libros de Ciencia o Literatura (union)
**Dificultad:** Intermedia
**Requerimiento:** Obtener titulos pertenecientes al menos a una de las colecciones Ciencia o Literatura.

**Expresión y pasos:**
- B_C = π_{isbn}(σ_{nombre="Ciencia"}(LibroColeccion ⋈ Coleccion))
- B_L = π_{isbn}(σ_{nombre="Literatura"}(LibroColeccion ⋈ Coleccion))
- R = π_{titulo}(Libro ⋈_{isbn} (B_C ∪ B_L))

**Relaciones intermedias comprobadas:**
- B_C: ISBN de Ciencia: 4 filas; columnas isbn.
- B_L: ISBN de Literatura: 3 filas; columnas isbn.
- R: union sin duplicados: 6 filas; columnas titulo.
**Salida esperada en datos de prueba:** 6 filas; columnas titulo.
**Equivalente SQL:** `consultas_sqlserver.sql`, sección Q06.
**CSV de resultados:** `resultados_csv/Q06_resultado.csv`.

## Q07 — Libros presentes en Ciencia y Literatura
**Dificultad:** Intermedia
**Requerimiento:** Obtener titulos que pertenezcan simultaneamente a las dos colecciones.

**Expresión y pasos:**
- B_C = π_{isbn}(σ_{nombre="Ciencia"}(LibroColeccion ⋈ Coleccion))
- B_L = π_{isbn}(σ_{nombre="Literatura"}(LibroColeccion ⋈ Coleccion))
- R = π_{titulo}(Libro ⋈_{isbn} (B_C ∩ B_L))

**Relaciones intermedias comprobadas:**
- B_C: ISBN de Ciencia: 4 filas; columnas isbn.
- B_L: ISBN de Literatura: 3 filas; columnas isbn.
- R: interseccion: 1 filas; columnas titulo.
**Salida esperada en datos de prueba:** 1 filas; columnas titulo.
**Equivalente SQL:** `consultas_sqlserver.sql`, sección Q07.
**CSV de resultados:** `resultados_csv/Q07_resultado.csv`.

## Q08 — Division: libros en todas las colecciones exigidas
**Dificultad:** Avanzada
**Requerimiento:** Buscar los libros incluidos en cada una de las colecciones requeridas: Ciencia y Literatura.

**Expresión y pasos:**
- S = π_{isbn,id_coleccion}(LibroColeccion)
- T = π_{id_coleccion}(σ_{nombre∈{Ciencia,Literatura}}(Coleccion))
- D = S ÷ T
- R = π_{titulo}(Libro ⋈_{isbn} D)

**Relaciones intermedias comprobadas:**
- T: colecciones exigidas: 2 filas; columnas id_coleccion, nombre.
- S: relaciones libro-coleccion: 10 filas; columnas isbn, id_coleccion.
- D: ISBN que cumplen todas: 1 filas; columnas isbn.
- R: titulo resultante: 1 filas; columnas titulo.
**Salida esperada en datos de prueba:** 1 filas; columnas titulo.
**Equivalente SQL:** `consultas_sqlserver.sql`, sección Q08.
**CSV de resultados:** `resultados_csv/Q08_resultado.csv`.

## Q09 — Numero de ejemplares por libro (agrupacion)
**Dificultad:** Avanzada
**Requerimiento:** Contar ejemplares por libro incluyendo titulos sin copias registradas.

**Expresión y pasos:**
- J = Libro ⟕_{Libro.isbn=Ejemplar.isbn} Ejemplar
- R = γ_{Libro.isbn,Libro.titulo; COUNT(Ejemplar.id_ejemplar)→total}(J)

**Relaciones intermedias comprobadas:**
- J: libros con sus copias: 8 filas; columnas titulo, id_ejemplar.
- R: agrupacion: 6 filas; columnas titulo, total_ejemplares.
**Salida esperada en datos de prueba:** 6 filas; columnas titulo, total_ejemplares.
**Equivalente SQL:** `consultas_sqlserver.sql`, sección Q09.
**CSV de resultados:** `resultados_csv/Q09_resultado.csv`.

## Q10 — Prestamos activos con lector y titulo
**Dificultad:** Avanzada
**Requerimiento:** Identificar el prestamo activo, nombre del lector y titulo del libro correspondiente.

**Expresión y pasos:**
- A = σ_{fecha_devolucion IS NULL}(Prestamo)
- J1 = A ⋈_{A.id_persona=Persona.id_persona} Persona
- J2 = J1 ⋈_{A.id_ejemplar=Ejemplar.id_ejemplar} Ejemplar
- R = π_{id_prestamo,nombres,titulo}(J2 ⋈_{Ejemplar.isbn=Libro.isbn} Libro)

**Relaciones intermedias comprobadas:**
- A: prestamos activos: 3 filas; columnas id_prestamo, id_persona, id_ejemplar.
- J1: lectores: 3 filas; columnas id_prestamo, nombres, id_ejemplar.
- R: lectores y titulos: 3 filas; columnas id_prestamo, nombres, titulo.
**Salida esperada en datos de prueba:** 3 filas; columnas id_prestamo, nombres, titulo.
**Equivalente SQL:** `consultas_sqlserver.sql`, sección Q10.
**CSV de resultados:** `resultados_csv/Q10_resultado.csv`.

## Q11 — Personas que no han solicitado prestamos
**Dificultad:** Compleja
**Requerimiento:** Encontrar personas sin movimientos historicos de prestamo.

**Expresión y pasos:**
- I = π_{id_persona}(Persona)
- P = π_{id_persona}(Prestamo)
- R = π_{nombres,apellido_paterno}(Persona ⋈_{id_persona} (I − P))

**Relaciones intermedias comprobadas:**
- I: todos los lectores: 7 filas; columnas id_persona, nombres.
- P: quienes han pedido: 5 filas; columnas id_persona.
- R: diferencia: 2 filas; columnas nombres, apellido_paterno.
**Salida esperada en datos de prueba:** 2 filas; columnas nombres, apellido_paterno.
**Equivalente SQL:** `consultas_sqlserver.sql`, sección Q11.
**CSV de resultados:** `resultados_csv/Q11_resultado.csv`.

## Q12 — Autores, incluso quienes no tienen libros
**Dificultad:** Avanzada
**Requerimiento:** Conservar todos los autores registrados, aun si no tienen obras vinculadas.

**Expresión y pasos:**
- J1 = Autor ⟕_{Autor.id_autor=LibroAutor.id_autor} LibroAutor
- R = π_{Autor.nombre,Libro.titulo}(J1 ⟕_{LibroAutor.isbn=Libro.isbn} Libro)

**Relaciones intermedias comprobadas:**
- J1: autoria opcional: 9 filas; columnas nombre, isbn.
- R: con titulo opcional: 9 filas; columnas autor, titulo.
**Salida esperada en datos de prueba:** 9 filas; columnas autor, titulo.
**Equivalente SQL:** `consultas_sqlserver.sql`, sección Q12.
**CSV de resultados:** `resultados_csv/Q12_resultado.csv`.

## Q13 — Prestamos e incidencias (reunion externa)
**Dificultad:** Intermedia
**Requerimiento:** Listar todos los prestamos, tengan o no incidencia reportada.

**Expresión y pasos:**
- R = π_{Prestamo.id_prestamo,Incidencia.tipo}(Prestamo ⟕_{Prestamo.id_prestamo=Incidencia.id_prestamo} Incidencia)

**Relaciones intermedias comprobadas:**
- P: total de prestamos: 6 filas; columnas id_prestamo.
- R: prestamos con incidencias opcionales: 6 filas; columnas id_prestamo, incidencia.
**Salida esperada en datos de prueba:** 6 filas; columnas id_prestamo, incidencia.
**Equivalente SQL:** `consultas_sqlserver.sql`, sección Q13.
**CSV de resultados:** `resultados_csv/Q13_resultado.csv`.

## Q14 — Producto cartesiano de lectores y novedades
**Dificultad:** Intermedia
**Requerimiento:** Generar combinaciones potenciales entre estudiantes de semestre 5+ y libros publicados desde 2023.

**Expresión y pasos:**
- A = π_{nombres}(Persona ⋈ σ_{semestre≥5}(Estudiante))
- B = π_{titulo}(σ_{anio_publicacion≥2023}(Libro))
- R = A × B

**Relaciones intermedias comprobadas:**
- A: estudiantes objetivo: 2 filas; columnas nombres.
- B: novedades: 2 filas; columnas titulo.
- R: combinaciones: 4 filas; columnas nombres, titulo.
**Salida esperada en datos de prueba:** 4 filas; columnas nombres, titulo.
**Equivalente SQL:** `consultas_sqlserver.sql`, sección Q14.
**CSV de resultados:** `resultados_csv/Q14_resultado.csv`.

## Q15 — Proyeccion generalizada: antiguedad en 2026
**Dificultad:** Intermedia
**Requerimiento:** Calcular los anos transcurridos entre el ano de publicacion y el ano 2026.

**Expresión y pasos:**
- R = π_{titulo,(2026 − anio_publicacion)→antiguedad}(Libro)

**Relaciones intermedias comprobadas:**
- L: ano original: 6 filas; columnas titulo, anio_publicacion.
- R: expresion derivada: 6 filas; columnas titulo, antiguedad.
**Salida esperada en datos de prueba:** 6 filas; columnas titulo, antiguedad.
**Equivalente SQL:** `consultas_sqlserver.sql`, sección Q15.
**CSV de resultados:** `resultados_csv/Q15_resultado.csv`.

## Q16 — Consulta compleja: titulos de Ciencia escritos por Ada desde 2020
**Dificultad:** Avanzada
**Requerimiento:** Obtener titulos de Ciencia posteriores a 2019 en cuya autoria aparezca Ada Nieto.

**Expresión y pasos:**
- C1 = σ_{nombre="Ciencia"}(Coleccion)
- A1 = σ_{nombre="Ada Nieto"}(Autor)
- L1 = σ_{anio_publicacion≥2020}(Libro)
- J1 = L1 ⋈_{L1.isbn=LC.isbn} LC ⋈_{LC.id_coleccion=C1.id_coleccion} C1
- J2 = J1 ⋈_{L1.isbn=LA.isbn} LA ⋈_{LA.id_autor=A1.id_autor} A1
- R = π_{L1.titulo}(J2)

**Relaciones intermedias comprobadas:**
- C1: coleccion objetivo: 1 filas; columnas id_coleccion.
- A1: autoria objetivo: 1 filas; columnas id_autor.
- L1: filtro de fecha: 5 filas; columnas isbn, titulo.
- R: interseccion de relaciones: 3 filas; columnas titulo.
**Salida esperada en datos de prueba:** 3 filas; columnas titulo.
**Equivalente SQL:** `consultas_sqlserver.sql`, sección Q16.
**CSV de resultados:** `resultados_csv/Q16_resultado.csv`.

## Alcance de la validación
Se ejecutaron 16 consultas sobre una base SQLite en memoria. Las salidas se verificaron con las relaciones intermedias correspondientes y se exportaron en CSV. El SQL Server no fue ejecutado en este entorno. Para verificarlo, utilizar una instancia SSMS y la guía incluida.

## Conclusión
La combinación ordenada de operadores simplifica las preguntas de catálogo, préstamo, lector y autor. Los conjuntos evitan duplicidades, el operador división expresa un cuantificador universal y las reuniones externas preservan registros sin coincidencia.