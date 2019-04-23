// Top level module that wires all the other modules together.
module Processor(clock, reset, instruction, counter, 
    e_register_write, e_memory_to_register, e_memory_write, e_alu_control, e_alu_immediate, e_register_destination, e_rs_data, e_rt_data, e_immediate,
    m_register_write, m_memory_to_register, m_memory_write, m_register_destination, m_result, m_rt_data,
    w_register_write, w_memory_to_register, w_register_destination, w_result_address, w_result_data);

    input clock;
    input reset;
    output [31:0] instruction;
    output [31:0] counter;
    
    output e_register_write;
    output e_memory_to_register;
    output e_memory_write;
    output [3:0] e_alu_control;
    output e_alu_immediate;
    output [4:0] e_register_destination;
    output [31:0] e_rs_data;
    output [31:0] e_rt_data;
    output [31:0] e_immediate;
   
    output m_register_write;
    output m_memory_to_register;
    output m_memory_write;
    output [4:0] m_register_destination;
    output [31:0] m_result;
    output [31:0] m_rt_data;    
    
    output w_register_write;
    output w_memory_to_register;
    output [4:0] w_register_destination;
    output [31:0] w_result_address;
    output [31:0] w_result_data;
    
    // Wires for the fetch stage.
    wire [31:0] adder_to_program_counter;
    wire [31:0] program_counter_out; // Needs to be split up into two wires.
    wire [31:0] program_counter_to_adder;
    wire [31:0] program_counter_to_instruction_memory;
    wire [31:0] instruction_memory_to_fetch_decode;
    wire [31:0] instruction_out;
    
    // Wires for the decode stage.
    wire register_write_to_decode_execute;
    wire memory_to_register_to_decode_execute;
    wire memory_write_to_decode_execute;
    wire [3:0] alu_control_to_decode_execute;
    wire alu_immediate_to_decode_execute;
    wire register_destination_selector_to_destination;  
    wire [4:0] destination_to_decode_execute;
    wire register_write_memory_writeback_to_regfile; // FAR
    wire [4:0] register_destination_memory_writeback_to_regfile;
    wire [31:0] register_data_to_regfile; // FAR
    wire [31:0] rs_data_regfile_to_decode_execute;
    wire [31:0] rt_data_regfile_to_decode_execute;   
    wire [31:0] immediate_to_decode_execute;
    
    // Wires for the execute stage.
    wire register_write_decode_execute_to_execute_memory;
    wire memory_to_register_decode_execute_to_execute_memory;
    wire memory_write_decode_execute_to_execute_memory;
    wire [3:0] alu_control_decode_execute_to_alu;
    wire alu_immediate_decode_execute_to_second_source_alu;
    wire [4:0] register_destination_decode_execute_to_execute_memory;
    wire [31:0] rs_data_decode_execute_to_alu;
    wire [31:0] immediate_decode_execute_to_second_source_alu;  
    wire [31:0] second_source_second_source_alu_to_alu; 
    wire [31:0] result_alu_to_execute_memory;   
    wire [31:0] rt_data_decode_execute_to_execute_memory;  
    wire [31:0] rt_data_decode_execute_to_second_source_alu;
    wire [31:0] rt_data_decode_execute_out; // Wire needs to be split.
    wire [31:0] result_execute_memory_out; // Wire needs  to be split.     
    
    // Wires for the memory stage.
    wire [31:0] result_address_execute_memory_to_memory_writeback; 
    wire [31:0] result_address_execute_memory_to_data_memory;
    wire register_write_execute_memory_to_memory_writeback;
    wire memory_to_register_execute_memory_to_memory_writeback;
    wire memory_write_execute_memory_to_data_memory;
    wire [4:0] register_destination_execute_memory_to_memory_writeback;
    wire [31:0] rt_data_execute_memory_to_data_memory;   
    wire [31:0] result_data_data_memory_to_memory_writeback;
    
    // Wire for the writeback stage.
    wire memory_to_register_memory_writeback_to_memory_to_register_multiplexer;
    wire [31:0] result_address_memory_writeback_to_memory_to_register_multiplexer;
    wire [31:0] result_data_memory_writeback_to_memory_to_register_multiplexer;
    
    
    // I organized it in such a way that all the outputs are given values through
    // the assignments to existing wires.
    assign program_counter_to_adder = program_counter_out;
    assign program_counter_to_instruction_memory = program_counter_out;
    assign instruction = instruction_out; 
    assign counter = program_counter_out;
    
    assign e_register_write = register_write_decode_execute_to_execute_memory;
    assign e_memory_to_register = memory_to_register_decode_execute_to_execute_memory;
    assign e_memory_write = memory_write_decode_execute_to_execute_memory;
    assign e_alu_control = alu_control_decode_execute_to_alu;
    assign e_alu_immediate = alu_immediate_decode_execute_to_second_source_alu;
    assign e_register_destination = register_destination_decode_execute_to_execute_memory;
    assign e_rs_data = rs_data_decode_execute_to_alu;
    assign e_rt_data = rt_data_decode_execute_to_second_source_alu;
    assign e_immediate = immediate_decode_execute_to_second_source_alu;
    
    // Splitting wires.
    assign result_address_execute_memory_to_memory_writeback = result_execute_memory_out;
    assign result_address_execute_memory_to_data_memory = result_execute_memory_out;
     
    assign m_register_write = register_write_execute_memory_to_memory_writeback;
    assign m_memory_to_register = memory_to_register_execute_memory_to_memory_writeback;
    assign m_memory_write = memory_write_execute_memory_to_data_memory;
    assign m_register_destination = register_destination_execute_memory_to_memory_writeback;
    assign m_result = result_execute_memory_out; 
    assign m_rt_data = rt_data_execute_memory_to_data_memory;
    
    // More splitting.
    assign rt_data_decode_execute_to_second_source_alu = rt_data_decode_execute_out;
    assign rt_data_decode_execute_to_execute_memory = rt_data_decode_execute_out;
    
    assign w_register_write = register_write_memory_writeback_to_regfile;
    assign w_memory_to_register = memory_to_register_memory_writeback_to_memory_to_register_multiplexer;
    assign w_register_destination = register_destination_memory_writeback_to_regfile;
    assign w_result_address = result_address_memory_writeback_to_memory_to_register_multiplexer;
    assign w_result_data = result_data_memory_writeback_to_memory_to_register_multiplexer;
    
    // Instantiating modules.
    program_counter program_counter(
        .clock(clock),
        .reset(reset),
        .in_pc(adder_to_program_counter),
        .out_pc(program_counter_out)
    );
    
    adder adder(
        .old_counter(program_counter_to_adder),
        .new_counter(adder_to_program_counter)
    );
    
    instruction_memory instruction_memory(
        .pc_address(program_counter_to_instruction_memory),
        .instruction(instruction_memory_to_fetch_decode)
    );
    
    fetch_decode fetch_decode(
        .clock(clock),
        .reset(reset),
        .in_instruct(instruction_memory_to_fetch_decode),
        .out_instruct(instruction_out)
    );
    
    control_unit control_unit(
        .op_code(instruction_out[31:26]),
        .function_code(instruction_out[5:0]),
        .register_write(register_write_to_decode_execute),
        .memory_to_register(memory_to_register_to_decode_execute),
        .memory_write(memory_write_to_decode_execute),
        .alu_control(alu_control_to_decode_execute),
        .alu_immediate(alu_immediate_to_decode_execute),
        .register_destination(register_destination_selector_to_destination)
    );
    
    destination destination(
        .destination_selector(register_destination_selector_to_destination),
        .rt(instruction_out[25:21]), 
        .rd(instruction_out[20:16]), 
        .register_destination(destination_to_decode_execute)
    );
    
    regfile regfile(
        .clock(clock), 
        .write_enable(register_write_memory_writeback_to_regfile), 
        .write_address(register_destination_memory_writeback_to_regfile), 
        .write_data(register_data_to_regfile), 
        .rs_address(instruction_out[26:21]), 
        .rt_address(instruction_out[20:16]), 
        .rs_data(rs_data_regfile_to_decode_execute), 
        .rt_data(rt_data_regfile_to_decode_execute)
    );
        
    sign_extender sign_extender(
        .instruction(instruction_out[15:0]),
        .immediate(immediate_to_decode_execute)
    );
    
    decode_execute decode_execute(
        .clock(clock), 
        .register_write(register_write_to_decode_execute), 
        .memory_to_register(memory_to_register_to_decode_execute), 
        .memory_write(memory_write_to_decode_execute), 
        .alu_control(alu_control_to_decode_execute), 
        .alu_immediate(alu_immediate_to_decode_execute), 
        .register_destination(destination_to_decode_execute), 
        .rs_data(rs_data_regfile_to_decode_execute), 
        .rt_data(rt_data_regfile_to_decode_execute), 
        .immediate(immediate_to_decode_execute),
        .e_register_write(register_write_decode_execute_to_execute_memory), 
        .e_memory_to_register(memory_to_register_decode_execute_to_execute_memory), 
        .e_memory_write(memory_write_decode_execute_to_execute_memory), 
        .e_alu_control(alu_control_decode_execute_to_alu), 
        .e_alu_immediate(alu_immediate_decode_execute_to_second_source_alu), 
        .e_register_destination(register_destination_decode_execute_to_execute_memory), 
        .e_rs_data(rs_data_decode_execute_to_alu), 
        .e_rt_data(rt_data_decode_execute_out), 
        .e_immediate(immediate_decode_execute_to_second_source_alu)
    );
        
    second_source_alu second_source_alu(
        .alu_immediate_selector(alu_immediate_decode_execute_to_second_source_alu), 
        .rt_data(rt_data_decode_execute_to_second_source_alu), 
        .immediate(immediate_decode_execute_to_second_source_alu), 
        .second_source(second_source_second_source_alu_to_alu)
    );
    
    alu alu(
        .alu_control(alu_control_decode_execute_to_alu), 
        .first_source(rs_data_decode_execute_to_alu), 
        .second_source(second_source_second_source_alu_to_alu), 
        .result(result_alu_to_execute_memory)
    );
    
    execute_memory execute_memory(
        .clock(clock), 
        .e_register_write(register_write_decode_execute_to_execute_memory), 
        .e_memory_to_register(memory_to_register_decode_execute_to_execute_memory), 
        .e_memory_write(memory_write_decode_execute_to_execute_memory), 
        .e_register_destination(register_destination_decode_execute_to_execute_memory), 
        .e_result(result_alu_to_execute_memory), 
        .e_rt_data(rt_data_decode_execute_to_execute_memory),
        
        .m_register_write(register_write_execute_memory_to_memory_writeback), 
        .m_memory_to_register(memory_to_register_execute_memory_to_memory_writeback), 
        .m_memory_write(memory_write_execute_memory_to_data_memory), 
        .m_register_destination(register_destination_execute_memory_to_memory_writeback), 
        .m_result(result_execute_memory_out), 
        .m_rt_data(rt_data_execute_memory_to_data_memory)
    );
    
    data_memory data_memory(
        .write_enable(memory_write_execute_memory_to_data_memory), 
        .write_data(rt_data_execute_memory_to_data_memory), 
        .result_address(result_address_execute_memory_to_data_memory), 
        .result_data(result_data_data_memory_to_memory_writeback)       
    );
    
    memory_writeback memory_writeback(
        .clock(clock), 
        .m_register_write(register_write_execute_memory_to_memory_writeback), 
        .m_memory_to_register(memory_to_register_execute_memory_to_memory_writeback), 
        .m_register_destination(register_destination_execute_memory_to_memory_writeback), 
        .m_result_address(result_address_execute_memory_to_memory_writeback), 
        .m_result_data(result_data_data_memory_to_memory_writeback),
        .w_register_write(register_write_memory_writeback_to_regfile), 
        .w_memory_to_register(memory_to_register_memory_writeback_to_memory_to_register_multiplexer), 
        .w_register_destination(register_destination_memory_writeback_to_regfile), 
        .w_result_address(result_address_memory_writeback_to_memory_to_register_multiplexer), 
        .w_result_data(result_data_memory_writeback_to_memory_to_register_multiplexer)
    );
    
    memory_to_register_multiplexer memory_to_register_multiplexer(
        .memory_to_register_selector(memory_to_register_memory_writeback_to_memory_to_register_multiplexer), 
        .result_address(result_address_memory_writeback_to_memory_to_register_multiplexer), 
        .result_data(result_data_memory_writeback_to_memory_to_register_multiplexer), 
        .writeback_data(register_data_to_regfile)
    );
    
