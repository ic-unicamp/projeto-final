module buffer(
	input CLOCK_50,
    input reset,

	input write_enable,
	input [7:0] data_in,
	input [10:0] data_in_x,
	input [10:0] data_in_y,
	
	output reg [7:0] data_out,
	input [10:0] data_out_x,
	input [10:0] data_out_y
);
    reg [7:0] framebuffer [0:239][0:319];
    integer i, j;

    always @(posedge CLOCK_50) begin
        if (reset == 0) begin
            
            end

        else begin 
            if (write_enable) begin
            framebuffer[data_in_y][data_in_x] = data_in;
            end
            data_out = framebuffer[data_out_y >> 1][data_out_x >> 1];
            end
    end

endmodule
