`timescale 1ns / 1ps

module branch_control(
    input [2:0] funct3,
    input zero_flag,
    input less_than_flag,
    output reg branch_taken
);

    localparam BEQ  = 3'b000;
    localparam BNE  = 3'b001;
    localparam BLT  = 3'b100;
    localparam BGE  = 3'b101;
    localparam BLTU = 3'b110;
    localparam BGEU = 3'b111;

    always @(*) begin
        case (funct3)
            BEQ:  branch_taken = zero_flag;
            BNE:  branch_taken = ~zero_flag;
            BLT:  branch_taken = less_than_flag;
            BGE:  branch_taken = ~less_than_flag;
            BLTU: branch_taken = less_than_flag;
            BGEU: branch_taken = ~less_than_flag;
            default: branch_taken = 1'b0;
        endcase
    end

endmodule
