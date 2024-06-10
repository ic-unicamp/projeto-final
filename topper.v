module topper (

    // CLOCK
    input  CLOCK_50,

    KEY_N,
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

wire enable_write_memory; // Controle para saber se a memória ira guardar algo. Quem gera esse sinal é o cursor
reg [8:0] dado_escrita_memoria;
wire [0:19] pos_pxl_w; // Endereço da memória onde será pintado ou não em um determinadomomento momento, gerado pelo cursor
wire ativo;
reg [0:19] pos_pxl_r; // Endereço da memória onde será lida informação pelo vga para por na tela 
wire [8:0] cor_atual_vga;
reg initializing_memory = 0;
wire memory_initialized;

ram_2port MEMORIA(
	.clk(CLOCK_50),
	.we(enable_write_memory),
	.data_in(dado_escrita_memoria),
	.write_addr(pos_pxl_w),
	.re(ativo),
	.read_addr(pos_pxl_r),
	.data_out(cor_atual_vga),
	.initializing(initializing_memory),
	.initialized(memory_initialized)
);



wire [10:0] x;
wire [10:0] y;

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
wire mover_controlador;
assign mover_controlador = ~SW[0];
controller CONTROLADOR(
	.clk(CLOCK_50),
	.KEY(KEY),
	.SW(SW),
	.cursor_x_pos(cursor_x_pos),
	.cursor_y_pos(cursor_y_pos),
    .mover_controlador(mover_controlador),
);



reg [5:0] radius = 20; // raio de pintura do cursor
wire draw; // raio de pintura do cursor
assign draw = mover_controlador; // pra garantir que estamos na tela principal do paint, não no controle de cor       PROVISORIO 
cursor CURSOR(
	.clk(CLOCK_50),
	.radius(radius),
	.draw(draw),
	.x(cursor_x_pos),
	.y(cursor_y_pos),
	.enable_write_memory(enable_write_memory),
	.pos_pxl_w(pos_pxl_w),
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



assign VGA_R = vga_r_int;
assign VGA_G = vga_g_int;
assign VGA_B = vga_b_int;
reg [7:0] vga_r_int, vga_g_int, vga_b_int;

reg [10:0] vga_cursor_x_pos;
reg [10:0] vga_cursor_y_pos;
reg [4:0] estado = 0;

always @(posedge CLOCK_50) begin
	vga_cursor_x_pos = cursor_x_pos + 145;
	vga_cursor_y_pos = cursor_y_pos + 36;
    dado_escrita_memoria = {r_escrita_memoria, g_escrita_memoria, b_escrita_memoria};
    pos_pxl_r <= 640*(y - 36) + x - 145; // o x e o y do vga não começam em zero

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
                vga_r_int <= r_escrita_memoria << 5;
                vga_g_int <= g_escrita_memoria << 5;
                vga_b_int <= b_escrita_memoria << 5;
            end
            else if (ativo && (((x == vga_cursor_x_pos) && (y >= vga_cursor_y_pos - radius) && (y <= vga_cursor_y_pos + radius)) || ((y == vga_cursor_y_pos) && (x >= vga_cursor_x_pos - radius) && (x <= vga_cursor_x_pos + radius)))) begin // cursor
                vga_r_int <= 255;
                vga_g_int <= 0;
                vga_b_int <= 0;
            end else if (ativo) begin // tela fora cursor
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
    
endmodule