endmodule


// program_counter module is a register that acts like a DFF that is triggered by
// the positive edge of the clock. This is a common pattern of the future registers
// for pipelining --> their logic resembles a DFF.
module program_counter(clock, reset, in_pc, out_pc);
    input clock;
    input reset;
    input [31:0] in_pc;
    output reg [31:0] out_pc;    
    
    initial begin
        out_pc <= 100;
    end
    
    always @(posedge clock) begin
        if(reset) out_pc <= 100;
        else out_pc <= in_pc;
    end
endmodule

// Adder simply increments the pc address by 4, so that we can move onto the
// next instruction.
module adder(old_counter, new_counter);
    input [31:0] old_counter;
    output reg [31:0] new_counter;
    
    always @(old_counter) begin
        new_counter <= old_counter + 4;
    end
endmodule

// instruction_memory module takes the given pc address and gives a 32 bit
// instructions from that address. These are hardcoded to show that it works.
// We represent this structure by making a reg called instruct_memory that stores
// these 32 bit addresses so that they can be accessed and manipulated.
module instruction_memory(pc_address, instruction);
    input [31:0] pc_address;
    output reg [31:0] instruction;
    reg [31:0] instruct_memory [0:511];

    initial begin
        instruct_memory[100] = 32'b100011_00001_00010_0000000000000000;
        instruct_memory[104] = 32'b100011_00001_00011_0000000000000100;
        instruct_memory[108] = 32'b100011_00001_00100_0000000000001000;
        instruct_memory[112] = 32'b100011_00001_00101_0000000000001100;
        instruct_memory[116] = 32'b000000_00010_01010_00110_00000_100000;
    end
    
    always @(pc_address) begin
        instruction <= instruct_memory[pc_address];
    end
