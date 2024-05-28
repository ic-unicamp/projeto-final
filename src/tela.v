module tela(
    input CLOCK_50,
    input reset,
    input [9:0] xNave,  
    input [9:0] yNave,
    input [9:0] larguraNave,
    input [9:0] alturaNave,
    output reg [7:0] VGA_R,    
    output reg [7:0] VGA_G, 
    output reg [7:0] VGA_B,  
    output wire VGA_HS,  
    output wire VGA_VS, 
    output wire VGA_BLANK_N, 
    output wire VGA_SYNC_N, 
	output wire VGA_CLK
);    
    wire [9:0] VGA_X; 
    wire [9:0] VGA_Y;
    wire ativo;

	vga vga_inst(
		.CLOCK_50(CLOCK_50),
		.reset(reset),
		.VGA_CLK(VGA_CLK),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
		.x(VGA_X),
		.y(VGA_Y),
		.ativo(ativo)
	);

    always @(posedge CLOCK_50 or posedge reset) begin // implementar a lógica que será usada para "imprimir" na tela
        if (reset) begin
		   	VGA_R <= 0;
			VGA_G <= 0;
            VGA_B <= 0;
        end else begin
            if (ativo) begin
                    if ((xNave + 144 <= VGA_X ) && (VGA_X <= 144 + xNave + larguraNave) && 
                        (yNave + 35 <= VGA_Y) && (VGA_Y <= yNave + 35 + alturaNave)) begin //o da bola
                    VGA_R <= 255;
                    VGA_G <= 255;
                    VGA_B <= 255;
                end else begin
                    VGA_R <= 0; 
                    VGA_G <= 50;
                    VGA_B <= 50;
                end
            end else begin 
                    VGA_R <= 0;
                    VGA_G <= 0;
                    VGA_B <= 0;    
            end
        end
    end

endmodule