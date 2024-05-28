module nave(
    input CLOCK_50,
    input reset,
    output reg [9:0] xNave,
    output reg [9:0] yNave, 
    output reg [9:0] larguraNave, 
    output reg [9:0] alturaNave 
);
  
    reg [9:0] deslocamento = 8; 
    assign resetBarra = reset;
 
    always @(posedge CLOCK_50 or posedge resetBarra) begin
        if (resetBarra) begin
            xNave <= 270; 
            yNave <= 424;
            larguraNave <= 20; 
            alturaNave <= 20;  
        end 
        // else begin
        //     if (direita && ((xNave + deslocamento + larguraNave) < 640)) begin
        //             xNave <= xNave + deslocamento;
        //     end 
        //     if (esquerda && ((xNave - deslocamento) < 640)) begin
        //             xNave <= xNave - deslocamento;
        //     end 
        // end
    end

endmodule
