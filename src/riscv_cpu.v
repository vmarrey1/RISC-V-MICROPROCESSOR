`timescale 1ns / 1ps

module riscv_cpu(
    input clk,
    input reset,
    output [31:0] pc_out,
    output [31:0] instruction_out,
    output [31:0] alu_result_out,
    output [31:0] reg_data1_out,
    output [31:0] reg_data2_out
);

    reg [31:0] pc;
    reg [31:0] pc_plus_4;
    
    reg [31:0] if_id_pc;
    reg [31:0] if_id_instruction;
    reg [31:0] if_id_pc_plus_4;
    
    reg [31:0] id_ex_pc;
    reg [31:0] id_ex_pc_plus_4;
    reg [31:0] id_ex_imm;
    reg [31:0] id_ex_reg_data1;
    reg [31:0] id_ex_reg_data2;
    reg [4:0] id_ex_rs1;
    reg [4:0] id_ex_rs2;
    reg [4:0] id_ex_rd;
    reg [2:0] id_ex_funct3;
    reg [6:0] id_ex_funct7;
    reg id_ex_reg_write_enable;
    reg id_ex_mem_to_reg;
    reg id_ex_mem_read;
    reg id_ex_mem_write;
    reg id_ex_branch;
    reg id_ex_jump;
    reg [1:0] id_ex_alu_op;
    reg id_ex_alu_src;
    
    reg [31:0] ex_mem_pc_plus_4;
    reg [31:0] ex_mem_alu_result;
    reg [31:0] ex_mem_reg_data2;
    reg [4:0] ex_mem_rd;
    reg [2:0] ex_mem_funct3;
    reg ex_mem_reg_write_enable;
    reg ex_mem_mem_to_reg;
    reg ex_mem_mem_read;
    reg ex_mem_mem_write;
    reg ex_mem_branch;
    reg ex_mem_jump;
    reg ex_mem_branch_taken;
    reg [31:0] ex_mem_branch_target;
    
    reg [31:0] mem_wb_alu_result;
    reg [31:0] mem_wb_mem_read_data;
    reg [4:0] mem_wb_rd;
    reg mem_wb_reg_write_enable;
    reg mem_wb_mem_to_reg;
    
    wire [31:0] next_pc;
    wire [31:0] instruction;
    wire [6:0] opcode;
    wire [4:0] rs1, rs2, rd;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;
    wire [31:0] reg_data1, reg_data2;
    wire [31:0] alu_operand_a, alu_operand_b;
    wire [31:0] alu_result;
    wire [3:0] alu_control_signal;
    wire alu_zero, alu_less_than;
    wire [31:0] mem_read_data;
    wire [31:0] write_back_data;
    wire [31:0] immediate_value;
    wire branch_taken;
    wire [31:0] branch_target;
    wire [31:0] jump_target;
    
    wire reg_write_enable;
    wire alu_src;
    wire mem_to_reg;
    wire mem_read;
    wire mem_write;
    wire branch;
    wire jump;
    wire [1:0] alu_op;
    wire [1:0] imm_src;
    
    wire load_use_hazard;
    wire pc_write_enable;
    wire if_id_write_enable;
    wire if_id_flush;
    
    assign next_pc = (ex_mem_branch_taken || ex_mem_jump) ? 
                     ((ex_mem_jump) ? jump_target : ex_mem_branch_target) : 
                     (pc + 4);
    
    assign pc_write_enable = ~load_use_hazard;
    assign if_id_write_enable = ~load_use_hazard;
    assign if_id_flush = ex_mem_branch_taken || ex_mem_jump;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'h00000000;
        end else if (pc_write_enable) begin
            pc <= next_pc;
        end
    end
    
    instruction_memory imem(
        .address(pc),
        .instruction(instruction)
    );
    
    always @(posedge clk or posedge reset) begin
        if (reset || if_id_flush) begin
            if_id_pc <= 32'd0;
            if_id_instruction <= 32'h00000013;
            if_id_pc_plus_4 <= 32'd0;
        end else if (if_id_write_enable) begin
            if_id_pc <= pc;
            if_id_instruction <= instruction;
            if_id_pc_plus_4 <= pc + 4;
        end
    end
    
    instruction_decoder decoder(
        .instruction(if_id_instruction),
        .opcode(opcode),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .funct3(funct3),
        .funct7(funct7),
        .imm_i(imm_i),
        .imm_s(imm_s),
        .imm_b(imm_b),
        .imm_u(imm_u),
        .imm_j(imm_j)
    );
    
    control_unit ctrl(
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write_enable(reg_write_enable),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .jump(jump),
        .alu_op(alu_op),
        .imm_src(imm_src)
    );
    
    assign immediate_value = (imm_src == 2'b00) ? imm_i :
                            (imm_src == 2'b01) ? imm_s :
                            (imm_src == 2'b10) ? imm_b :
                            (imm_src == 2'b11) ? imm_j :
                            (opcode == 7'b0110111 || opcode == 7'b0010111) ? imm_u : imm_i;
    
    register_file rf(
        .clk(clk),
        .reset(reset),
        .reg_write_enable(mem_wb_reg_write_enable),
        .read_addr1(rs1),
        .read_addr2(rs2),
        .write_addr(mem_wb_rd),
        .write_data(write_back_data),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );
    
    assign load_use_hazard = (id_ex_mem_read && 
                              ((id_ex_rd == rs1) || (id_ex_rd == rs2)) &&
                              (id_ex_rd != 5'd0));
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            id_ex_pc <= 32'd0;
            id_ex_pc_plus_4 <= 32'd0;
            id_ex_imm <= 32'd0;
            id_ex_reg_data1 <= 32'd0;
            id_ex_reg_data2 <= 32'd0;
            id_ex_rs1 <= 5'd0;
            id_ex_rs2 <= 5'd0;
            id_ex_rd <= 5'd0;
            id_ex_funct3 <= 3'd0;
            id_ex_funct7 <= 7'd0;
            id_ex_reg_write_enable <= 1'b0;
            id_ex_mem_to_reg <= 1'b0;
            id_ex_mem_read <= 1'b0;
            id_ex_mem_write <= 1'b0;
            id_ex_branch <= 1'b0;
            id_ex_jump <= 1'b0;
            id_ex_alu_op <= 2'b00;
            id_ex_alu_src <= 1'b0;
        end else if (load_use_hazard) begin
            id_ex_pc <= 32'd0;
            id_ex_pc_plus_4 <= 32'd0;
            id_ex_imm <= 32'd0;
            id_ex_reg_data1 <= 32'd0;
            id_ex_reg_data2 <= 32'd0;
            id_ex_rs1 <= 5'd0;
            id_ex_rs2 <= 5'd0;
            id_ex_rd <= 5'd0;
            id_ex_funct3 <= 3'd0;
            id_ex_funct7 <= 7'd0;
            id_ex_reg_write_enable <= 1'b0;
            id_ex_mem_to_reg <= 1'b0;
            id_ex_mem_read <= 1'b0;
            id_ex_mem_write <= 1'b0;
            id_ex_branch <= 1'b0;
            id_ex_jump <= 1'b0;
            id_ex_alu_op <= 2'b00;
            id_ex_alu_src <= 1'b0;
        end else begin
            id_ex_pc <= if_id_pc;
            id_ex_pc_plus_4 <= if_id_pc_plus_4;
            id_ex_imm <= immediate_value;
            id_ex_reg_data1 <= reg_data1;
            id_ex_reg_data2 <= reg_data2;
            id_ex_rs1 <= rs1;
            id_ex_rs2 <= rs2;
            id_ex_rd <= rd;
            id_ex_funct3 <= funct3;
            id_ex_funct7 <= funct7;
            id_ex_reg_write_enable <= reg_write_enable;
            id_ex_mem_to_reg <= mem_to_reg;
            id_ex_mem_read <= mem_read;
            id_ex_mem_write <= mem_write;
            id_ex_branch <= branch;
            id_ex_jump <= jump;
            id_ex_alu_op <= alu_op;
            id_ex_alu_src <= alu_src;
        end
    end
    
    wire [31:0] forwarded_reg_data1, forwarded_reg_data2;
    
    assign forwarded_reg_data1 = (ex_mem_reg_write_enable && ex_mem_rd == id_ex_rs1 && ex_mem_rd != 5'd0) ?
                                 ex_mem_alu_result :
                                 (mem_wb_reg_write_enable && mem_wb_rd == id_ex_rs1 && mem_wb_rd != 5'd0) ?
                                 write_back_data : id_ex_reg_data1;
    
    assign forwarded_reg_data2 = (ex_mem_reg_write_enable && ex_mem_rd == id_ex_rs2 && ex_mem_rd != 5'd0) ?
                                 ex_mem_alu_result :
                                 (mem_wb_reg_write_enable && mem_wb_rd == id_ex_rs2 && mem_wb_rd != 5'd0) ?
                                 write_back_data : id_ex_reg_data2;
    
    assign alu_operand_a = (id_ex_jump && id_ex_rd == 5'd1) ? id_ex_pc_plus_4 :
                          forwarded_reg_data1;
    
    assign alu_operand_b = id_ex_alu_src ? id_ex_imm : forwarded_reg_data2;
    
    alu_control alu_ctrl(
        .alu_op(id_ex_alu_op),
        .funct3(id_ex_funct3),
        .funct7(id_ex_funct7),
        .alu_control(alu_control_signal)
    );
    
    alu alu_unit(
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .alu_control(alu_control_signal),
        .result(alu_result),
        .zero_flag(alu_zero),
        .less_than_flag(alu_less_than)
    );
    
    branch_control branch_ctrl(
        .funct3(id_ex_funct3),
        .zero_flag(alu_zero),
        .less_than_flag(alu_less_than),
        .branch_taken(branch_taken)
    );
    
    assign branch_target = id_ex_pc + id_ex_imm;
    assign jump_target = (id_ex_funct3 == 3'b000) ?
                         (forwarded_reg_data1 + id_ex_imm) & 32'hFFFFFFFE :
                         id_ex_pc + id_ex_imm;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_mem_pc_plus_4 <= 32'd0;
            ex_mem_alu_result <= 32'd0;
            ex_mem_reg_data2 <= 32'd0;
            ex_mem_rd <= 5'd0;
            ex_mem_funct3 <= 3'd0;
            ex_mem_reg_write_enable <= 1'b0;
            ex_mem_mem_to_reg <= 1'b0;
            ex_mem_mem_read <= 1'b0;
            ex_mem_mem_write <= 1'b0;
            ex_mem_branch <= 1'b0;
            ex_mem_jump <= 1'b0;
            ex_mem_branch_taken <= 1'b0;
            ex_mem_branch_target <= 32'd0;
        end else begin
            ex_mem_pc_plus_4 <= id_ex_pc_plus_4;
            ex_mem_alu_result <= alu_result;
            ex_mem_reg_data2 <= forwarded_reg_data2;
            ex_mem_rd <= id_ex_rd;
            ex_mem_funct3 <= id_ex_funct3;
            ex_mem_reg_write_enable <= id_ex_reg_write_enable;
            ex_mem_mem_to_reg <= id_ex_mem_to_reg;
            ex_mem_mem_read <= id_ex_mem_read;
            ex_mem_mem_write <= id_ex_mem_write;
            ex_mem_branch <= id_ex_branch;
            ex_mem_jump <= id_ex_jump;
            ex_mem_branch_taken <= id_ex_branch && branch_taken;
            ex_mem_branch_target <= branch_target;
        end
    end
    
    data_memory dmem(
        .clk(clk),
        .reset(reset),
        .mem_read(ex_mem_mem_read),
        .mem_write(ex_mem_mem_write),
        .address(ex_mem_alu_result),
        .write_data(ex_mem_reg_data2),
        .funct3(ex_mem_funct3),
        .read_data(mem_read_data)
    );
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_wb_alu_result <= 32'd0;
            mem_wb_mem_read_data <= 32'd0;
            mem_wb_rd <= 5'd0;
            mem_wb_reg_write_enable <= 1'b0;
            mem_wb_mem_to_reg <= 1'b0;
        end else begin
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_mem_read_data <= mem_read_data;
            mem_wb_rd <= ex_mem_rd;
            mem_wb_reg_write_enable <= ex_mem_reg_write_enable;
            mem_wb_mem_to_reg <= ex_mem_mem_to_reg;
        end
    end
    
    assign write_back_data = mem_wb_mem_to_reg ? mem_wb_mem_read_data : mem_wb_alu_result;
    
    assign pc_out = pc;
    assign instruction_out = if_id_instruction;
    assign alu_result_out = ex_mem_alu_result;
    assign reg_data1_out = reg_data1;
    assign reg_data2_out = reg_data2;

endmodule
