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

wire enable_write_memory; // Controle para saber se a memória ira guardar algo. Quem gera esse sinal é o cursor
wire [0:19] pos_pixel_w; // Endereço da memória onde será pintado ou não em um determinadomomento momento, gerado pelo cursor
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
reg initializing_memory = 0;
wire memory_initialized;


ram_2port MEMORIA(
                  .reset(reset),
						.clk(CLOCK_50),
                  .we(enable_write_memory),
                  .data_in(dado_escrita_memoria),
                  .write_addr(pos_pixel_w),
                  .re(ativo),
                  .read_addr(pos_pixel_r),
                  .data_out(cor_atual_vga),
                  .initializing(initializing_memory),
                  .initialized(memory_initialized)
                  );


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

wire [10:0] x;
wire [10:0] y;
reg [5:0] radius = 5; // raio de pintura do cursor
reg [5:0] draw = 1; // raio de pintura do cursor
wire ativo;
reg power;
reg [7:0] vga_r_int, vga_g_int, vga_b_int;

// CONTROLADOR PARA TESTES
wire [10:0] cursor_x_pos;
wire [10:0] cursor_y_pos;
controller CONTROLADOR(
  .clk(CLOCK_50),
  .KEY(KEY),
  .SW(SW),
  .x_pos(cursor_x_pos),
  .y_pos(cursor_y_pos),
);

cursor CURSOR(
  .clk(CLOCK_50),
  .radius(radius),
  .draw(draw),
  .x(cursor_x_pos),
  .y(cursor_y_pos),
  .enable_write_memory(enable_write_memory),
  .pos_pxl(pos_pixel_w),
);

reg [10:0] x_pos;
reg [10:0] y_pos;


always @(posedge CLOCK_50) begin
	x_pos = cursor_x_pos + 144;
	y_pos = cursor_y_pos + 36;
    dado_escrita_memoria = 120;

    case(estado)
        0: begin // Inicializando memória
            initializing_memory = 1;
            if (memory_initialized) begin
                initializing_memory = 0;
                estado = 1;
            end
        end

        1: begin // mostrando na tela
            if (ativo && ((x == x_pos && y >= y_pos - 5 && y <= y_pos + 5) || (y == y_pos && x >= x_pos - 5 && x <= x_pos + 5))) begin // cursor
                vga_r_int <= 255;
                vga_g_int <= 0;
                vga_b_int <= 0;
            end else if (ativo) begin // tela fora cursor
                vga_r_int <= cor_atual_vga;
                vga_g_int <= cor_atual_vga;
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

    if (SW[0]) begin // reset
        estado = 0;
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
