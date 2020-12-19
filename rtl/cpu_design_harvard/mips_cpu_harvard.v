module mips_cpu_harvard (
    input logic clk,
    reset,
    output logic active,
    output logic [31:0] register_v0,

    input logic clk_enable,

    output logic [31:0] instr_address,  //PC Next
    input  logic [31:0] instr_readdata,  //Data stored at address determined by PCnext

    output logic [31:0] data_address,  //ALU_result
    output logic data_write,  //control signal Data memory write enable for data
    output logic data_read,
    output logic [31:0] data_writedata,
    input logic [31:0] data_readdata,
    
    //output logic pcsrc, pcsrclast					//debug
    output logic [31:0] register_debug,				//debug (+ @datapath)
    output logic [31:0] alu1, alu2					//debug (+ @datapath)
);

  logic memtoreg1, memtoreg2, branch, alusrc, regdst1, regdst2, regwrite, jump1, jump, zero, pcsrc;
  
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
      .active(active),
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
      .register_v0(register_v0), //
      
	  .register_debug(register_debug),						//debug (+ in datapath.v)
      //.pcsrclast(pcsrclast),							//debug (+ in datapath.v)
      .srca(alu1),										//debug (+ in datapath.v)
      .srcb(alu2)										//debug (+ in datapath.v)
  );
  



/*  	OLD ACTIVE SIGNAL DEFINITION

  always @(posedge clk) begin
    if (reset) active <= 1;
    else begin  //If PC counter points to address 0, then the active flag is set to 0
      if (clk_enable == 1) active <= (instr_address == 32'h00000000) ? 1'b0 : 1'b1;
      else active <= 0;
    end
  end
*/


endmodule





/*  NO SWITCHING OF ENDIANNESS

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



/*  WITH SWITCHING FROM LITTLE (MEMORY) TO BIG ENDIAN (CPU)


  // Switch from little endian to big endian and vice-versa when reading/writing to memories
  logic [31:0] 	instr_readdata_be, 
  				data_readdata_be, 
  				data_writedata_be;
  
  endian_switch switch_instr_readdata (
  	  .in(instr_readdata),
      .out(instr_readdata_be)
  );
  
  endian_switch switch_data_readdata (
  	  .in(data_readdata),
      .out(data_readdata_be)
  );
  
  endian_switch switch_data_writedata (
  	  .in(data_writedata_be),
      .out(data_writedata)
  );



  controller control (
      .op(instr_readdata_be[31:26]),
      .funct(instr_readdata_be[5:0]),
      .dest(instr_readdata_be[20:16]),
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
      .instr_readdata(instr_readdata_be),
      .data_readdata(data_readdata_be),
      .data_address(data_address),
      .data_writedata(data_writedata_be),
      .register_v0(register_v0),
      .register_v3(register_v3),
      .pcsrclast(pcsrclast),
//      .srca(alu1),
//      .srcb(alu2)
  );




*/
