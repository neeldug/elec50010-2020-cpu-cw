timeunit 1ns / 10ps;

module tb_harvard;

  parameter INSTR_INIT_FILE = ""  /*default test case if not specified*/;
  parameter DATA_INIT_FILE = ""  /*default data if not specified*/;
  parameter TIMEOUT_CYCLES = 50;

  logic clk;
  logic reset;
  logic active;
  logic [31:0] register_v0;

  logic clk_enable;

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
      .register_v0(register_v0),
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

    //Looping until the CPU finished (sets active low)
    while (active) begin
      @(posedge clk);
    end

    $display("%d", register_v0);

    $finish;

  end

endmodule
