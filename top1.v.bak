module top1 (

  // CLOCK
  input  CLOCK_50,
	input  CLOCK2_50,

   KEY_N,

  // SW
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

wire locked; //variavel do pclock

wire enable_write_memory; // Controle para saber se a memória guardar a informação da câmera. Quem gera esse sinal é a prórpria câmera
wire [0:19] pos_pixel_w; // Endereço da memória onde será guardado a info da câmera, gerado pela câmera.
reg [0:19] pos_pixel_r; // Endereço da memória onde será lida informação pelo vga para por na tela 
wire [7:0] cor_atual_vga; //saida em cores da memoria
wire [7:0] pixel_atual; //dado de entrada na memoria / saida da camera
assign GPIO_1[11] = 1; //reset
wire reset;

assign reset = SW[0];

wire href;
wire pclock;
//wire hpclk;
assign href = GPIO_1[22];
assign pclock = GPIO_1[21];



pll CLOCK24(
	 .refclk(CLOCK_50),
    .rst(~KEY[0]),
    .outclk_0(GPIO_1[20]),
    .locked(locked)
    );
wire [19:0] pixel_detect;

camera CAMERA( 
    //.scl(GPIO_1[25]),
    //.sda(GPIO_1[24]),
    //.vsync(GPIO_1[23]),
    .href(href),
    .pclk(pclock),
	  //.hpclk(hpclk),
    .reset(~KEY[0]),
    .pwdn(GPIO_1[10]),
    .enable_write_memory(enable_write_memory),
    .pos_pxl(pos_pixel_w),
    .byte_camera(GPIO_1[19:12]),
    .pixel_out(pixel_atual),
    .detect_pos_pixel(pixel_detect),
    .achou_out(ativa_pincel)
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
wire ativa_pincel;


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

reg [10:0] y_detect;
reg [10:0] x_detect;
		  
always @(posedge CLOCK_50) begin
    y_detect <= pixel_detect/640;
    x_detect <= pixel_detect%640;
    if (ativo) begin
      if ((x-143==x_detect || y-35==y_detect) && ativa_pincel) begin
        vga_r_int <= 0;
        vga_g_int <= 0;
        vga_b_int <= 255;
      end
       else if(~ativa_pincel && y==239) begin
         vga_r_int <= 255;
         vga_g_int <= 127;
         vga_b_int <= 127;
       end
      else begin
        if (cor_atual_vga > 127) begin
          vga_r_int <= 127;
          vga_g_int <= 255;
          vga_b_int <= 127;
        end
        else begin
          vga_r_int <= cor_atual_vga<<1;
          vga_g_int <= cor_atual_vga<<1;
          vga_b_int <= cor_atual_vga<<1;
        end
      end
        pos_pixel_r <= 640*(y- 1 - 35) + x - 1 - 143; // o x e o y do vga n~ao começam em zero
		  // [E necess´ario desloca-los.
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
