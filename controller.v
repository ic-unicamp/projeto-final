module controller (

   input  clk,
   input [3:0] KEY,
   input [9:0] SW,
   output reg [10:0] cursor_x_pos,
   output reg [10:0] cursor_y_pos
);

reg [3:0] estado = 5;
reg [4:0] step = 16;


always @(posedge clk) begin
	
	if (SW[8]) begin
    	estado = 5;
    end
	
	case (estado)

	5: begin
        cursor_x_pos = 320;
        cursor_y_pos = 240;
		if (!SW[8]) begin
        	estado = 4;
		end
    end

    4: begin // esperando apertar botao
		if (!KEY[3]) begin
			estado = 3;
			if (cursor_y_pos < step) begin
				cursor_y_pos = cursor_y_pos + 480;
			end
			cursor_y_pos = cursor_y_pos - step;
		end 
		else if (!KEY[2]) begin
			estado = 2;
			cursor_y_pos = cursor_y_pos + step;
			if (cursor_y_pos >= 480) begin
				cursor_y_pos = cursor_y_pos - 480;
			end
		end
		else if (!KEY[1]) begin
			estado = 1;
			if (cursor_x_pos < step) begin
				cursor_x_pos = cursor_x_pos + 640;
			end
			cursor_x_pos = cursor_x_pos - step;
		end
		else if (!KEY[0]) begin
			estado = 0;
			cursor_x_pos = cursor_x_pos + step;
			if (cursor_x_pos >= 640) begin
				cursor_x_pos = cursor_x_pos - 640;
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

