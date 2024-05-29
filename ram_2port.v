// Código base buscado na internet
module ram_2port (
    input reset,
    input clk,               // Clock
    // Porta de Escrita
    input we,                // Sinal de habilitação de escrita
    input[0:19] write_addr, // Endereço de escrita
    input [7:0] data_in,    // Dados de entrada para escrita
    // Porta de Leitura
    input  re,                // Sinal de habilitação de leitura
    input [0:19] read_addr,  // Endereço de leitura
    output reg [7:0] data_out    // Dados de saída peara leitura
);

    // Declaração da memória
    reg [7:0] buffer [0:640*480];

    // Processo de Escrita
    always @(posedge clk) begin
        if (we) begin
            buffer[write_addr] <= data_in;
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
