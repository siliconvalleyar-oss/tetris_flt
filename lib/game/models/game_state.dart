/// Estados posibles del juego.
enum GameState {
  /// Partida en curso.
  playing,

  /// Partida pausada por el jugador.
  paused,

  /// Partida terminada por acumulación de piezas.
  gameOver,
}
