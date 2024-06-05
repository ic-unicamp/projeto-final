module projeto(
	input CLOCK_50,
	input [3:0] KEY,

);  

	wire [3:0] keysout;  

	
	keys keysInstancia(
		.CLOCK_50(CLOCK_50),
		.keys(KEY),
		.keysout(keysout)
	);

	tela telaInstancia(
		.CLOCK_50(CLOCK_50),
		.reset(keysout[3]),
		.BordaBarraX(telaBarraX),
		.BordaBarraY(telaBarraY),
		.LarguraBarra(LarguraBarra), 
		.AlturaBarra(AlturaBarra),
		.BolaX(telaBolaX),
		.BolaY(telaBolaY),
		.LadoBola(LadoBola),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_CLK(VGA_CLK),
		.perdeu(perdeu)
	);

endmodule 