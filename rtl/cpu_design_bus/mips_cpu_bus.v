module mips_cpu_harvard (
    input logic clk,
    reset,
    output logic active,
    output logic [31:0] register_v0, register_v3,

    output logic [31:0] address,  //PC Next and ALU result
    output logic write,  //control signal Data memory write enable for data
    output logic read,
    input logic waitrequest,
    output logic [31:0] writedata,
    output logic [3:0] byteenable,
    input logic [31:0] readdata  //Data stored at address determined by PCnext
);

  logic memtoreg1, memtoreg2, branch, alusrc, regdst1, regdst2, regwrite, jump1, jump, zero, pcsrc, pcen;
  
  logic [4:0] alucontrol;
  logic [2:0] loadcontrol;
  
  
  
  // SWITCH FROM LITTLE ENDIAN TO BIG ENDIAN AND VICE-VERSA WHEN READING/WRITING TO MEMORIES
  logic [31:0] 	readdata_be,  
  				writedata_be;
  
  endian_switch switch_readdata (
  	  .in(readdata),
      .out(readdata_be)
  );
  
  endian_switch switch_writedata (
  	  .in(writedata_be),
      .out(writedata)
  );

/*
module controller (
	input logic clk,
	reset,
    input logic [5:0] op,
    funct,
    input logic [4:0] dest,
    input logic zero,
    output logic memtoreg2,
    memtoreg1,
    output logic memwrite,
    alusrca,
    output logic regdst2,
    regdst1,
    output logic regwrite,
    output logic jump1,
    jump,
    output logic iord,
    output logic pcen,
    output logic pcwrite,
    irwrite,
    output logic [1:0] alusrcb,
    output logic [1:0] pcsrc,
    output logic [4:0] alucontrol,
    output logic [2:0] loadcontrol
);
*/

  controller control (
      .op(readdata_be[31:26]),
      .funct(readdata_be[5:0]),
      .dest(readdata_be[20:16]),
      .zero(zero),
      .memtoreg2(memtoreg2),
      .memtoreg1(memtoreg1),
      .memwrite(write),
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
//      .clk_enable(clk_enable),
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
      .address(address),
      .readdata(readdata_be),
      .address(address),
      .writedata(writedata_be),
      .register_v0(register_v0),
      .register_v3(register_v3),
      .pcsrclast(pcsrclast)
  );


  always @(posedge clk) begin
	if(reset) active <= 1;
	else begin						//If PC counter points to address 0, then the active flag is set to 0
		if(clk_enable == 1) active <= (instr_address == 32'h00000000) ? 1'b0 : 1'b1;
		else active <= 0;
		end
  end


/* OLD VERSION WITHOUT ENDIAN SWITCH

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
  
*/

endmodule
