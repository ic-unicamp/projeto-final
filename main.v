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
	parameter [6:0] SIZE = 16;
	parameter [6:0] STEP = 16;
	parameter [10:0] W_RES = 640;
	parameter [10:0] H_RES = 480; 
	parameter [19:0] DIVISOR = 200000;

	reg [10:0] ball_x;		// Coordenadas da bola		
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

	wire write_enable;
	wire [7:0] red_in;
	wire [7:0] green_in;
	wire [7:0] blue_in;
	wire [10:0] top_x_coord;
	wire [10:0] top_y_coord;
	wire [7:0] red_out;
	wire [7:0] green_out;
	wire [7:0] blue_out;
	wire [7:0] red_data_in;
	wire [7:0] green_data_in;
	wire [7:0] blue_data_in;

	buffer red_buffer(
		.CLOCK_50(CLOCK_50),
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
		.CLOCK_50(CLOCK_50),
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
		.CLOCK_50(CLOCK_50),
		.reset(reset),
		.write_enable(write_enable),
		.data_in(blue_data_in),
		.data_in_x(top_x_coord),
		.data_in_y(top_y_coord),
		.data_out(blue_out),
		.data_out_x(x_coord),
		.data_out_y(y_coord)
	);

	wire [10:0] x_zera;
	wire [10:0] y_zera;


	zera_buffer inst_zera_buffer(
		.reset(reset),
		.clock(CLOCK_50),
		.x_coord(x_zera),
		.y_coord(y_zera)
	);

	reg enable = 0;

	// assign top_x_coord = reset ? ------: x_zera;
	// assign top_y_coord = reset ? ------: y_zera;
	assign top_x_coord = x_zera;
	assign top_y_coord = y_zera;
	assign write_enable = reset ? enable: 1;
	assign red_data_in = reset ? red_in : 255;
	assign green_data_in = reset ? green_in : 255;
	assign blue_data_in = reset ? blue_in : 255;

	assign red_vga = (y_coord >= ball_y && y_coord <= ball_y + SIZE && x_coord >= ball_x && x_coord <= ball_x + SIZE) ? 0 : red_out;
	assign green_vga = (y_coord >= ball_y && y_coord <= ball_y + SIZE && x_coord >= ball_x && x_coord <= ball_x + SIZE) ? 0 : green_out;
	assign blue_vga = (y_coord >= ball_y && y_coord <= ball_y + SIZE && x_coord >= ball_x && x_coord <= ball_x + SIZE) ? 0 : blue_out;

	always @(posedge VGA_CLK) begin

		if (reset == 0) begin
			ball_x = ((W_RES/2) - (SIZE/2));       // Centraliza a barra
			ball_y = ((H_RES/2) - (SIZE/2));          // Afasta a barra 30 pixels do final da tela
			last_button = 3'b111;
			end

    else begin
			cont = cont + 1;
			// if pintar_but: enable=1 else 0
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
							if (ball_y + STEP > 479) ball_y = (479 - SIZE);
							else ball_y = ball_y + STEP;
							end
					3'b010: begin // LEFT
							if (ball_x < STEP) ball_x = 0;
							else ball_x = ball_x - STEP;
							end
					3'b011: begin // Right
							if (ball_x + STEP > 639) ball_x = (639 - SIZE);
							else ball_x = ball_x + STEP;
							end
					endcase

						last_button = 3'b111;
					end            
				end
			end
		end

endmodule