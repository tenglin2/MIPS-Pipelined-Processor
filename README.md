# MIPS-Pipelined-Processor


### Overview
This is a repository of a MIPS pipelined processor coded in Verilog HDL. It's basically a showcase of an elementary processor unit that can handle a few basic instructions.

This project was very useful for learning how the processor actually works in a CPU. There are a myriad of different components that work together in specific stages to make sure everything flows together.

A pipelined processor is special because it allows multiple instructions to be performed on a single clock cycle. For instance, on a single clock cycle the processor could be performing parts of 5 instructions at once. This drastically improves the throughput and runtime of processing an instruction set. 

### Stages
- Fetch
- Decode
- Execute
- Memory
- Writeback

### Modules
- Processor (Top Level --> Combines Everything)
- program_counter
- adder
- instruction_memory
- fetch_decode
- control_unit
- destination
- regfile
- sign_extender
- decode_execute
- second_source_alu
- alu
- execute_memory
- data_memory
- memory_to_register_multiplexer

### Final Notes
This is more of a proof of concept than anything else. I wanted to learned how the processor works so I did this little project. Processors these days are exceptionally more complicated than my implementation.

My processor uses a 32 bit instruction set architecture. I have a testbench which tests the hardcoded MIPS instructions. I also have a schematic and waveform to show that pipelining is actually working as expected.