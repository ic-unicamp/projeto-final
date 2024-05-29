module controller (

   input  clk,
   input [3:0] KEY,
   input [9:0] SW,
   output reg [10:0] x_pos,
   output reg [10:0] y_pos
);

// implemente o circuito aqui
wire ativo;
reg [3:0] estado = 5;


always @(posedge clk) begin
  case (estado)
    4: begin // esperando apertar botao
      if (!KEY[3]) begin
        estado = 3;
        y_pos = y_pos - 16;
        if (y_pos >= 480) begin
          y_pos = 480;
        end
      end 
      else if (!KEY[2]) begin
        estado = 2;
        y_pos = y_pos + 16;
        if (y_pos > 480) begin
          y_pos = y_pos - 480;
        end
      end
      else if (!KEY[1]) begin
        estado = 1;
        x_pos = x_pos - 16;
        if (x_pos >= 640) begin
          x_pos = 640;
        end
      end
      else if (!KEY[0]) begin
        estado = 0;
        x_pos = x_pos + 16;
        if (x_pos > 640) begin
          x_pos = x_pos - 640;
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

    5: begin
        x_pos = 320;
        y_pos = 240;
        estado = 4;
    end

 	endcase

  if (SW[0]) begin
    x_pos = 320;
    y_pos = 240;
  end
end

endmodule

