import 'dart:ui';

abstract class InterfaceControl {
	void enviarComando(String comando);
	void enviarTexto(String comando);
	void moverMouse(String direcao);
	void enviarMovimento(double dx, double dy);
	void moverMouseDelta(Offset delta);
	void clicar(String botao);
}