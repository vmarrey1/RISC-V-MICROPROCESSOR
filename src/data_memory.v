`timescale 1ns / 1ps

module data_memory(
    input clk,
    input reset,
    input mem_read,
    input mem_write,
    input [31:0] address,
    input [31:0] write_data,
    input [2:0] funct3,
    output reg [31:0] read_data
);

    reg [31:0] memory [0:1023];
    integer i;
    wire [31:0] word_address;
    wire [31:0] aligned_address;
    
    assign word_address = address >> 2;
    assign aligned_address = (word_address < 1024) ? word_address : 10'd0;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 1024; i = i + 1) begin
                memory[i] <= 32'd0;
            end
        end else if (mem_write && aligned_address < 1024) begin
            case (funct3)
                3'b000: begin
                    case (address[1:0])
                        2'b00: memory[aligned_address][7:0] <= write_data[7:0];
                        2'b01: memory[aligned_address][15:8] <= write_data[7:0];
                        2'b10: memory[aligned_address][23:16] <= write_data[7:0];
                        2'b11: memory[aligned_address][31:24] <= write_data[7:0];
                    endcase
                end
                3'b001: begin
                    if (address[1] == 1'b0) begin
                        memory[aligned_address][15:0] <= write_data[15:0];
                    end else begin
                        memory[aligned_address][31:16] <= write_data[15:0];
                    end
                end
                3'b010: begin
                    memory[aligned_address] <= write_data;
                end
                default: memory[aligned_address] <= write_data;
            endcase
        end
    end
    
    always @(*) begin
        if (mem_read && aligned_address < 1024) begin
            case (funct3)
                3'b000: begin
                    case (address[1:0])
                        2'b00: read_data = {{24{memory[aligned_address][7]}}, memory[aligned_address][7:0]};
                        2'b01: read_data = {{24{memory[aligned_address][15]}}, memory[aligned_address][15:8]};
                        2'b10: read_data = {{24{memory[aligned_address][23]}}, memory[aligned_address][23:16]};
                        2'b11: read_data = {{24{memory[aligned_address][31]}}, memory[aligned_address][31:24]};
                    endcase
                end
                3'b001: begin
                    if (address[1] == 1'b0) begin
                        read_data = {{16{memory[aligned_address][15]}}, memory[aligned_address][15:0]};
                    end else begin
                        read_data = {{16{memory[aligned_address][31]}}, memory[aligned_address][31:16]};
                    end
                end
                3'b010: begin
                    read_data = memory[aligned_address];
                end
                3'b100: begin
                    case (address[1:0])
                        2'b00: read_data = {24'b0, memory[aligned_address][7:0]};
                        2'b01: read_data = {24'b0, memory[aligned_address][15:8]};
                        2'b10: read_data = {24'b0, memory[aligned_address][23:16]};
                        2'b11: read_data = {24'b0, memory[aligned_address][31:24]};
                    endcase
                end
                3'b101: begin
                    if (address[1] == 1'b0) begin
                        read_data = {16'b0, memory[aligned_address][15:0]};
                    end else begin
                        read_data = {16'b0, memory[aligned_address][31:16]};
                    end
                end
                default: read_data = memory[aligned_address];
            endcase
        end else begin
            read_data = 32'd0;
        end
    end

endmodule
