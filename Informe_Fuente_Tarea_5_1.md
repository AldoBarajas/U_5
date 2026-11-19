# Unidad 5 · Tarea 5.1 | Álgebra relacional

**Alumno:** Aldo Alberto Barajas Ancira  
**Institución:** Instituto Tecnológico Superior de Monclova  
**Asignatura:** Fundamentos de Bases de Datos  
**Docente:** Rubén Riojas  
**Caso:** Biblioteca escolar

## Marco teórico

El álgebra relacional es un lenguaje formal de manipulación de relaciones; una expresión recibe relaciones y produce otra. En su formulación clásica, los resultados tienen semántica de conjuntos: la proyección elimina tuplas duplicadas. El modelo es cerrado bajo los operadores relacionales.

| Tipo | Operador | Notación | Función |
|---|---|---|---|
| Unario | Selección | σ_condición(R) | Filtrar filas |
| Unario | Proyección | π_atributos(R) | Elegir columnas y eliminar duplicados |
| Unario | Renombramiento | ρ(R) | Renombrar relación o atributos |
| Binario | Producto | R × S | Todas las combinaciones |
| Binario | Unión | R ∪ S | Tuplas en R o S |
| Binario | Intersección | R ∩ S | Tuplas en ambos |
| Binario | Diferencia | R − S | Tuplas que están solo en R |
| Binario | División | R ÷ S | Tuplas asociadas con **todas** las de S |
| Binario | Join | R ⋈_predicado S | Combinar filas que cumplen relación |
| Extendido | Proyección generalizada | π_A,f(B)→X(R) | Columnas calculadas |
| Extendido | Agrupación | γ_grupo;F(A)→X(R) | COUNT, SUM, AVG, MIN, MAX |
| Extendido | Left outer join | R ⟕_predicado S | Preserva filas sin pareja del lado izquierdo |
| Extendido | Right outer join | R ⟖_predicado S | Preserva filas sin pareja del lado derecho |
| Extendido | Full outer join | R ⟗_predicado S | Preserva filas sin pareja en ambos lados |

### Restricciones formales

- Unión, intersección y diferencia requieren relaciones compatibles por esquema y dominio; se necesita alinear atributos cuando sus nombres difieren.
- La división requiere que las columnas del divisor sean un subconjunto de las columnas del dividendo. No significa división numérica.
- Un producto cartesiano tiene |R|×|S| filas en ausencia de restricciones, mientras que un join filtra combinaciones por un predicado.
- La proyección clásica elimina duplicados; SQL debe usar SELECT DISTINCT para conservar esa semántica. NULL y outer joins son extensiones de la formulación clásica.

### Ejemplos aplicados

1. Libros desde 2020: `π_isbn,titulo(σ_anio_publicacion≥2020(Libro))`.
2. Autores y títulos: `π_Libro.titulo,Autor.nombre((Libro ⋈ LibroAutor) ⋈ Autor)` (los joins se realizan mediante ISBN e id_autor).
3. Libros no prestados: `π_isbn(Libro) − π_Ejemplar.isbn(Ejemplar ⋈ Prestamo)`.
4. División: `π_isbn,id_coleccion(LibroColeccion) ÷ π_id_coleccion(σ_nombre∈{Ciencia,Literatura}(Coleccion))`.
5. Agrupación: `γ_isbn;COUNT(id_ejemplar)→copias(Ejemplar)`.

### Equivalencia general con SQL Server

σ -> WHERE; π -> SELECT DISTINCT; × -> CROSS JOIN; ⋈ -> JOIN ... ON; ∪ -> UNION; ∩ -> INTERSECT; − -> EXCEPT; ÷ -> NOT EXISTS anidados; γ -> GROUP BY y funciones; outer joins -> LEFT/RIGHT/FULL OUTER JOIN.

## Referencias

- Carnegie Mellon University (2021), *Relational Model & Relational Algebra*: https://15445.courses.cs.cmu.edu/fall2021/notes/01-introduction.pdf
- University at Buffalo (2019), *Extended Relational Algebra*: https://odin.cse.buffalo.edu/teaching/cse-562/2019sp/slide/2019-02-13-ExtRA.html
- Microsoft Learn, *EXCEPT and INTERSECT (Transact-SQL)*: https://learn.microsoft.com/sql/t-sql/language-elements/set-operators-except-and-intersect-transact-sql

La versión maquetada final está en `Tarea_5_1_Mapa_y_Marco_Teorico.pdf`; el mapa editable se entrega en formato Graphviz DOT y SVG, además de PDF vectorial y PNG.