endmodule

// fetch_decode pipeline register outputs only the 32 bit instruction.
module fetch_decode(clock, reset, in_instruct, out_instruct);
    input clock;
    input reset;
    input [31:0] in_instruct;
    output reg [31:0] out_instruct;

    always @(posedge clock) begin
        if(reset) out_instruct <= 0;
        else out_instruct <= in_instruct;
    end
endmodule

// sign_extender is used to make the 16 bit immediate field into 32 bits for
// later operations in the ALU if it gets there.
module sign_extender(instruction, immediate);
    input [31:0] instruction;
    output reg [31:0] immediate;
    
    always @(instruction) begin
        immediate = {{16{instruction[15]}}, instruction[15:0]};
    end
endmodule

// regfile module is similar in vein to the instruction memory. We have a structure
// called register that holds all the register values that we hardcode.
// Basically we give it two register addresses rs and rt, and we are given back the
// 32 bit data values that are actually stored in the register.
// The other aspect is writing to the register which is done at a later step.
module regfile(clock, write_enable, write_address, write_data, rs_address, rt_address, rs_data, rt_data); 
    input clock;
    input write_enable;
    input [4:0] write_address;
    input [31:0] write_data;
    input [4:0] rs_address;
    input [4:0] rt_address;
    output [31:0] rs_data; 
    output [31:0] rt_data;  
    reg [31:0] register [0:31]; 
    
    integer j;
    initial begin
        for(j = 0; j < 32; j = j + 1) register[j] = 0; // This might break.
    end
    
    integer k;
    initial begin
        for(k = 1; k < 11; k = k + 1)
            case(k)
                1: register[k] = 0;
                2: register[k] = 32'b0001_0000_0000_0000_0000_0000_0001_0001;
                3: register[k] = 32'b0010_0000_0000_0000_0000_0000_0010_0010;
                4: register[k] = 32'b0011_0000_0000_0000_0000_0000_0011_0011;
                5: register[k] = 32'b0100_0000_0000_0000_0000_0000_0100_0100;
                6: register[k] = 32'b0101_0000_0000_0000_0000_0000_0101_0101;
                7: register[k] = 32'b0110_0000_0000_0000_0000_0000_0110_0110;
                8: register[k] = 32'b0111_0000_0000_0000_0000_0000_0111_0111;
                9: register[k] = 32'b1000_0000_0000_0000_0000_0000_1000_1000;
                10: register[k] = 32'b1001_0000_0000_0000_0000_0000_1001_1001;
            endcase
    end
  
    assign rs_data = (rs_address == 0) ? 0 : register[rs_address];
    assign rt_data = (rt_address == 0) ? 0 : register[rt_address];
  
    always @(posedge clock) begin
        if(write_enable && (write_address != 0)) register[write_address] = write_data;
    end
