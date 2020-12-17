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

  logic [1:0] aluop;
  logic branch;

  maindec md (
  	  .clk(clk),
  	  .reset(reset),
      .op(op),
      .funct(funct),
      .dest(dest),
      .memtoreg1(memtoreg1),
      .memwrite(memwrite),
      .branch(branch),
      .alusrca( alusrca),
      .alusrcb(alusrcb),
      .regdst2(regdst2),
      .regdst1(regdst1),
      .regwrite(regwrite),
      .jump1(jump1),
      .jump(jump),
      .aluop(aluop),
      .state(state),
      .loadcontrol(loadcontrol)
  );

  aludec ad (
      .clk(clk),
  	  .reset(reset),
      .funct(funct),
      .op(op),
      .dest(dest),
      .aluop(aluop),
      .state(state),
      .alucontrol(alucontrol)
  );
  
  always @(posedge clk) begin
    pcsrc <= (branch & zero);
    memtoreg2 <= (jump | pcsrc);
    pcen <= (pcwrite | pcsrc);
  end
  
endmodule
