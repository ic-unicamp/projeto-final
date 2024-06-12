module color_control (

    input  clk,
    input [3:0] KEY,
    input [9:0] SW,
    input borracha,
    output reg [2:0] r_escrita_memoria,
    output reg [2:0] g_escrita_memoria,
    output reg [2:0] b_escrita_memoria,
    input mudar_cor
);

reg [3:0] estado = 5;
reg [2:0] r_cor_atual;
reg [2:0] g_cor_atual;
reg [2:0] b_cor_atual;

always @(posedge clk) begin // muda a cor de pintura atual
	
	if (SW[8]) begin
    	estado = 5;
    end
	
	case (estado)

	5: begin
        r_cor_atual= 0;
        g_cor_atual = 0;
        b_cor_atual = 0;

		if (!SW[8]) begin
        	estado = 4;
		end
    end

    4: begin // esperando apertar botao
		if (mudar_cor) begin
			if (!KEY[3]) begin
				r_cor_atual = r_cor_atual + 1;
				estado = 3;
			end 
			else if (!KEY[2]) begin
				g_cor_atual = g_cor_atual + 1;
				estado = 2;
			end
			else if (!KEY[1]) begin
				b_cor_atual = b_cor_atual + 1;
				estado = 1;
			end
            else if (!KEY[0]) begin // reseta a cor pra preto
				estado = 5;
			end
		end
    end

    3: begin // botao KEY3 pressionado
		if (KEY[3]) begin
			estado = 4;
		end
    end

    2: begin // botao KEY2 pressionado
		if (KEY[2]) begin
			estado = 4;
		end
    end

    1: begin // botao KEY1 pressionado
		if (KEY[1]) begin
			estado = 4;
		end
    end

 	endcase
end

always @(posedge clk) begin // escolhe entre pincel e borracha

    case (borracha)
    0: begin // pincel
		r_escrita_memoria = r_cor_atual;
        g_escrita_memoria = g_cor_atual;
        b_escrita_memoria = b_cor_atual;
    end

    1: begin // borracha
		r_escrita_memoria = 7;
        g_escrita_memoria = 7;
        b_escrita_memoria = 7;
    end

 	endcase
end

endmodule

