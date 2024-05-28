module buffer (
	input clk,
	input [18:0] enderecoC,
	input [7:0] yIn,
	input write_enable,
	input [18:0] enderecoV,
	output reg [7:0] yOut
);

	reg [7:0] buffer [0:640*480];
	
	always @(posedge clk) begin
		if (write_enable) begin
			buffer[enderecoC] = yIn;
			yOut = buffer[enderecoV];
		end else begin
			yOut = buffer[enderecoV];
		end
	end

endmodule