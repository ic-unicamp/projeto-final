module zera_buffer(
    input reset,
    input clock,

    output reg [10:0] x_coord,
    output reg [10:0] y_coord,
    output reg zera_buffer
);

    always @(posedge clock) begin
        if (reset == 0) begin
            x_coord = 0;
            y_coord = 0;
            zera_buffer = 0;
        end

        else begin
            zera_buffer = 1;
            x_coord = x_coord + 1;
            if (x_coord == 240) begin
                x_coord = 0;
                y_coord = y_coord + 1;
                if (y_coord == 525)
                    y_coord = 0;
                end
            end
    end




endmodule