endmodule 

// control_unit module determines the control lines. They determine how we manipulate
// the 32 bit instruction. This is done by checking the instruction type and funccode.
module control_unit(op_code, function_code, register_write, memory_to_register, memory_write, alu_control, alu_immediate, register_destination);
    input [5:0] op_code;
    input [5:0] function_code;
    output reg register_write;
    output reg memory_to_register;
    output reg memory_write;
    output reg [3:0] alu_control; 
    output reg alu_immediate; 
    output reg register_destination; 
    
    always @(op_code || function_code) begin
        case(op_code)
            6'b000000: begin // R type instruction
                case(function_code)
                    6'b100000: alu_control <= 4'b0010; // ADD
                    6'b100010: alu_control <= 4'b0110; // SUB
                    6'b100100: alu_control <= 4'b0000; // AND
                    6'b100101: alu_control <= 4'b0001; // OR
                    6'b101010: alu_control <= 4'b0111; // SLT
                    6'b100111: alu_control <= 4'b1100; // NOR
                endcase
                
                register_write <= 1;
                memory_to_register <= 0;
                memory_write <= 0;
                alu_immediate <= 0; // Uses rt for alu second source
                register_destination <= 1; // Because it uses rd for destination not rt.
            end
            6'b100011: begin // lw instruction
                register_write <= 1;
                memory_to_register <= 1;
                memory_write <= 1;
                alu_control <= 4'b0010; // lw uses add alu function
                alu_immediate <= 1; // Uses immediate shift for alu second source.
                register_destination <= 0; // Uses rt as destination register.
            end
            6'b101011: begin // sw instruction
                register_write <= 0;
                memory_to_register <= 1'bx; // So this is a don't care instance
                memory_write <= 1;
                alu_control <= 4'b0010; // sw uses add
                alu_immediate <= 1; // same as alu_src
                register_destination <= 0; // rt destination
            end      
        endcase
    end   
