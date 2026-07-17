══════════════════════════════════════════════════════════════════════════════
              CORRECCIÓN DEL LAYOUT RESPONSIVO - TETRIS
══════════════════════════════════════════════════════════════════════════════

NO MODIFICAR ABSOLUTAMENTE NADA DEL MODO VERTICAL (PORTRAIT).

El diseño vertical actual es correcto y debe mantenerse exactamente igual.
No cambiar tamaños, posiciones, márgenes, botones, tablero ni distribución.

ÚNICAMENTE REDISEÑAR EL MODO HORIZONTAL (LANDSCAPE).

OBJETIVOS

1) AGRANDAR EL TABLERO

Actualmente el tablero ocupa una parte muy pequeña de la pantalla y queda una gran zona vacía.

Se debe:

- Aumentar considerablemente el tamaño visual del tablero.
- El tablero debe ocupar aproximadamente entre el 65% y el 75% del ancho disponible.
- Aprovechar prácticamente toda la altura disponible.
- Las piezas deben verse mucho más grandes.
- Las celdas deben seguir siendo cuadrados perfectos.
- No deformar el tablero.
- El tablero debe convertirse en el elemento principal de la interfaz.

2) DISEÑO RESPONSIVO

Utilizar únicamente un diseño responsive mediante:

- LayoutBuilder
- MediaQuery
- Expanded
- Flexible
- AspectRatio

Evitar tamaños fijos siempre que sea posible.

3) PANEL DE PUNTUACIÓN

Mover el panel de información al lado izquierdo.

Mostrar en forma vertical:

SCORE
LEVEL
LINES
BEST

Debe ocupar únicamente el ancho necesario.

4) TABLERO

Ubicar el tablero en el centro.

Debe ser el elemento más grande de toda la pantalla.

No debe quedar una enorme zona blanca vacía.

5) SIGUIENTE PIEZA

Mantener el panel NEXT en el lado derecho.

Debe alinearse verticalmente con el tablero.

6) BOTONES DE ACCIÓN

Ubicar centrados debajo del tablero:

ROT
DROP
HARD DROP
PAUSE

Mantener el mismo tamaño y separación uniforme.

7) CONTROLES DE MOVIMIENTO

Separar completamente los botones de dirección.

El botón:

←

debe quedar completamente a la izquierda.

El botón:

→

debe quedar completamente a la derecha.

No deben permanecer juntos en el centro.

La distribución debe permitir jugar cómodamente con ambos pulgares.

8) DISTRIBUCIÓN FINAL

+------------+--------------------------------------+------------+
|            |                                      |            |
| SCORE      |                                      |   NEXT     |
| LEVEL      |                                      |            |
| LINES      |         TABLERO GRANDE               |            |
| BEST       |                                      |            |
|            |                                      |            |
+------------+--------------------------------------+------------+
|                                                              |
|      ROT       DROP       HARD DROP       PAUSE              |
|                                                              |
|   ←                                                →         |
+--------------------------------------------------------------+

9) MODO VERTICAL

NO CAMBIAR:

- tamaño del tablero
- tamaño de las piezas
- posición del puntaje
- posición del NEXT
- botones
- márgenes
- distribución
- jugabilidad

Debe verse exactamente igual que la versión actual.

10) RESULTADO ESPERADO

VERTICAL:
Mantener exactamente el diseño actual.

HORIZONTAL:
- Tablero grande y centrado.
- Piezas mucho más visibles.
- Puntaje en el lateral izquierdo.
- NEXT en el lateral derecho.
- Botones de acción centrados debajo del tablero.
- Flecha izquierda completamente a la izquierda.
- Flecha derecha completamente a la derecha.
- Aprovechar toda la pantalla sin dejar grandes espacios vacíos.
- Mantener una interfaz limpia, equilibrada y profesional.
══════════════════════════════════════════════════════════════════════════════
