 module top2 (

   // CLOCK
    input  CLOCK_50,
    input  CLOCK2_50,

    KEY_N,

   // SW
 	input [9:0] SW,
    //SW[0] = muda para color control
    //SW[1] = mostra camera

    // SW[8]: reseta cor de pintura para preto
    // SW[9]: reseta a memoria

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
    //KEY[3] = ativa pincel (desenha)
    //KEY[2] = borracha
    //KEY[0] = reset cam
 );

 wire locked; //variavel
 pll CLOCK24(
    .refclk(CLOCK_50),
    .rst(~KEY[0]),
    .outclk_0(GPIO_1[20]),
    .locked(locked)
);

wire href;

wire pclock;
assign pclock = GPIO_1[21];
wire enable_write_memory_cam; // Controle para saber se a memória guardar a informação da câmera. Quem gera esse sinal é a prórpria câmera
wire [19:0] pos_pixel_w_cam; // Endereço da memória onde será guardado a info da câmera, gerado pela câmera.
wire [7:0] pixel_type_cam;  //escala de cinza ou codigo da cor enviada
wire [19:0] dedo_pos_detect; // posicao de detecção do dedo
//posicao no vetor e nao na matriz
wire achou_dedo;

wire power;
assign power = ~KEY[0];

assign GPIO_1[10] = power; //power dowm
assign href = GPIO_1[22];

camera CAMERA( 
    .href(href),
    .pclk(pclock),
    .reset(~KEY[0]),
    .pwdn(GPIO_1[10]),
    .enable_write_memory(enable_write_memory_cam),
    .pos_pxl(pos_pixel_w_cam),
    .byte_camera(GPIO_1[19:12]),
    .pixel_out(pixel_type_cam),
    .detect_pos_pixel(dedo_pos_detect),
    .achou_out(achou_dedo)
);


reg enable_write_memory_in; //ativa ou nao a entrada de dados
reg [8:0] data_in;     //dados de da pintada
reg [19:0] write_addr; //endereço de escrita na memoria
reg [19:0] read_addr;
wire [8:0] data_out;
reg initializing_memory = 0;
wire memory_initialized;

ram_2port MEMORIA(
				.clk(CLOCK_50),
                .we(enable_write_memory_in),
                .data_in(data_in),
                .write_addr(write_addr),
                .re(ativo),
                .read_addr(read_addr),
                .data_out(data_out),
                .initializing(initializing_memory),
                .initialized(memory_initialized)
                );


wire ativo;     //se refere a ativação do vga
wire [10:0] x_vga;  //é deslocado em +145
wire [10:0] y_vga;  //idem +36
reg [7:0] vga_r_int, vga_g_int, vga_b_int;
//regs usados pra fazer alterações iteradas

assign VGA_R = vga_r_int;
assign VGA_G = vga_g_int;
assign VGA_B = vga_b_int;

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
  .x(x_vga),
  .y(y_vga),
);


reg [5:0] radius = 6; // raio de pintura do cursor
wire draw;
assign draw = ~KEY[3]&&~mudar_cor; //fala se é pro cursor escrever na memoria
wire borracha;
assign borracha = ~KEY[2]&&~mudar_cor;
wire enable_write_memory_cursor;
wire [19:0] pos_pixel_w_cursor;

cursor CURSOR(
	.clk(CLOCK_50),
	.radius(radius),
	.draw(draw || borracha),
	.x(x_pos_dedo),
	.y(y_pos_dedo),
	.enable_write_memory(enable_write_memory_cursor),
	.pos_pxl_w(pos_pixel_w_cursor),
);


wire [2:0] r_escrita_memoria;
wire [2:0] g_escrita_memoria;
wire [2:0] b_escrita_memoria;
wire mudar_cor = SW[0]; // controla se escolho a cor ou se pinto 

color_control COLOR_CONTROL(
	.clk(CLOCK_50),
	.KEY(KEY),
	.SW(SW),
    .borracha(borracha),
	.r_escrita_memoria(r_escrita_memoria),
	.g_escrita_memoria(g_escrita_memoria),
    .b_escrita_memoria(b_escrita_memoria),
    .mudar_cor(mudar_cor),
);

