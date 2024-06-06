module projeto(
	input CLOCK_50,
	input [9:0] SW,
	input [3:0] KEY,

	// VGA
	output wire [7:0] VGA_R, 
    output wire [7:0] VGA_G,     
    output wire [7:0] VGA_B,  
	output wire VGA_HS,   
	output wire VGA_VS,   
	output wire VGA_BLANK_N,  
	output wire VGA_SYNC_N, 
	output wire VGA_CLK


);  
	wire [2:0] R_AUX;
	wire [2:0] G_AUX;
	wire [2:0] B_AUX;

	assign VGA_R = ativoVGA? {R_AUX, 5'b00000} : 8'h00;
	assign VGA_G = ativoVGA? {G_AUX, 5'b00000} : 8'h00;
	assign VGA_B = ativoVGA? {B_AUX, 5'b00000} : 8'h00;	

	// assign VGA_R = ativoVGA? 255 : 8'h00;
	// assign VGA_G = ativoVGA? 255 : 8'h00;
	// assign VGA_B = ativoVGA? 255 : 8'h00;	

	// Chaves
	wire [3:0] keysout;

	// Funcionalidades
	wire reset;
	assign reset = SW[0]; 

	wire pausa; 
	assign pausa = SW[1];

	// Coordenadas
	wire [9:0] x_bola_nave; 
	wire [9:0] y_bola_nave; 
	wire [9:0] raio_bola_nave;


	// VGA
	wire [9:0] xVGA;
	wire [9:0] yVGA;  
	wire ativoVGA;
	wire [18:0] readingAdressVGA;
	assign readingAdressVGA = ativoVGA ? ((xVGA - 144)) + (yVGA - 35) * 640 : 0; //espelha a imagem
	// Reiniciar jogo = não zera o placar máximo

	keys keysInstancia(
		.CLOCK_50(CLOCK_50),
		.keys(KEY),
		.keysout(keysout)
	);

	bola bolaNave(
		.CLOCK_50(CLOCK_50),
		.reset(reset),
		.pausa(pausa),
		.reiniciarJogo(keysout[3]),
		.x(BolaNaveX),
		.y(BolaNaveY),
		.raio(telaBolaNaveRaio),
		.ehNave(1),
		.ehInimigo(0),
		.atingiuInimigo(),
		.atingiuNave()
	);

	tela telaInstancia(
		.CLOCK_50(CLOCK_50),
		.reset(reset),
		.perdeu(0),
		.BordaNaveX(0),
		.BordaNaveY(0),
		.LarguraNave(0),
		.AlturaNave(0),
		.BordaInimigoX(0),
		.BordaInimigoY(0),
		.LarguraInimigo(0),
		.AlturaInimigo(0),
		.BolaNaveX(x_bola_nave),
		.BolaNaveY(y_bola_nave),
		.BolaInimigoX(0),
		.BolaInimigoY(0),
		.RaioBolaNave(raio_bola_nave),
		.RaioBolaInimigo(0),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_CLK(VGA_CLK),
		.xVGA(xVGA),
		.yVGA(yVGA),
		.ativoVGA(ativoVGA)
	);



endmodule 