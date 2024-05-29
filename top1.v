module top1 (

   // CLOCK
   input  CLOCK_50,
	input  CLOCK2_50,

   KEY_N,

   // SW
	input [9:0] SW,

  // VGA
  output [7:0] VGA_B,
  output VGA_BLANK_N,
  output VGA_CLK,
  output [7:0] VGA_G,
  output VGA_HS,
  output [7:0] VGA_R,
  output VGA_SYNC_N,
  output VGA_VS,

   // GPIO_1
  inout [35:0] GPIO_1,
   //Key
  input [3:0] KEY

);

    
endmodule