# Rescate Salvaje

Serious game top-down (estilo *The Legend of Zelda*, 1986) sobre especies en peligro y tráfico de fauna.
Hecho en **Godot 4.7** con la misma organización que el proyecto Zelda: escenas `.tscn` con sus nodos,
sprites en `Assets/` y el mapa pintado en un `TileMapLayer`.

Incluye introducción en viñetas, 3 niveles, música y efectos de sonido.

## Cómo abrirlo

1. Abre Godot 4.7 → **Importar** → selecciona `project.godot` de esta carpeta.
2. Presiona **F5** para jugar (empieza en `Scenes/World/titulo.tscn`).

## Controles

| Acción | Teclas |
| --- | --- |
| Mover | WASD o flechas |
| Abrir jaula | E o Espacio |
| Guía de campo | G o Tab |
| Aceptar / continuar | Enter |

## Cómo se juega

1. Entra al **campamento** de los traficantes y abre una jaula.
2. El animal te sigue. Llévalo a su hábitat.
3. Si aciertas, se desbloquea su ficha. Si fallas, recibes una pista.
4. Evita los conos de visión de los traficantes. Si te tocan, pierdes un corazón y el animal vuelve a su jaula.
5. Al rescatar a los 3 animales respondes la pregunta final y ves tus resultados (1 a 3 estrellas).

## Niveles

| Nivel | Hábitats | Especies | Novedad |
| --- | --- | --- | --- |
| 1: Selva, páramo y costa | Selva, páramo, costa | Guacamaya, oso de anteojos, tortuga carey | 3 traficantes |
| 2: Los Llanos | Sabana, bosque de galería, ciénaga | Oso palmero, jaguar, manatí | Jaulas con candado (busca 3 llaves), río que solo se cruza por 2 puentes, 4 traficantes |
| 3: La Amazonía de noche | Dosel de la selva, río (muelle), playa del río | Mono churuco, delfín rosado, tortuga charapa | Nivel oscuro: los traficantes llevan linterna (PointLight2D) y el mundo se oscurece con un CanvasModulate |

Preguntas finales: nivel 1, comprar o no un loro; nivel 2, un collar de colmillos de jaguar; nivel 3, huevos de charapa.

## Sonido y música

Todo el audio se sintetizó por código (ondas cuadradas, triangulares y ruido) y está en `Assets/Audio/`.
El autoload `Sonido` (`Scenes/Audio/sonido.tscn`) tiene un `AudioStreamPlayer` para la música y 6 canales de efectos.
Los sonidos se asignan en su Inspector y se usan con `Sonido.reproducir("jaula")` o `Sonido.tocar_musica("musica")`.

| Efecto | Cuándo suena |
| --- | --- |
| paso | Mientras el guardaparques camina |
| jaula | Al abrir una jaula |
| alerta | Cuando un traficante te ve |
| llave | Al recoger una llave |
| acierto / error | Hábitat correcto o incorrecto, respuesta de la pregunta final |
| dano | Cuando te atrapan |
| victoria | Pantalla de resultados |
| click / blip | Menús, guía e introducción |

## Escenas

| Escena | Nodos principales |
| --- | --- |
| `Scenes/World/titulo.tscn` | Control, TileMapLayer (borde), Labels, TextureRects |
| `Scenes/World/intro.tscn` | Introducción: Marco → Imagen, CajaTexto → Texto (aparece letra por letra), Pie. Imágenes y textos en el Inspector |
| `Scenes/Audio/sonido.tscn` | Autoload Sonido → Musica, Efectos (Canal1…Canal6) |
| `Scenes/World/nivel_1.tscn`, `nivel_2.tscn`, `nivel_3.tscn` | Mundo → Suelo (TileMapLayer), Letreros, Zonas (Area2D), Jaulas, Llaves, Animales, Traficantes, PuntoInicio, Player · HUD · Ficha · Guia · PreguntaFinal · Derrota |
| `Scenes/World/resultados.tscn` | Panel con estrellas, estadísticas y "Aprendiste"; lleva al siguiente nivel |
| `Scenes/Player/player.tscn` | CharacterBody2D → CollisionShape2D, AnimatedSprite2D |
| `Scenes/Enemies/traficante.tscn` | CharacterBody2D → CollisionShape2D, ConoVision (Polygon2D), AnimatedSprite2D, Alerta, LineaVista (RayCast2D) |
| `Scenes/Objetos/jaula.tscn` | Node2D → Animal (Sprite2D), Barras (Sprite2D), Aviso |
| `Scenes/Objetos/animal.tscn` | Node2D → Sprite2D (se crea al abrir una jaula) |
| `Scenes/Objetos/llave.tscn` | Area2D → Sprite2D, CollisionShape2D |
| `Scenes/UI/*.tscn` | CanvasLayer del HUD, ficha, guía, pregunta final y derrota |

## Cómo editarlo

- **Mapa:** abre `nivel_1.tscn` o `nivel_2.tscn`, selecciona `Mundo/Suelo` y pinta con el TileSet (`Assets/tileset.tres`).
- **Nivel:** en el nodo raíz del nivel se editan `nivel`, `siguiente_escena`, `mensaje_inicio`, `musica` y `de_noche`.
- **Dificultad de cada traficante:** `ALCANCE_VISION`, `ANGULO_VISION`, `TIEMPO_PERSECUCION` y `SPEED_PERSECUCION` en el Inspector.
- **Introducción:** imágenes (`Assets/Intro/`) y textos en el Inspector de `intro.tscn`.
- **Hábitats:** cambia el tamaño del `CollisionShape2D` de cada nodo en `Mundo/Zonas`.
- **Jaulas:** mueve los nodos de `Mundo/Jaulas`, elige la especie (`especie_id`) y si tiene candado (`necesita_llave`).
- **Llaves:** duplica o mueve los nodos de `Mundo/Llaves`.
- **Traficantes:** su ruta de patrulla y velocidades se editan en el Inspector (`ruta`, `SPEED_PATRULLA`).
- **Pregunta final:** contexto, frase, imagen, opciones, respuesta correcta y explicaciones en el Inspector del nodo `PreguntaFinal`.
- **Datos de las especies y textos de "Aprendiste":** `Scripts/game_manager.gd`.

## Evaluación del aprendizaje

Flujo completo: título → **evaluación inicial** → introducción → juego → **evaluación final** → comparación antes/después → **encuesta de valoración**.

- Las 6 preguntas y sus opciones están en `Scripts/evaluacion.gd` (las opciones se mezclan al mostrarlas).
- Al terminar el último nivel y la encuesta, el participante queda guardado como una fila (P01, P02…) en
  `%APPDATA%\Godot\app_userdata\Rescate Salvaje\resultados.csv`. Se abre en Excel.
- **F2 en la pantalla de título** abre el panel del docente: participantes, promedios antes y después, ganancia, aciertos por pregunta y valoración.

## Shaders, tipografía y menú de pausa

- `Assets/Shaders/`: efectos hechos con shaders de Godot (ver la documentación en Word).
- `Assets/Fonts/`: fuente propia *Silvestre Pixel* (Regular y Bold). El tema `tema.tres` la aplica a todo el juego; los tamaños son múltiplos de 8 para que se vea nítida.
- **ESC** abre el menú de pausa: continuar, reiniciar, activar o quitar sonido y efectos visuales, y ver los controles.
