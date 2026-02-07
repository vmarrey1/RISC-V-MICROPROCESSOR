`timescale 1ns / 1ps

module register_file(
    input clk,
    input reset,
    input reg_write_enable,
    input [4:0] read_addr1,
    input [4:0] read_addr2,
    input [4:0] write_addr,
    input [31:0] write_data,
    output reg [31:0] read_data1,
    output reg [31:0] read_data2
);

    reg [31:0] registers [31:0];
    integer i;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'd0;
            end
        end else if (reg_write_enable && write_addr != 5'd0) begin
            registers[write_addr] <= write_data;
        end
    end
    
    always @(*) begin
        read_data1 = (read_addr1 == 5'd0) ? 32'd0 : registers[read_addr1];
        read_data2 = (read_addr2 == 5'd0) ? 32'd0 : registers[read_addr2];
    end

endmodule
