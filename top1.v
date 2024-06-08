module top1 (

   // CLOCK
   input  CLOCK_50,
	input  CLOCK2_50,

   KEY_N,

   /// SW
	input [9:0] SW,

  // VGA
  output [7:0] VGA_B,
  output VGA_BLANK_N,
  output VGA_CLK,
  output [7:0] VGA_G,
  output VGA_HS,
  output [7:0] VGA_R,
  output VGA_SYNC_N,
  output VGA_VS,

   // GPIO_1
  inout [35:0] GPIO_1,
   //Key
  input [3:0] KEY

);

wire locked;

wire enable_write_memory; // Controle para saber se a memória guardar a informação da câmera. Quem gera esse sinal é a prórpria câmera
wire [0:19] pos_pixel_w; // Endereço da memória onde será guardado a info da câmera, gerado pela câmera.
reg [0:19] pos_pixel_r; // Endereço da memória onde será lida informação pelo vga para por na tela 
wire [7:0] cor_atual_vga;
wire [7:0] pixel_atual;
assign GPIO_1[11] = 1; //reset

wire reset;

assign reset = SW[0];

wire href;
wire pclock;
wire hpclk;
assign href = GPIO_1[22];
assign pclock = GPIO_1[21];



pll CLOCK24(
	 .refclk(CLOCK_50),
    .rst(~KEY[0]),
    .outclk_0(GPIO_1[20]),
    .locked(locked)
    );

camera CAMERA( 
    .scl(GPIO_1[25]),
    .sda(GPIO_1[24]),
    .vsync(GPIO_1[23]),
    .href(href),
    .pclk(pclock),
	  .hpclk(hpclk),
    .reset(~KEY[0]),
    .pwdn(GPIO_1[10]),
    .enable_write_memory(enable_write_memory),
    .pos_pxl(pos_pixel_w),
    .byte_camera(GPIO_1[19:12]),
    .pixel_out(pixel_atual)
    );

ram_2port MEMORIA(
                  .reset(reset),
						      .clk(CLOCK_50),
                  .we(enable_write_memory),
                  .data_in(pixel_atual),
                  .write_addr(pos_pixel_w),
                  .re(ativo),
                  .read_addr(pos_pixel_r),
                  .data_out(cor_atual_vga)
                  );

wire [10:0] x;
wire [10:0] y;
wire ativo;
reg power;
reg [7:0] vga_r_int, vga_g_int, vga_b_int;


vga VGA(
  .CLOCK_50(CLOCK_50),
  .KEY(KEY),
  .SW(SW),
  .VGA_BLANK_N(VGA_BLANK_N),
  .VGA_CLK(VGA_CLK),
  .VGA_HS(VGA_HS),
  .VGA_SYNC_N(VGA_SYNC_N),
  .VGA_VS(VGA_VS),
  .ativo_vga(ativo),
  .x(x),
  .y(y),
);

		  
always @(posedge CLOCK_50) begin
    if (ativo) begin
        vga_r_int <= cor_atual_vga;
        vga_g_int <= cor_atual_vga;
        vga_b_int <= cor_atual_vga;
        pos_pixel_r <= 640*(y- 1 - 35) + x - 1 - 143; // o x e o y do vga n~ao começam em zero
		  // [E necess´ario desloca-los
    end
	 else begin
        vga_r_int <= 0;
        vga_g_int <= 0;
        vga_b_int <= 0;
    end
end



always @(posedge CLOCK_50)begin
  if (~KEY[0]) begin
    power = 1;
  end
  else begin
    power = 0;
  end


end

assign GPIO_1[10] = power; //power dowm
assign VGA_R = vga_r_int;
assign VGA_G = vga_g_int;
assign VGA_B = vga_b_int;

    
endmodule