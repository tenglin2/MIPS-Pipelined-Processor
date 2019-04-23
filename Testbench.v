`timescale 1ns / 1ps

module Testbench;
    // The only inputs we give are clock and reset signals.
    reg clock;
    reg reset;
    
    wire [31:0] instruction;
    wire [31:0] counter;
    
    // Outputs at decode_execute register.
    wire e_register_write;
    wire e_memory_to_register;
    wire e_memory_write;
    wire [3:0] e_alu_control;
    wire e_alu_immediate;
    wire [4:0] e_register_destination;
    wire [31:0] e_rs_data;
    wire [31:0] e_rt_data;
    wire [31:0] e_immediate;
    
    // Outputs at execute_memory register.
    wire m_register_write;
    wire m_memory_to_register;
    wire m_memory_write;
    wire [4:0] m_register_destination;
    wire [31:0] m_result;
    wire [31:0] m_rt_data;
    
    // Outputs at memory_writeback register.
    wire w_register_write;
    wire w_memory_to_register;
    wire [4:0] w_register_destination;
    wire [31:0] w_result_address;
    wire [31:0] w_result_data;
    
    
    // Instantiating the Processor module which is basically the module that contains
    // all the other modules.
    Processor Processor(
        .clock(clock),
        .reset(reset),
        .instruction(instruction),
        .counter(counter),
        
        .e_register_write(e_register_write),
        .e_memory_to_register(e_memory_to_register),
        .e_memory_write(e_memory_write),
        .e_alu_control(e_alu_control),
        .e_alu_immediate(e_alu_immediate),
        .e_register_destination(e_register_destination),
        .e_rs_data(e_rs_data),
        .e_rt_data(e_rt_data),
        .e_immediate(e_immediate),
        
        .m_register_write(m_register_write),
        .m_memory_to_register(m_memory_to_register),
        .m_memory_write(m_memory_write),
        .m_register_destination(m_register_destination),
        .m_result(m_result),
        .m_rt_data(m_rt_data),
        
        .w_register_write(w_register_write),
        .w_memory_to_register(w_memory_to_register),
        .w_register_destination(w_register_destination),
        .w_result_address(w_result_address),
        .w_result_data(w_result_data)
    );
    
    // We initialize the clock and reset inputs and set a sample total clock time of
    // 50 nano seconds, which is more than enough to show everything.
    initial begin
        clock = 0;
        reset = 1;       
        #2 reset = 0;
        
        #48 $finish;
    end
    
    always begin
        #1 clock = ~clock; // The clock alternates every nano second.
    end
endmodule
