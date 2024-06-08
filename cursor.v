module cursor(
    input clk,
    input [5:0] radius,
    input draw,
    input [10:0] x,
    input [10:0] y,
    output reg enable_write_memory,
    output reg [0:19] pos_pxl_w

  // complemente seus sinais aqui
);

// Estes valores ficam sempre entre (cordenada do cursor - radius) e (coordenada do cursor + radius)
// São usados para coordenar qual pixel especifico está sendo pintado na memória
reg [10:0] x_em_cursor;
reg [10:0] y_em_cursor;

always @(posedge clk) begin
	pos_pxl_w <= 640*(y_em_cursor) + x_em_cursor; // posicao de escrita na memoria

	x_em_cursor = x_em_cursor + 1;
	if (x_em_cursor > x + radius) begin
		x_em_cursor = x - radius;
		y_em_cursor = y_em_cursor + 1;
	end
	if (y_em_cursor > y + radius) begin
		y_em_cursor = y - radius;
	end

	if (draw && (x_em_cursor < 640 && y_em_cursor < 480)) begin
		enable_write_memory <= 1;
	end 
	else begin
		enable_write_memory <= 0;
	end

end

endmodule

