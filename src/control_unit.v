`timescale 1ns / 1ps

module control_unit(
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg reg_write_enable,
    output reg alu_src,
    output reg mem_to_reg,
    output reg mem_read,
    output reg mem_write,
    output reg branch,
    output reg jump,
    output reg [1:0] alu_op,
    output reg [1:0] imm_src
);

    localparam OP_R_TYPE = 7'b0110011;
    localparam OP_I_TYPE = 7'b0010011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_JAL    = 7'b1101111;
    localparam OP_JALR   = 7'b1100111;
    localparam OP_LUI    = 7'b0110111;
    localparam OP_AUIPC  = 7'b0010111;

    always @(*) begin
        reg_write_enable = 1'b0;
        alu_src = 1'b0;
        mem_to_reg = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        branch = 1'b0;
        jump = 1'b0;
        alu_op = 2'b00;
        imm_src = 2'b00;

        case (opcode)
            OP_R_TYPE: begin
                reg_write_enable = 1'b1;
                alu_src = 1'b0;
                mem_to_reg = 1'b0;
                alu_op = 2'b10;
            end
            
            OP_I_TYPE: begin
                reg_write_enable = 1'b1;
                alu_src = 1'b1;
                mem_to_reg = 1'b0;
                alu_op = 2'b10;
                imm_src = 2'b00;
            end
            
            OP_LOAD: begin
                reg_write_enable = 1'b1;
                alu_src = 1'b1;
                mem_to_reg = 1'b1;
                mem_read = 1'b1;
                alu_op = 2'b00;
                imm_src = 2'b00;
            end
            
            OP_STORE: begin
                alu_src = 1'b1;
                mem_write = 1'b1;
                alu_op = 2'b00;
                imm_src = 2'b01;
            end
            
            OP_BRANCH: begin
                branch = 1'b1;
                alu_op = 2'b01;
                imm_src = 2'b10;
            end
            
            OP_JAL: begin
                reg_write_enable = 1'b1;
                jump = 1'b1;
                imm_src = 2'b11;
            end
            
            OP_JALR: begin
                reg_write_enable = 1'b1;
                jump = 1'b1;
                alu_op = 2'b00;
                imm_src = 2'b00;
            end
            
            OP_LUI: begin
                reg_write_enable = 1'b1;
                alu_src = 1'b1;
                mem_to_reg = 1'b0;
                alu_op = 2'b11;
                imm_src = 2'b00;
            end
            
            OP_AUIPC: begin
                reg_write_enable = 1'b1;
                alu_src = 1'b1;
                mem_to_reg = 1'b0;
                alu_op = 2'b00;
                imm_src = 2'b00;
            end
            
            default: begin
            end
        endcase
    end

endmodule
