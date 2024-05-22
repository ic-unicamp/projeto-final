module buffer(
    // Auxiliares
	input CLOCK_50,
	input write_enable,
    input reset,

    // Cor para pintar
	input [7:0] rdata_in,
    input [7:0] gdata_in,
    input [7:0] bdata_in,
    // Posição da bola
	input [10:0] ball_x,
	input [10:0] ball_y,

    // Tamanho da bola
    input [6:0] SIZE,
    // Deslocamento da bola
    input [6:0] STEP,
    // Direção da bola
    input [1:0] ball_direction,

	// Posição de leitura
	input [10:0] data_out_x,
	input [10:0] data_out_y,

    // Cores de saída
    output reg [7:0] rdata_out,
    output reg [7:0] gdata_out,
    output reg [7:0] bdata_out
);
    
    integer row;
    integer col;
	reg [7:0] rbuffer [0:239][0:319];
    reg [7:0] gbuffer [0:239][0:319];
	reg [7:0] bbuffer [0:239][0:319];
    reg [10:0] out_x;
    reg [10:0] out_y;

    initial begin
        // Pintar a matriz inicialmente
        for (row = 0; row <= 239; row = row + 1) begin
            for (col = 0; col <= 319; col = col + 1) begin
                rbuffer[row][col] = 0;
                gbuffer[row][col] = 0;
                bbuffer[row][col] = 0;
            end
        end
    end

	always @(posedge CLOCK_50) begin 
        if (~reset) begin
            // Pintar a matriz inicialmente
            for (row = 0; row <= 239; row = row + 1) begin
                for (col = 0; col <= 319; col = col + 1) begin
                    rbuffer[row][col] = 0;
                    gbuffer[row][col] = 0;
                    bbuffer[row][col] = 0;
                end
            end
        end
        else begin
            if (write_enable) begin
                // Cor da bola - pintar na matriz
                for (row = 0; row <= 239; row = row + 1) begin
                    for (col = 0; col <= 319; col = col + 1) begin
                        if (row >= ball_y && row <= ball_y + SIZE && col >= ball_x && col <= ball_x + SIZE) begin
                            // Colorir a bola
                            rbuffer[row][col] = 0;
                            gbuffer[row][col] = 0;
                            bbuffer[row][col] = 100;
                        end
                        else begin
                            case (ball_direction)
                                3'b000:  begin  // UP
                                    rbuffer[row][col] = 0;
                                    gbuffer[row][col] = 0;
                                    bbuffer[row][col] = 0;
                                    end
                                3'b001: begin // DOWN
                                    rbuffer[row][col] = 0;
                                    gbuffer[row][col] = 0;
                                    bbuffer[row][col] = 0;                                    
                                    end
                                3'b010: begin // LEFT
                                    rbuffer[row][col] = 0;
                                    gbuffer[row][col] = 0;
                                    bbuffer[row][col] = 0;                                    
                                    end
                                3'b011: begin // RIGHT
                                    rbuffer[row][col] = 0;
                                    gbuffer[row][col] = 0;
                                    bbuffer[row][col] = 0;
                                    end
                                endcase
                        end
                    end
                end
            end
            // Read data
            out_x = data_out_x >> 1;
            out_y = data_out_y >> 1;
            rdata_out = rbuffer[out_y][out_x];
            gdata_out = gbuffer[out_y][out_x];
            bdata_out = bbuffer[out_y][out_x];
        end
	end
	
endmodule

// for (row = ball_y; row <= ball_y + SIZE; row = row + 1) begin
//     for (col = ball_x; col <= ball_x + SIZE; col = col + 1) begin
//         // Access elements in the specified range
//         rbuffer[row][col] = 0;
//         gbuffer[row][col] = 0;
//         bbuffer[row][col] = 100;
//     end
// end