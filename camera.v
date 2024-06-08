module camera(
    inout scl,
    input sda,
    input href,
    output vsync,
    input pclk,
	 output hpclk,
    input xclk,
    input reset,
    input pwdn,
    output reg enable_write_memory,
    output reg [0:19] pos_pxl
);



reg half_pclock;

always @(posedge pclk)begin
	if (reset) begin
	half_pclock = 0;
	end
	else begin
    half_pclock <= !half_pclock;
    end
end

assign hpclk = half_pclock;
//Oia
always @(posedge pclk or posedge reset) begin
    if (reset) begin
        enable_write_memory <= 0;
        pos_pxl <= 0;
    end else begin
        if (href & half_pclock) begin 
            enable_write_memory <= 1;
            
            if (pos_pxl >= 640*480 - 1) begin
                pos_pxl <= 0;
            end else begin
                pos_pxl <= pos_pxl + 1;
            end
        end else begin
            enable_write_memory <= 0;
        end
    end
end





endmodule