module top1(

	// SINAIS BASICOS
	input CLOCK_50,
	input reset,
	
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
    // Cor para o VGA
    wire [7:0] red;
    wire [7:0] green;
    wire [7:0] blue;

    // Auxiliar para os botões
    reg [2:0] last_button;

    // Posição do VGA
	wire [10:0] x_coord;
	wire [10:0] y_coord;

    // Posição do cursor
	reg [10:0] ball_x;
	reg [10:0] ball_y;

    // Cor que o cursor tem para colorir
    reg [7:0] ball_rcolor = 0;
    reg [7:0] ball_gcolor = 100;
    reg [7:0] ball_bcolor = 0;

    // Enable para leitura
	reg enable;
    reg [1:0] ball_direction;

    // Parâmetros para o cursos
    parameter [6:0] STEP = 16;
    parameter [6:0] SIZE = 16;

    // Cor de entrada
    // assign ball_rcolor =
    // assign ball_gcolor =
    // assign ball_bcolor =

	vga vga_inst(
		.CLOCK_50(CLOCK_50),
		.reset(reset),
		.top_R(red),
		.top_G(green),
		.top_B(blue),
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

	buffer buffer_inst(
		.CLOCK_50(CLOCK_50),
		.write_enable(enable),
        .reset(reset),
		.rdata_in(ball_rcolor),
        .gdata_in(ball_gcolor),
        .bdata_in(ball_bcolor),
		.ball_x(ball_x),
		.ball_y(ball_y),
        .SIZE(SIZE),
        .STEP(STEP),
        .ball_direction(ball_direction),
		.data_out_x(x_coord),
		.data_out_y(y_coord),
        .rdata_out(red),
        .gdata_out(green),
        .bdata_out(blue)
	);

	always @(posedge CLOCK_50) begin 
		if (~reset) begin
			ball_x = (320 - (SIZE/2));
			ball_y = (240 - (SIZE/2));
            last_button = 3'b111;
            ball_direction = 3'b111;
			enable = 0;
		end
		else begin
            if (!up_but | !down_but | !left_but | !right_but) begin
                if (!up_but) begin
                    enable = 1;
                    last_button = 3'b000;
                    ball_direction = 3'b000;
                    end
                else if (!down_but) begin
                    enable = 1;
                    last_button = 3'b001;
                    ball_direction = 3'b001;
                    end
                else if (!left_but) begin
                    enable = 1;
                    last_button = 3'b010;
                    ball_direction = 3'b010;
                    end
                else if (!right_but) begin
                    enable = 1;
                    last_button = 3'b011;
                    ball_direction = 3'b011;
                    end
                else
                    enable = 0;
            end

            else begin
                if (last_button != 3'b111) begin
                    case (last_button)
                    3'b000:  begin  // UP
                        if (ball_y < STEP) ball_y = (480 - SIZE);
                        else ball_y = ball_y - STEP;
                        end
                    3'b001: begin // DOWN
                        if (ball_y + STEP > 479) ball_y = 0;
                        else ball_y = ball_y + STEP;
                        end
                    3'b010: begin // LEFT
                        if (ball_x < STEP) ball_x = (640 - SIZE);
                        else ball_x = ball_x - STEP;
                        end
                    3'b011: begin // Right
                        if (ball_x + STEP > 639) ball_x = 0;
                        else ball_x = ball_x + STEP;
                        end
                    endcase
                    last_button = 3'b111;
                end
            end
	    end
    end

endmodule