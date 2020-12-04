module tb_harvard;

    parameter RAM_FILE =  /*default test case if not specified*/;
    parameter TIMEOUT_CYCLES = /*default value*/;

    timeunit 1ns / 10ps;

    logic clk;
    logic reset;
    logic active;
    logic [31:0] register_v0;

    logic clk_enable; //Needs investigating further - logic to drive signal?

    logic[31:0] instr_address;
    logic[31:0] instr_readdata;

    logic[31:0] data_address;
    logic data_write;
    logic data_read;
    logic[31:0] data_writedata;
    logic[31:0] data_readdata;

    /*INSTR RAM NAME*/ #(RAM_FILE) instRAMInst(/*connect wires*/);
    /*DATA RAM NAME*/ dataRAMInst(/*connect wires*/);

    /*MIPS CPU NAME*/ cpuInst(clk, reset, active, register_v0, clk_enable, instr_address, instr_readdata, data_address, data_write, data_read, 				      data_writedata, data_readdata);

    //Setting up a clock
    initial begin
	clk = 0;

	repeat (TIMEOUT_CYCLES) begin
	    #10;
	    clk = !clk;
	    #10;
	    clk = !clk;
	end

	$fatal(1, "Simulation didn't finish within %d cycles.", TIMEOUT_CYCLES);

    end

    initial begin
	//Resetting the CPU
	reset <= 0;

	@(posedge clk);
	reset <= 1;

	@(posedge clk);
	reset <= 0;

	@(posedge clk);
	//Checking reset was successful
	assert(active==1) else $display("Testbench: CPU didn't set active high after reset");

	//Looping until the CPU finished (sets active low) 
	while(active) begin
	    @(posedge clk);
	end

	$display("Testbench: Finished. Active = 0");
	$display("Final value of register v0 = %d", register_v0);

	$finish;

    end

endmodule

		
	
	


