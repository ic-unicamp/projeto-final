module main(
	// SINAIS BASICOS
	input CLOCK_50,
	input reset,        // Switch

	// Botões para controle
	input right_but,
	input up_but,
	input down_but,
	input left_but,

	// SINAIS DA VGA
	output wire VGA_CLK,
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_SYNC_N,

	output VGA_HS,
	output VGA_VS
);
	// Parâmetros
	parameter [6:0] SIZE = 8;
	parameter [6:0] STEP = 4;
	parameter [10:0] W_RES = 640;
	parameter [10:0] H_RES = 480;
	parameter [21:0] DIVISOR = 2000000;

	// Coordenadas da bola
	reg [10:0] ball_x;
	reg [10:0] ball_y;
	reg [2:0] last_button; 
	reg [19:0] cont;
	reg [1:0] ball_direction;

	// Coordenadas de leitura do VGA
	wire [10:0] x_coord;
	wire [10:0] y_coord;
	wire [7:0] red_vga;
	wire [7:0] green_vga;
	wire [7:0] blue_vga;

	// Enable de escrita do buffer
	reg write_enable;
	// Cores do cursor - pintar
	wire [7:0] red_in;
	wire [7:0] green_in;
	wire [7:0] blue_in;
	// Coordenadas de escrita do buffer
	reg [10:0] top_x_coord;
	reg [10:0] top_y_coord;
	// Entrada do modulo buffer
	reg [7:0] red_data_in = 255;
	reg [7:0] green_data_in = 255;
	reg [7:0] blue_data_in = 255;
	// Saída do modulo buffer
	wire [7:0] red_out;
	wire [7:0] green_out;
	wire [7:0] blue_out;
	// Coordenadas para zerar o buffer quando reset=0
	// saída do modulo zera_buffer
	wire [10:0] x_zera;
	wire [10:0] y_zera;

	// Enable de leitura do buffer
	// quando reset=1 (desligado)
	// lê baseado no botão pressionado pintar_but

	vga vga_inst(
		.CLOCK_50(CLOCK_50),
		.reset(reset),
		.top_R(red_vga),			// Dado a ser enviado
		.top_G(green_vga),		// Dado a ser enviado
		.top_B(blue_vga),			// Dado a ser enviado
		.VGA_CLK(VGA_CLK),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.x_coord(x_coord),
		.y_coord(y_coord)
	);

	buffer red_buffer(
		.clock(CLOCK_50),
		.write_enable(write_enable),
		.reset(reset),
		.data_in(red_data_in),
		.data_in_x(top_x_coord),
		.data_in_y(top_y_coord),
		.data_out(red_out),
		.data_out_x(x_coord),
		.data_out_y(y_coord)
	);

	buffer green_buffer(
		.clock(CLOCK_50),
		.reset(reset),
		.write_enable(write_enable),
		.data_in(green_data_in),
		.data_in_x(top_x_coord),
		.data_in_y(top_y_coord),
		.data_out(green_out),
		.data_out_x(x_coord),
		.data_out_y(y_coord)
	);

	buffer blue_buffer(
		.clock(CLOCK_50),
		.reset(reset),
		.write_enable(write_enable),
		.data_in(blue_data_in),
		.data_in_x(top_x_coord),
		.data_in_y(top_y_coord),
		.data_out(blue_out),
		.data_out_x(x_coord),
		.data_out_y(y_coord)
	);

	zera_buffer inst_zera_buffer(
		.reset(reset),
		.clock(CLOCK_50),
		.x_coord(x_zera),
		.y_coord(y_zera)
	);

	// assign write_enable = 1;

	// assign top_x_coord = reset ? ------: x_zera;
	// assign top_y_coord = reset ? ------: y_zera;

	// assign top_x_coord = x_zera;
	// assign top_y_coord = y_zera;

	// Aqui em '------' passar as coordenadas da bola
	// e adaptar para pintar (escrever no buffer)
	// onde a bola estava antes
	// Se reset = 0, escrevemos 0 na matriz. Para isso, write_enable = 1.
	// Senão, pintamos de acordo com o botão pintar_but (enable)
	// assign write_enable = reset ? enable: 1;
	// Se reset = 0, pintamos a tela de branco
	// Senão, pintamos de acordo com a cor do cursor
	// assign red_data_in = reset ? red_in : 255;
	// assign green_data_in = reset ? green_in : 255;
	// assign blue_data_in = reset ? blue_in : 255;

	// Registradores que vão direto para o VGA
	assign red_vga = (y_coord >= ball_y && y_coord <= ball_y + SIZE && x_coord >= ball_x && x_coord <= ball_x + SIZE) ? 255 : red_out;
	assign green_vga = (y_coord >= ball_y && y_coord <= ball_y + SIZE && x_coord >= ball_x && x_coord <= ball_x + SIZE) ? 0 : green_out;
	assign blue_vga = (y_coord >= ball_y && y_coord <= ball_y + SIZE && x_coord >= ball_x && x_coord <= ball_x + SIZE) ? 0: blue_out;

	always @(posedge CLOCK_50) begin

		if (reset == 0) begin
			// Centralizar o cursor
			ball_x = ((W_RES/2) - (SIZE/2));
			ball_y = ((H_RES/2) - (SIZE/2));
			// Reiniciar last_button
			last_button = 3'b111;
			// Zerar o buffer
			top_x_coord = x_zera;
			top_y_coord = y_zera;
			end

    else begin
			write_enable = 0;
			cont = cont + 1;
			if (cont == DIVISOR) begin
				cont = 0;
				if (!up_but | !down_but | !left_but | !right_but) begin
					if (!up_but) begin
						// enable = 1;
						last_button = 3'b000;
						ball_direction = 2'b00;
						end
					else if (!down_but) begin
						// enable = 1;
						last_button = 3'b001;
						ball_direction = 2'b01;
						end
					else if (!left_but) begin
							// enable = 1;
							last_button = 3'b010;
							ball_direction = 2'b10;
							end
					else if (!right_but) begin
							// enable = 1;
							last_button = 3'b011;
							ball_direction = 2'b11;
							end
					// else
							// enable = 0;
					end

				if (last_button != 3'b111) begin
					case (last_button)
					3'b000:  begin  // UP
							if (ball_y < STEP) ball_y = 0;
							else ball_y = ball_y - STEP;
							end
					3'b001: begin // DOWN
							if (ball_y + STEP + SIZE > H_RES) ball_y = (H_RES - SIZE);
							else ball_y = ball_y + STEP;
							end
					3'b010: begin // LEFT
							if (ball_x <= STEP) ball_x = 0;
							else ball_x = ball_x - STEP;
							end
					3'b011: begin // Right
							if (ball_x + STEP + SIZE >= W_RES) ball_x = (W_RES - SIZE);
							else ball_x = ball_x + STEP;
							end
					endcase

						last_button = 3'b111;
					end            
				end
			end
		end

endmodule