endmodule

// destination is a multiplexer module to determine whether or not the destination
// is rt or rd, which is found by the control module using the opcode.
module destination(destination_selector, rt, rd, register_destination);
    input destination_selector;
    input [4:0] rt;
    input [4:0] rd;
    output reg [4:0] register_destination;
    
    always @(destination_selector || rt || rd) begin
        if(destination_selector) register_destination <= rd;
        else register_destination <= rt;
    end
endmodule

// decode_execute pipeline is again, just a DFF that is triggered by the positive
// edge of the clock. I denote e_prefix as the output for this step.
module decode_execute(clock, register_write, memory_to_register, memory_write, alu_control, alu_immediate, register_destination, rs_data, rt_data, immediate,
    e_register_write, e_memory_to_register, e_memory_write, e_alu_control, e_alu_immediate, e_register_destination, e_rs_data, e_rt_data, e_immediate);
    
    input clock;
    
    input register_write;
    input memory_to_register;
    input memory_write;
    input [3:0] alu_control;
    input alu_immediate;
    input [4:0] register_destination;
    input [31:0] rs_data;
    input [31:0] rt_data;
    input [31:0] immediate;
    output reg e_register_write;
    output reg e_memory_to_register;
    output reg e_memory_write;
    output reg [3:0] e_alu_control;
    output reg e_alu_immediate;
    output reg [4:0] e_register_destination;
    output reg [31:0] e_rs_data;
    output reg [31:0] e_rt_data;
    output reg [31:0] e_immediate;
    
    always @(posedge clock) begin
        e_register_write <= register_write;
        e_memory_to_register <= memory_to_register;
        e_memory_write <= memory_write;
        e_alu_control <= alu_control;
        e_alu_immediate <= alu_immediate;
        e_register_destination <= register_destination;
        e_rs_data <= rs_data;
        e_rt_data <= rt_data;
        e_immediate <= immediate;
    end
endmodule

// second_source_alu is to determine whether or not we use the value for
// rt_data or the immediate field for alu, which is determined by the control unit.
module second_source_alu(alu_immediate_selector, rt_data, immediate, second_source);
    input alu_immediate_selector;
    input [31:0] rt_data;
    input [31:0] immediate;
    output reg [31:0] second_source;
    
    always @(alu_immediate_selector || rt_data || immediate) begin
        if(alu_immediate_selector) second_source <= immediate;
        else second_source <= rt_data;
    end    
endmodule

