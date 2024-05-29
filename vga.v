// #############################################################################
// DE1_SoC_top_level.v
//
// BOARD         : DE1-SoC from Terasic
// Author        : Sahand Kashani-Akhavan from Terasic documentation
// Revision      : 1.4
// Creation date : 04/02/2015
//
// Syntax Rule : GROUP_NAME_N[bit]
//
// GROUP  : specify a particular interface (ex: SDR_)
// NAME   : signal name (ex: CONFIG, D, ...)
// bit    : signal index
// _N     : to specify an active-low signal
// #############################################################################

module vga (

   input  CLOCK_50,
   input [3:0] KEY,
   input [9:0] SW,
   output VGA_BLANK_N,
   output VGA_CLK,
   output VGA_HS,
   output VGA_SYNC_N,
   output VGA_VS,
   output ativo_vga,
   output reg [10:0] x,
   output reg [10:0] y
);

assign VGA_BLANK_N = 1;
assign VGA_SYNC_N = 1;


wire reset;
reg clk25 = 0;
assign reset = SW[0];


always @(posedge CLOCK_50)begin
	if (reset) begin
	clk25 = 0;
	end
	else
    clk25 = !clk25;
end

always @(posedge clk25)
begin
   if (reset) begin
      x = 0;
      y = 0;
   end
   else begin
      x = x + 1;
      if (x >= 793) begin
         x = 0;
         y = y + 1;
         if (y >= 525) begin
					y = 0;
         end
      end
   end
end

assign VGA_HS = (x<96)? 0:1;
assign VGA_VS = (y<2)? 0:1;
assign ativo_vga = ((x>144) && (y>35))? 1:0;
assign VGA_CLK = clk25;

endmodule