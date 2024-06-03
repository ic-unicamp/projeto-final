module green_buffer(
	input CLOCK_50,
	input write_enable,
	input [7:0] data_in,
	input [10:0] data_in_x,
	input [10:0] data_in_y,
	input [10:0] data_out_x,
	input [10:0] data_out_y
	
	output reg [7:0] data_out,
);

	reg [7:0] green_buff [0:479][0:639];
	
	always @(posedge CLOCK_50) begin 
		if (write_enable) begin 
			green_buff[data_in_y][data_in_x] = data_in;
		end
		data_out = green_buff[data_out_y][data_out_x];
	end
	
endmodule