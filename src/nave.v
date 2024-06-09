module nave(
    input CLOCK_50,
    input reset,
    input [3:0] keysout,
    input pausa,
	input reiniciarJogo,
    
    output wire [9:0] largura_nave,
    output wire [9:0] altura_nave,
    output reg [9:0] x_nave,
    output reg [9:0] y_nave,

    output wire [9:0] x_bola,
    output wire [9:0] y_bola,
    output wire [9:0] raio_bola,
    output [9:0] LEDR
);

    wire [9:0] xi_bola;
    assign xi_bola = x_nave;
    wire [9:0] yi_bola;
    assign yi_bola = y_nave;
    reg bateu;
    reg iniciarBola;

    assign largura_nave = 30;
    assign altura_nave = 30;
    assign resetNave = reset || reiniciarJogo;

    bola bolaAliada(
        .CLOCK_50(CLOCK_50),
        .reset(resetNave),
        .pausa(pausa),
        .reiniciarJogo(reiniciarJogo),
        .xi(xi_bola),
        .yi(yi_bola),
        .ehAliada(1),
        .iniciar_movimento(1),
        .x(x_bola),
        .y(y_bola),
        .raio(raio_bola)
        // .LEDR(LEDR)
    );

    assign LEDR = x_nave;


    always @(posedge CLOCK_50 or posedge resetNave) begin
        if (resetNave) begin
            x_nave = 350;
            y_nave = 420;
            iniciarBola = 0;
        end else begin
            if (pausa == 0) begin
                if (keysout[0]) begin // direita
                    x_nave = x_nave + 1;
                end
                if (keysout[2]) begin // esquerda
                    x_nave = x_nave - 1;
                end
                // if (keysout[1]) begin // atirar
                //     iniciarBola = 1;
                // end
                if (bateu) begin
                    iniciarBola = 0;
                end
            end
        end
    end

endmodule