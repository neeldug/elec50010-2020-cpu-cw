timeunit 1ns / 10ps;

module tb_bus;

  parameter INSTR_INIT_FILE = ""  /*default test case if not specified*/;
  parameter DATA_INIT_FILE = ""  /*default data if not specified*/;
  parameter TIMEOUT_CYCLES = 30;

  logic clk;
  logic reset;
  logic active;
  logic [31:0] register_v0;
  logic [31:0] register_v3;
  integer cycle_count = 0;
  integer STDERR = 32'h8000_0002;

  logic [31:0] address;
  logic write;
  logic read;
  logic waitrequest;
  logic [31:0] writedata;
  logic [3:0] byteenable;
  logic [31:0] readdata;

  mips_cpu_bus cpuInst (
      .clk(clk),
      .reset(reset),
      .active(active),
      .register_v0(register_v0),
      .register_v3(register_v3),
      .address(address),
      .write(write),
      .read(read),
      .waitrequest(waitrequest),
      .writedata(writedata),
      .byteenable(byteenable),
      .readdata(readdata),
  );

  mem #(INSTR_INIT_FILE) #(DATA_INIT_FILE) memInst (
      .clk(clk),
      .address(address),
      .write(write),
      .read(read),
      .waitrequest(waitrequest),
      .writedata(writedata),
      .byteenable(byteenable),
      .readdata(readdata)
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

    @(posedge clk);
    reset <= 1;

    @(posedge clk);
    reset <= 0;
    
    

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
      $fdisplay(STDERR, "Cycle Count: %d, register_v0: %d, register_v3: %d, active: %d", cycle_count, register_v0, register_v3, active);
      $fdisplay(STDERR, "Instruction address: %h, Instruction: %b, Data output: %h", instr_address, instr_readdata, data_readdata);
      //$fdisplay(STDERR, "Data address: %h, Data: %b", data_address, data_readdata);
    end

    $display("%d", register_v0);

    $finish;

  end

endmodule
