 module top2 (

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

 wire locked; //variavel
 pll CLOCK24(
 	 .refclk(CLOCK_50),
     .rst(~KEY[0]),
     .outclk_0(GPIO_1[20]),
     .locked(locked)
     );

 wire href;
 wire pclock;
 wire [19:0] pixel_detect;
 wire ativa_pincel; // Saber se achou a luva ou não

 assign href = GPIO_1[22];
 assign pclock = GPIO_1[21];

wire enable_write_memory_camera; // Controle para saber se a memória guardar a informação da câmera. Quem gera esse sinal é a prórpria câmera


 camera CAMERA( 
    .href(href),
    .pclk(pclock),
    .reset(~KEY[0]),
    .pwdn(GPIO_1[10]),
    .byte_camera(GPIO_1[19:12]),
    .detect_pos_pixel(pixel_detect),
    .achou_out(ativa_pincel),
    .enable_write_memory(enable_write_memory_camera)
    );
 reg [10:0] x_detect;
 reg [10:0] y_detect;

 wire [0:19] pos_pxl_w; // Endereço da memória onde será pintado ou não em um determinadomomento momento, gerado pelo cursor
 reg [19:0] write_addr;
 reg [5:0] radius = 20; // raio de pintura do cursor
 wire draw; // raio de pintura do cursor
 assign draw = ~SW[0]; // Controle de quando pinta
wire enable_write_memory_cursor; // Controle para saber se a memória guardar a informação da câmera. Quem gera esse sinal é a prórpria câmera


 cursor CURSOR(
 	.clk(CLOCK_50),
 	.radius(radius),
 	.draw(draw),
 	.x(x_detect),
 	.y(y_detect),
 	.enable_write_memory(enable_write_memory_cursor),
 	.pos_pxl_w(pos_pxl_w),
 );

 reg [8:0] dado_escrita_memoria;
 reg initializing_memory = 0;
 wire memory_initialized;
 wire [8:0] cor_atual_vga; // COR concatenada 3 BITS para cada cor
 reg [19:0] pos_pxl_r; // Endereço da memória onde será lida informação pelo vga para por na tela 


reg enable_write_memory;

 ram_2port MEMORIA(
 	.clk(CLOCK_50),
 	.we(enable_write_memory),
 	.data_in(dado_escrita_memoria),
 	.write_addr(write_addr),
 	.re(ativo),
 	.read_addr(pos_pxl_r),
 	.data_out(cor_atual_vga),
 	.initializing(initializing_memory),
 	.initialized(memory_initialized)
 );

 wire borracha;
 assign borracha = SW[2]; // PROVISORIO 
 wire [2:0] r_escrita_memoria;
 wire [2:0] g_escrita_memoria;
 wire [2:0] b_escrita_memoria;
 assign mudar_cor = SW[0];

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

 wire [10:0] x;
 wire [10:0] y;
 wire ativo;

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

 assign VGA_R = vga_r_int;
 assign VGA_G = vga_g_int;
 assign VGA_B = vga_b_int;
 reg [7:0] vga_r_int, vga_g_int, vga_b_int;
 reg [10:0] vga_cursor_x_pos;   //posicao corrigida sobre qual x deve ser obtido da memoria
 reg [10:0] vga_cursor_y_pos;   //idem para o y
 reg [4:0] estado = 0;
 
always @(posedge VGA_VS) begin
    y_detect <= pixel_detect/640;
    x_detect <= pixel_detect%640;
 end //tentando diminuir o ruido


always @(posedge CLOCK_50) begin
    if (~SW[3]) begin
        enable_write_memory = enable_write_memory_cursor;
        write_addr <= pos_pxl_w;
        dado_escrita_memoria = {r_escrita_memoria, g_escrita_memoria, b_escrita_memoria};
        //concatenação das saídas do color control para saber como colorir o pixel do vga
        pos_pxl_r <= 640*(y - 36) + x - 145; // o x e o y do vga não começam em zero
            //qual pixel do quadro atualmente está pegando
            vga_cursor_x_pos = x_detect + 145; //145
            vga_cursor_y_pos = y_detect + 36;    //36

        case(estado)
            0: begin // Inicializando memória
                initializing_memory = 1;
                if (memory_initialized) begin
                    initializing_memory = 0;
                    estado = 1;
                end
            end

            1: begin // mostrando na tela
                if (SW[0] && ativo) begin // controle de cor
                //mostra a cor do color control (cor do pincel)
                    vga_r_int <= r_escrita_memoria << 5;
                    vga_g_int <= g_escrita_memoria << 5;
                    vga_b_int <= b_escrita_memoria << 5;
                end
                else if (ativo && (((x == vga_cursor_x_pos) && (y >= vga_cursor_y_pos - radius) && (y <= vga_cursor_y_pos + radius)) || ((y == vga_cursor_y_pos) && (x >= vga_cursor_x_pos - radius) && (x <= vga_cursor_x_pos + radius)))) begin // cursor
                    //checa os limites faz uma cruz em volta do pincel
                    vga_r_int <= 255;
                    vga_g_int <= 0;
                    vga_b_int <= 0;
                end else if (ativo) begin // tela fora cursor
                    //se o cursor nao deve ser mostrado apenas copia o quadro (memoria) para o vga
                    vga_r_int <= cor_atual_vga[8:6] << 5;
                    vga_g_int <= cor_atual_vga[5:3] << 5;
                    vga_b_int <= cor_atual_vga[2:0] << 5;
                    // É necessário desloca-los
                end else begin // fora da tela
                    vga_r_int <= 0;
                    vga_g_int <= 0;
                    vga_b_int <= 0;
                end
            end
        endcase

        if (SW[8]) begin // reset
            estado = 0;
        end
    end
    else begin
        enable_write_memory = enable_write_memory_camera;
        dado_escrita_memoria = GPIO_1[19:12];
        if (ativo) begin
            if ((x-143==x_detect || y-35==y_detect) && ativa_pincel) begin
                vga_r_int <= 0;
                vga_g_int <= 0;
                vga_b_int <= 255;
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
        end
    end
end
endmodule