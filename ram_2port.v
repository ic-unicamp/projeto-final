// Código base buscado na internet
module ram_2port (
    input clk,               // Clock
    // Porta de Escritall
    input we,                // Sinal de habilitação de escrita
    input[0:19] write_addr, // Endereço de escrita
    input [8:0] data_in,    // Dados de entrada para escrita
    // Porta de Leitura
    input  re,                // Sinal de habilitação de leitura
    input [0:19] read_addr,  // Endereço de leitura
    output reg [8:0] data_out,    // Dados de saída peara leitura
    input initializing,
    output reg initialized
);

// Declaração da memória
reg [8:0] buffer [0:640*480];
reg [0:19] initialization_write_addr = 0;
initial initialized = 0;

// Processo de Escrita
always @(posedge clk) begin
    if (initializing) begin
        if (initialization_write_addr >= 640*480) begin
            initialized = 1;
        end
        else begin
            // buffer[initialization_write_addr] <= initialization_write_addr/1200;
            buffer[initialization_write_addr] <= 9'b111111111; // branco
            initialization_write_addr = initialization_write_addr + 1;
        end
    end 

    else if (we) begin
        buffer[write_addr] <= data_in;
        initialization_write_addr = 0;
        initialized = 0;
    end
    // buffer[debug_pixel_i] <= debug_pixel_i%120;
    // debug_pixel_i <= debug_pixel_i + 1;
end

// Processo de Leitura
always @(posedge clk) begin
    if (re) begin
        data_out <= buffer[read_addr];
    end
end

endmodule
