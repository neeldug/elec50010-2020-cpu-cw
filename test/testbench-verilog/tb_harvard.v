timeunit 1ns / 10ps;

module tb_harvard;

  parameter INSTR_INIT_FILE = ""  /*default test case if not specified*/;
  parameter DATA_INIT_FILE = ""  /*default data if not specified*/;
  parameter TIMEOUT_CYCLES = 15;

  logic clk;
  logic reset;
  logic active;
  logic [31:0] register_v0;
  integer cycle_count = 0;
  integer STDERR = 32'h8000_0002;

  logic clk_enable;

  logic [31:0] instr_address;
  logic [31:0] instr_readdata;

  logic [31:0] data_address;
  logic data_write;
  logic data_read;
  logic [31:0] data_writedata;
  logic [31:0] data_readdata;

// 	logic [31:0] alu1, alu2;					//debug
//	logic [31:0] instr_schedule;				//debug
//  	logic [31:0] rdb;							//debug




  instruction_mem #(INSTR_INIT_FILE) instRAMInst (
      .instr_address(instr_address),
      .instr(instr_readdata)
  );
  data_mem #(DATA_INIT_FILE) dataRAMInst (
      .clk(clk),
      .data_address(data_address),
      .data_writedata(data_writedata),
      .data_write(data_write),
      .data_readdata(data_readdata)
  );

  mips_cpu_harvard cpuInst (
      .clk(clk),
      .reset(reset),
      .active(active),
      .register_v0(register_v0),
      .clk_enable(clk_enable),
      .instr_address(instr_address),
      .instr_readdata(instr_readdata),
      .data_address(data_address),
      .data_write(data_write),
      .data_read(data_read),
      .data_writedata(data_writedata),
      .data_readdata(data_readdata)

//      .alu1(alu1),								//debug
//      .alu2(alu2),								//debug
//     .instr_schedule(instr_schedule),			//debug
//     .rdb(rdb)					    		//debug
  );

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
    while (active) begin
      assert (data_read != 1 && data_write != 1)
      else begin
        $fatal(1, "Tried to read and write data simultaneously");
      end
    end
  end

  initial begin
    //Resetting the CPU
    reset <= 0;
    clk_enable <= 0;

    @(posedge clk);
    reset <= 1;

    @(posedge clk);
    reset <= 0;
    clk_enable <= 1;



    @(posedge clk);
    //Checking reset was successful
    assert (active == 1)
    else $display("Testbench: CPU didn't set active high after reset");

    //Setting clk_enable high (may need to happen earlier - we shall see)


    //Debugging logs for cycle 0
/*    	  $fdisplay(STDERR, "  ");
      $fdisplay(STDERR, "Cycle Count: %d, register_v0: %d, active: %d", cycle_count, register_v0, active);
      $fdisplay(STDERR, "Instruction address: %h, Instruction: %b", instr_address, instr_readdata);
      $fdisplay(STDERR, "ALUa: %h, ALUb: %h, ALUresult: %h", alu1, alu2, data_address);
      $fdisplay(STDERR, "Instruction out of scheduler: %b, rdb: %h", instr_schedule, rdb);
      // */


    //Looping until the CPU finished (sets active low)
    while (active) begin
      @(posedge clk);
      cycle_count++;

      //Debugging logs for cycles 1+
/*      	  $fdisplay(STDERR, "  ");
      $fdisplay(STDERR, "Cycle Count: %d, register_v0: %h, active: %d", cycle_count, register_v0, active);
      $fdisplay(STDERR, "Instruction address: %h, Instruction: %b", instr_address, instr_readdata);
      $fdisplay(STDERR, "ALUa: %h, ALUb: %h, ALUresult: %h", alu1, alu2, data_address);
      $fdisplay(STDERR, "Instruction out of scheduler: %b, rdb: %h", instr_schedule, rdb);
      // */

    end

    $display("%d", register_v0);

    $finish;

  end

endmodule
