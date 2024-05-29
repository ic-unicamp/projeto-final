module topper (

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

wire locked;

reg enable_write_memory; // Controle para saber se a memória guardar a informação da câmera. Quem gera esse sinal é a prórpria câmera
reg [0:19] pos_pixel_w = 0; // Endereço da memória onde será guardado a info da câmera, gerado pela câmera
reg [0:19] pos_pixel_r; // Endereço da memória onde será lida informação pelo vga para por na tela 
wire [7:0] cor_atual_vga;
assign GPIO_1[11] = 1; //reset

wire reset;

assign reset = SW[0];

wire href;
wire pclock;
wire hpclk;
assign href = GPIO_1[22];
assign pclock = GPIO_1[21];

reg [4:0] estado = 0;
reg [7:0] dado_escrita_memoria;



ram_2port MEMORIA(
                  .reset(reset),
						.clk(CLOCK_50),
                  .we(enable_write_memory),
                  .data_in(dado_escrita_memoria),
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


// CONTROLADOR PARA TESTES
wire [10:0] cursor_x_pos;
wire [10:0] cursor_y_pos;
// controller CONTROLADOR(
//   .clk(CLOCK_50),
//   .KEY(KEY),
//   .SW(SW),
//   .x_pos(cursor_x_pos),
//   .y_pos(cursor_y_pos),
// );

reg [10:0] x_pos;
reg [10:0] y_pos;


always @(posedge CLOCK_50) begin
	x_pos = 320 + 144;
	y_pos = 240 + 35;

    case(estado)
        0: begin // Inicializando memória
            if (pos_pixel_w <= 640*480 - 1) begin
                enable_write_memory <= 1;
                dado_escrita_memoria <= 244;
                pos_pixel_w = pos_pixel_w + 1;
            end else begin
                estado = 1;
                pos_pixel_w = 0;
                enable_write_memory <= 0;
            end
        end

        1: begin // mostrando na tela
            if (ativo && x >= x_pos) begin
                vga_r_int <= 255;
                vga_g_int <= 0;
                vga_b_int <= 0;
            end else if (ativo) begin // tela fora cursor
                vga_r_int <= 0;
                vga_g_int <= 255;
                vga_b_int <= cor_atual_vga;
                pos_pixel_r <= 640*(y- 1 - 35) + x - 1 - 143; // o x e o y do vga não começam em zero
                // É necessário desloca-los
            end else begin // fora da tela
                vga_r_int <= 0;
                vga_g_int <= 0;
                vga_b_int <= 0;
            end
        end
    endcase
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