wire modo_operacao;
assign modo_operacao = SW[1];
//abaixado = 0 mostra paint
//levantado = 1 mostra camera

reg [10:0] x_pos_dedo;
reg [10:0] y_pos_dedo;

always @(posedge VGA_VS) begin
    y_pos_dedo <= dedo_pos_detect/640;
    x_pos_dedo <= dedo_pos_detect%640;
end //tentando diminuir o ruido

reg [10:0] vga_cursor_x_pos;
reg [10:0] vga_cursor_y_pos;
reg [4:0] estado = 0;

always @(posedge CLOCK_50) begin
    read_addr <= 640*(y_vga- 1 - 35) + x_vga - 1 - 144; // o x e o y do vga n~ao começam em zero
    case(estado)
        0: begin // Inicializando memória
            initializing_memory = 1;
            if (memory_initialized) begin
                initializing_memory = 0;
                estado = 1;
            end
        end

        1: begin // estado principal
            if (modo_operacao == 0) begin
                if (SW[0] && ativo) begin // controle de cor
                    vga_r_int <= r_escrita_memoria << 5;
                    vga_g_int <= g_escrita_memoria << 5;
                    vga_b_int <= b_escrita_memoria << 5;
                end
                else if (ativo && (((x_vga == vga_cursor_x_pos) && (y_vga >= vga_cursor_y_pos - radius) && (y_vga <= vga_cursor_y_pos + radius)) || ((y_vga == vga_cursor_y_pos) && (x_vga >= vga_cursor_x_pos - radius) && (x_vga <= vga_cursor_x_pos + radius)))) begin // cursor
                    vga_r_int <= 255;
                    vga_g_int <= 0;
                    vga_b_int <= 0;
                end else if (ativo) begin // tela fora cursor
                    vga_r_int <= data_out[8:6] << 5;
                    vga_g_int <= data_out[5:3] << 5;
                    vga_b_int <= data_out[2:0] << 5;
                    // É necessário desloca-los
                end else begin // fora da tela
                    vga_r_int <= 0;
                    vga_g_int <= 0;
                    vga_b_int <= 0;
                end
                if (!KEY[1] && ~mudar_cor) begin
                    radius = radius + 2;
                    if (radius > 20) begin
                        radius = 6;
                    end
				    estado = 2;
			    end
            end
            else begin
                // É necessário desloca-los.
                if (ativo) begin
                    if ((x_vga-145==x_pos_dedo || y_vga-36==y_pos_dedo) && achou_dedo) begin
                        vga_r_int <= 0;
                        vga_g_int <= 0;
                        vga_b_int <= 255;
                    end
                    else if(~achou_dedo && y_vga==239) begin
                        vga_r_int <= 255;
                        vga_g_int <= 127;
                        vga_b_int <= 127;
                    end
                    else begin
                        if (data_out[7:0] > 127) begin
                            vga_r_int <= 127;
                            vga_g_int <= 255;
                            vga_b_int <= 127;
                        end
                        else begin
                            vga_r_int <= data_out[7:0]<<1;
                            vga_g_int <= data_out[7:0]<<1;
                            vga_b_int <= data_out[7:0]<<1;
                        end
                    end
                end
                else begin
                    vga_r_int <= 0;
                    vga_g_int <= 0;
                    vga_b_int <= 0;
                end
            end
        end
        2: begin
            if (KEY[1]) begin
			    estado = 1;
		    end
        end
    endcase

    if (SW[9]) begin // reset da memoria
        estado = 0;
    end
end

always @(posedge CLOCK_50) begin
    if (modo_operacao == 0) begin
        vga_cursor_x_pos = x_pos_dedo + 145;
	    vga_cursor_y_pos = y_pos_dedo + 36;
        enable_write_memory_in <= enable_write_memory_cursor;
        write_addr <= pos_pixel_w_cursor;
        data_in <= {r_escrita_memoria, g_escrita_memoria, b_escrita_memoria};
    end
    else begin
        enable_write_memory_in <= enable_write_memory_cam;
        write_addr <= pos_pixel_w_cam;
        data_in <= pixel_type_cam;
    end 

end

endmodule