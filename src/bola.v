module bola(
    input CLOCK_50,
    input reset,
    input pausa,
    input reiniciarJogo,
    input xi,
    input yi,
    input ehAliada,
    inout iniciar_movimento,
    output reg [9:0] x,
    output reg [9:0] y,
    output reg [9:0] raio
);
    reg movimentar = 0;

    always @(posedge CLOCK_50 or posedge reset) begin
        if (reset) begin
            x = 1000;
            y = 1000;
            raio = 5;
        end else if (pausa == 0) begin
            if (iniciar_movimento && !movimentar) begin
                x = xi;
                y = yi;
                iniciar_movimento = 0;
                movimentar = 1;
            end
            if (movimentar) begin
                if (ehAliada) begin
                    y = y - 1;
                end else begin
                    y = y + 1;
                end

                if (y <= 0 || y >= 500) begin
                    movimentar = 0;
                    x = 1000;
                    y = 1000;
                end
            end

        end
    end





endmodule