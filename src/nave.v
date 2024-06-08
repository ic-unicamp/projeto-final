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

    output reg [9:0] x_bola,
    output reg [9:0] y_bola,
    output reg [9:0] raio_bola
);

    wire [9:0] xi_bola;
    wire [9:0] yi_bola;
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
        .iniciar_movimento(iniciar_bola_aliada),
        .x(x_bola_aliada),
        .y(y_bola_aliada),
        .raio(raio_bola_aliada)
    );

    always @(posedge CLOCK_50 or posedge resetNave) begin
        if (resetNave) begin
            x_nave = 350;
            y_nave = 420;
            xi_bola = 1000;
            yi_bola = 1000;
            iniciarBola = 0;
        end else begin
            if (pausa == 0) begin
                if (keysout[0]) begin // direita
                    x_nave = x_nave + 1;
                end else if (keysout[2]) begin // esquerda
                    x_nave = x_nave - 1;
                end else if (keysout[1]) begin // atirar
                    xi_bola = x_nave + 15;
                    yi_bola = y_nave;
                    iniciarBola = 1;
                end
            end
        end
    end

endmodule