// This part does an operation between the first and second source depending on
// what operation we need, which is found by the control unit. The output is then
// set as the result.
module alu(alu_control, first_source, second_source, result);
    input [3:0] alu_control;
    input [31:0] first_source;
    input [31:0] second_source;
    output reg [31:0] result;
    
    always @(alu_control || first_source || second_source) begin
        case(alu_control)
            4'b0000: result <= first_source & second_source;
            4'b0001: result <= first_source | second_source;
            4'b0010: result <= first_source + second_source;
            4'b0110: result <= first_source - second_source;
            4'b0111: result <= first_source < second_source ? 1 : 0;
            4'b1100: result <= first_source ^ second_source;
        endcase
    end
endmodule

// execute_memory pipeline is a DFF, same as other cases.
module execute_memory(clock, e_register_write, e_memory_to_register, e_memory_write, e_register_destination, e_result, e_rt_data,
    m_register_write, m_memory_to_register, m_memory_write, m_register_destination, m_result, m_rt_data);
    
    input clock;
    input e_register_write;
    input e_memory_to_register;
    input e_memory_write;
    input [4:0] e_register_destination;
    input [31:0] e_result;
    input [31:0] e_rt_data;
    
    output reg m_register_write;
    output reg m_memory_to_register;
    output reg m_memory_write;
    output reg [4:0] m_register_destination;
    output reg [31:0] m_result;
    output reg [31:0] m_rt_data;
    
    always @(posedge clock) begin
        m_register_write <= e_register_write;
        m_memory_to_register <= e_memory_to_register;
        m_memory_write <= e_memory_write;
        m_register_destination <= e_register_destination;
        m_result <= e_result;
        m_rt_data <= e_rt_data;
    end 
endmodule

// data_memory is similar to the regfile and instruction memory.
// The values are hardcoded and taken from a structure called data_memory which
// holds them all. 
module data_memory(write_enable, write_data, result_address, result_data);
    input write_enable;
    input [31:0] write_data; 
    input [31:0] result_address;
    output [31:0] result_data; 
    reg [31:0] data_memory [0:511];
    
    integer j;
    initial begin
        for(j = 0; j < 512; j = j + 1) data_memory[j] = 0; 
    end
    
    integer k;
    initial begin
        for(k = 0; k < 40; k = k + 4)
            case(k)
                0: data_memory[k] = 8'hA00000AA;
                4: data_memory[k] = 8'h10000011;
                8: data_memory[k] = 8'h20000022;
                12: data_memory[k] = 8'h30000033;
                16: data_memory[k] = 8'h40000044;
                20: data_memory[k] = 8'h50000055;
                24: data_memory[k] = 8'h60000066;
                28: data_memory[k] = 8'h70000077;
                32: data_memory[k] = 8'h80000088;
                36: data_memory[k] = 8'h90000099;
            endcase
    end
    
    assign result_data = data_memory[result_address];   
    always @(write_enable || write_data || result_address) begin
        if(write_enable) data_memory[result_address] = write_data;
    end
endmodule

// memory_writeback pipeline. Same case as the other pipeline registers.
module memory_writeback(clock, m_register_write, m_memory_to_register, m_register_destination, m_result_address, m_result_data,
    w_register_write, w_memory_to_register, w_register_destination, w_result_address, w_result_data);
    
    input clock;
    
    input m_register_write;
    input m_memory_to_register;
    input [4:0] m_register_destination;
    input [31:0] m_result_address;
    input [31:0] m_result_data;
    
    output reg w_register_write;
    output reg w_memory_to_register;
    output reg [4:0] w_register_destination;
    output reg [31:0] w_result_address;
    output reg [31:0] w_result_data;    
    
    
    always @(posedge clock) begin
        w_register_write <= m_register_write;
        w_memory_to_register <= m_memory_to_register;
        w_register_destination <= m_register_destination;
        w_result_address <= m_result_address;
        w_result_data <= m_result_address;
    end 
endmodule

// This module is used to determine what data is going to be written back into the
// regfile. The selector for this multiplexer is originally from the control unit, 
// but is passed on through the pipelines.
module memory_to_register_multiplexer(memory_to_register_selector, result_address, result_data, writeback_data);
    input memory_to_register_selector;
    input [31:0] result_address;
    input [31:0] result_data;
    output reg [31:0] writeback_data; 
    
    always @(memory_to_register_selector || result_address || result_data) begin
        if(memory_to_register_selector) writeback_data <= result_data;
        else writeback_data <= result_address;
    end
endmodule


