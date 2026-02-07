`timescale 1ns / 1ps

module instruction_memory(
    input [31:0] address,
    output reg [31:0] instruction
);

    reg [31:0] memory [0:1023];
    wire [31:0] word_address;
    wire [31:0] aligned_address;
    
    assign word_address = address >> 2;
    assign aligned_address = (word_address < 1024) ? word_address : 10'd0;
    
    always @(*) begin
        if (aligned_address < 1024) begin
            instruction = memory[aligned_address];
        end else begin
            instruction = 32'h00000013;
        end
    end
    
    initial begin
        memory[0] = 32'h00A00093;
        memory[1] = 32'h01400113;
        memory[2] = 32'h002081B3;
        memory[3] = 32'h00302023;
        memory[4] = 32'h00000013;
        memory[5] = 32'h00000013;
        
        for (integer i = 6; i < 1024; i = i + 1) begin
            memory[i] = 32'h00000013;
        end
    end

endmodule
