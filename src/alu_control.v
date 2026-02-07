`timescale 1ns / 1ps

module alu_control(
    input [1:0] alu_op,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [3:0] alu_control
);

    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLL  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SLTU = 4'b1001;

    always @(*) begin
        case (alu_op)
            2'b00: begin
                alu_control = ALU_ADD;
            end
            
            2'b01: begin
                alu_control = ALU_SUB;
            end
            
            2'b10: begin
                case (funct3)
                    3'b000: begin
                        if (funct7[5] == 1'b1) begin
                            alu_control = ALU_SUB;
                        end else begin
                            alu_control = ALU_ADD;
                        end
                    end
                    3'b001: alu_control = ALU_SLL;
                    3'b010: alu_control = ALU_SLT;
                    3'b011: alu_control = ALU_SLTU;
                    3'b100: alu_control = ALU_XOR;
                    3'b101: begin
                        if (funct7[5] == 1'b1) begin
                            alu_control = ALU_SRA;
                        end else begin
                            alu_control = ALU_SRL;
                        end
                    end
                    3'b110: alu_control = ALU_OR;
                    3'b111: alu_control = ALU_AND;
                    default: alu_control = ALU_ADD;
                endcase
            end
            
            2'b11: begin
                alu_control = ALU_ADD;
            end
            
            default: alu_control = ALU_ADD;
        endcase
    end

endmodule
