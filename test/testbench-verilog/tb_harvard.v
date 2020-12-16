timeunit 1ns / 10ps;

module tb_harvard;

  parameter INSTR_INIT_FILE = ""  /*default test case if not specified*/;
  parameter DATA_INIT_FILE = ""  /*default data if not specified*/;
  parameter TIMEOUT_CYCLES = 15;

  logic clk;
  logic reset;
  logic active;
  logic pcsrc, pcsrclast;
  logic [31:0] register_v0;
  logic [31:0] register_v3;
  integer cycle_count = 0;
  integer STDERR = 32'h8000_0002;

  logic clk_enable;  //Needs investigating further - logic to drive signal?

  logic [31:0] instr_address;
  logic [31:0] instr_readdata;

  logic [31:0] data_address;
  logic data_write;
  logic data_read;
  logic [31:0] data_writedata;
  logic [31:0] data_readdata;

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
      .pcsrc(pcsrc),
      .pcsrclast(pcsrclast),
      .register_v0(register_v0),
      .register_v3(register_v3),
      .clk_enable(clk_enable),
      .instr_address(instr_address),
      .instr_readdata(instr_readdata),
      .data_address(data_address),
      .data_write(data_write),
      .data_read(data_read),
      .data_writedata(data_writedata),
      .data_readdata(data_readdata)
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

    //Looping until the CPU finished (sets active low)
    while (active) begin
      @(posedge clk);
      cycle_count++;
//      $fdisplay(STDERR, "  ");
/*     $fdisplay(STDERR, "Cycle Count: %d, register_v0: %d, register_v3: %d, active: %d", cycle_count, register_v0, register_v3, active);
      $fdisplay(STDERR, "Instruction address: %h, Instruction: %b, Data output: %h", instr_address, instr_readdata, data_readdata);
      //$fdisplay(STDERR, "Data address: %h, Data: %b", data_address, data_readdata); */
    end

    $display("%d", register_v0);

    $finish;

  end

endmodule
