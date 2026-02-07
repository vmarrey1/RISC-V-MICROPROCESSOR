`timescale 1ns / 1ps

module riscv_cpu_tb;

    reg clk;
    reg reset;
    wire [31:0] pc_out;
    wire [31:0] instruction_out;
    wire [31:0] alu_result_out;
    wire [31:0] reg_data1_out;
    wire [31:0] reg_data2_out;
    
    riscv_cpu uut (
        .clk(clk),
        .reset(reset),
        .pc_out(pc_out),
        .instruction_out(instruction_out),
        .alu_result_out(alu_result_out),
        .reg_data1_out(reg_data1_out),
        .reg_data2_out(reg_data2_out)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        $display("=========================================");
        $display("RISC-V CPU Testbench");
        $display("=========================================\n");
        
        reset = 1;
        $display("[%0t] Reset asserted", $time);
        #20;
        reset = 0;
        $display("[%0t] Reset released - CPU starting execution\n", $time);
        
        #1000;
        
        $display("\n=========================================");
        $display("Test Complete");
        $display("=========================================");
        $display("Final PC: 0x%08h", pc_out);
        $display("Final Instruction: 0x%08h", instruction_out);
        $display("Final ALU Result: 0x%08h", alu_result_out);
        $display("=========================================\n");
        
        $finish;
    end
    
    always @(posedge clk) begin
        if (!reset) begin
            $display("[%0t] PC=0x%08h | Inst=0x%08h | ALU=0x%08h", 
                     $time, pc_out, instruction_out, alu_result_out);
        end
    end

endmodule
