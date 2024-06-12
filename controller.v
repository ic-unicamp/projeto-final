module controller (

	input  clk,
	input [3:0] KEY,
	input [9:0] SW,
	output reg [10:0] cursor_x_pos,
	output reg [10:0] cursor_y_pos,
	input mover_controlador
);

reg [3:0] estado = 5;
reg [4:0] step = 8;
reg [20:0] contador_anti_teleporte = 0;


always @(posedge clk) begin
	
	if (SW[8]) begin
		contador_anti_teleporte = contador_anti_teleporte + 1;
		if (contador_anti_teleporte > 100000) begin
			estado = 5;
		end
	end else begin
		contador_anti_teleporte = 0;
	end
	
	case (estado)

	5: begin
        cursor_x_pos = 600;
        cursor_y_pos = 480;
		if (!SW[8]) begin
        	estado = 4;
		end
    end

    4: begin // esperando apertar botao
		if (mover_controlador) begin
			if (!KEY[3]) begin
				if (cursor_y_pos < step) begin
					cursor_y_pos = 0;
				end
				else begin
					cursor_y_pos = cursor_y_pos - step;
				end
				estado = 3;
			end 
			else if (!KEY[2]) begin
				cursor_y_pos = cursor_y_pos + step;
				if (cursor_y_pos >= 480) begin
					cursor_y_pos = 479;
				end
				estado = 2;
			end
			else if (!KEY[1]) begin
				if (cursor_x_pos < step) begin
					cursor_x_pos = 0;
				end
				else begin
					cursor_x_pos = cursor_x_pos - step;
				end
				estado = 1;
			end
			else if (!KEY[0]) begin
				cursor_x_pos = cursor_x_pos + step;
				if (cursor_x_pos >= 640) begin
					cursor_x_pos = 639;
				end
				estado = 0;
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

    0: begin // botao KEY0 pressionado
		if (KEY[0]) begin
			estado = 4;
		end
    end

 	endcase
end

endmodule

