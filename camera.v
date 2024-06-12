module camera(
    //inout scl,
    //input sda,
    input href,
    //output vsync,ll
    input pclk,
	//output hpclk,
    input xclk,
    input reset,
    input pwdn,
    output reg enable_write_memory,
    output reg [19:0] pos_pxl,
    input [7:0] byte_camera,
    output reg [7:0] pixel_out,
    output reg [19:0] detect_pos_pixel,
    output reg achou_out
);

//assign pixel_out = byte_camera;

// reg half_pclock;

reg [19:0] detect_pos_pixel_pre_out;

always @(posedge pclk)begin
	if (reset) begin
	half_pclock = 0;
	end
	else begin
    half_pclock <= !half_pclock;
    end
end

//assign hpclk = half_pclock;

//Oia

reg [7:0] pixel0;
reg [7:0] pixel1;
reg [1:0] estado;
reg [7:0] cb;
reg [7:0] y0;
reg [7:0] cr;
reg [7:0] y1;
reg alterna_pixel;
reg [1:0] estado_pixels;
reg [7:0] verdes_seguidos;
reg achou;
reg half_pclock;

always @(posedge pclk) begin
// Capturando
    if (href) begin
        case(estado)
            0: begin
                cb <= byte_camera;
                estado <= 1;
            end
            1: begin
                y0 <= byte_camera;
                estado <= 2;
            end
            2: begin
                cr <= byte_camera;
                estado <= 3;
					if (cb>140 && cr>152) begin
						pixel0 = 255;
					end
					else begin
						pixel0 = y0>>1;
					end
            end
            3: begin
                y1 <= byte_camera;
                estado <= 0;
                if (cb>140 && cr>152) begin
                    pixel1 = 255;
				end
                else begin
                    pixel1 = y0>>1;
                end
            end
        endcase
    end
    else begin
        estado = 0;
    end
end

always @(posedge pclk or posedge reset) begin
    if (reset) begin
        enable_write_memory <= 0;
        pos_pxl <= 0;
    end
    else begin
        if (href & half_pclock) begin
            enable_write_memory <= 1;
            pos_pxl <= pos_pxl + 1;

            if (alterna_pixel) begin
                pixel_out <= pixel0;
                alterna_pixel = ~alterna_pixel;
            end 
            else begin
                pixel_out <= pixel1;
                alterna_pixel = ~alterna_pixel;
            end
            
            //testando se há pixels seguidos abaixo
            if (pixel_out == 255 && achou==0) begin
                verdes_seguidos <= verdes_seguidos + 1;
            end
            else begin
                verdes_seguidos <= 0;
            end
            //pinta o primeiro pixel preto após 5 verdes seguidos
            if (verdes_seguidos > 5) begin
                pixel_out <= 254;
                achou <= 1;
                detect_pos_pixel_pre_out <= pos_pxl;
            end
				


            if (pos_pxl >= 640*480 - 1) begin
                if (achou == 0) begin
                    achou_out <= 0;
                end
                else begin
                    achou_out <= 1;
                    detect_pos_pixel <= detect_pos_pixel_pre_out;
                end
                pos_pxl <= 0;
                achou <= 0;
            end else begin

            end
        end 
        else begin
            enable_write_memory <= 0;
        end
    end
end


endmodule
