module zera_buffer(
    input reset,
    input clock,

    output reg [10:0] x_coord,
    output reg [10:0] y_coord,
    output reg zera_buffer
);

    always @(posedge clock) begin
        x_coord = x_coord + 1;
        if (x_coord == 320) begin
            x_coord = 0;
            y_coord = y_coord + 1;
            if (y_coord == 240)
                y_coord = 0;
            end
        end



endmodule