module bola(
    // Sinais
    input CLOCK_50,
    input reset,
    input pausa,
    input reiniciarJogo,

    // Coordenadas
    output reg[9:0] x,
    output reg[9:0] y,
    output reg[9:0] raio,

    // Tipo de nave
    input ehNave,
    input ehInimigo,

    // Saidas
    output wire atingiuInimigo,
    output wire atingiuNave
); // o placar lidará com as vidas

    assign resetBola = reset || reiniciarJogo;

    // Divisor de clock
	reg [32:0] divisorCLK;
    reg [32:0] contador;
    reg clk;

    // Atributos da bola
    reg sentido;

    always @(posedge CLOCK_50) begin // Divisor de clock
        contador = contador + 1;    
        if (contador >= divisorCLK) begin   
            contador = 0; 
            clk = ~clk;
        end 
    end

    always @(posedge CLOCK_50) begin
        x = 300;
        y = 300;
        raio = 50;
    end


    // always @(posedge clk) begin // Movimentação
    //     if (resetBola) begin


    //     end else begin

    //     end
    // end

endmodule