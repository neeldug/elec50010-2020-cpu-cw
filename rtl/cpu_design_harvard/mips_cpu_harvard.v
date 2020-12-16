module mips_cpu_harvard (
    input logic clk,
    reset,
    output logic active,
    output logic [31:0] register_v0, register_v3,

    input logic clk_enable,

    output logic [31:0] instr_address,  //PC Next
    input  logic [31:0] instr_readdata,  //Data stored at address determined by PCnext

    output logic [31:0] data_address,  //ALU_result
    output logic data_write,  //control signal Data memory write enable for data
    output logic data_read,
    output logic [31:0] data_writedata,
    input logic [31:0] data_readdata,
    output logic pcsrc, pcsrclast
);

  logic memtoreg1, memtoreg2, branch, alusrc, regdst1, regdst2, regwrite, jump1, jump, zero, actimpl; //pcsrc

  logic [4:0] alucontrol;
  logic [2:0] loadcontrol;

  controller control (
      .op(instr_readdata[31:26]),
      .funct(instr_readdata[5:0]),
      .dest(instr_readdata[20:16]),
      .zero(zero),
      .memtoreg2(memtoreg2),
      .memtoreg1(memtoreg1),
      .data_write(data_write),
      .pcsrc(pcsrc),
      .alusrc(alusrc),
      .regdst2(regdst2),
      .regdst1(regdst1),
      .regwrite(regwrite),
      .jump1(jump1),
      .jump(jump),
      .alucontrol(alucontrol),
      .loadcontrol(loadcontrol)
  );

  datapath datap(
      .clk(clk),
      .reset(reset),
      .clk_enable(clk_enable),
      .memtoreg2(memtoreg2),
      .memtoreg1(memtoreg1),
      .alusrc(alusrc),
      .pcsrc(pcsrc),
      .regdst2(regdst2),
      .regdst1(regdst1),
      .regwrite(regwrite),
      .jump1(jump1),
      .jump(jump),
      .alucontrol(alucontrol),
      .loadcontrol(loadcontrol),
      .zero(zero),
      .instr_address(instr_address),
      .instr_readdata(instr_readdata),
      .data_readdata(data_readdata),
      .data_address(data_address),
      .data_writedata(data_writedata),
      .register_v0(register_v0),
      .register_v3(register_v3),
      .pcsrclast(pcsrclast)
  );
/* 
  delayslot dlslot(
	  .clk(clk),
	  .memtoreg2(memtoreg2),
	  .pcsrc(pcsrc),
	  .jump(jump),
	  .jump1(jump1),
	  .instr_readdata(instr_readdata),
	  .result2(result2),
	  .pcsrcprime(pcsrcprime),
	  .jumpprime(jumpprime),
	  .jump1prime(jump1prime),
	  .instr_readdata_prime(instr_readdata_prime),
	  .result2prime(result2prime)
  ); */
  	
/*
 assign active = (instr_address==0) ? 0 : 1; //If PC counter points to address 0, then the active flag is set to 0.
*/
/*initial begin
	active = 1;
	end


always @(posedge clk & clk_enable) begin
	if(instr_address == 0) active = 0;
	else active = 1;
end
*/	

always @(posedge clk) begin
	if(clk_enable == 1) active = (instr_address == 32'h00000000) ? 1'b0 : 1'b1; //If PC counter points to address 0, then the CPU is halted
	else active = 1;
  end


endmodule







module delayslot(
	input logic clk, memtoreg2, 
	input logic pcsrc, jump, jump1,
	input logic [25:0] instr_readdata, 
	input logic [31:0] result2,
	output logic pcsrcprime, jumpprime, jump1prime,
	output logic [25:0] instr_readdata_prime, 
	output logic [31:0] result2prime
);

logic a, b, c;
logic [25:0] d;
logic [31:0] e;

if(memtoreg2 != 1'b0) begin
always @(posedge clk) begin
	pcsrcprime = 0;
	jumpprime = 0;
	jump1prime = 0;
	instr_readdata_prime = 32'b0; 
	result2prime = 32'b0;
	end
end else begin	  		  
	delayslot1 brjpdelay1 (
		  .clk(clk),
		  .jump(jump),
		  .jump1(jump1),
		  .pcsrc(pcsrc),
		  .instr_readdata(instr_readdata[25:0]),
		  .result2(result2),
		  .a(a),
		  .b(b),
		  .c(c),
		  .d(d),
		  .e(e)
		  );
	  
	  delayslot2 brjpdelay2 (
		  .clk(clk),
		  .a(a),
		  .b(b),
		  .c(c),
		  .d(d),
		  .e(e),
		  .jumpprime(jumpprime),
		  .jump1prime(jump1prime),
		  .pcsrcprime(pcsrcprime),
		  .instr_readdata_prime(instr_readdata_prime),
		  .result2prime(result2prime)
		  );
end
endmodule
