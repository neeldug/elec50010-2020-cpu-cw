module maindec (
    input logic [5:0] op,
    funct,
    input logic [4:0] dest,
    output logic memtoreg1,
    data_write,
    output logic branch,
    alusrc,
    output logic regdst2,
    regdst1,
    output logic regwrite,
    output logic jump1,
    jump,
    output logic [1:0] aluop,
    output logic [2:0] loadcontrol
);


  reg [9:0] controls;


  //Probably needs to use a always@(*)

  assign {regwrite, regdst2, regdst1, alusrc, branch, data_write, memtoreg1, jump, aluop} = controls;


  // Assign 11 elements names as aluop consist of 2 bits so rightfully fills the reg controls.
  // Correspond to the bits below from left to right in the same order (starting with regwrite and ending with aluop).

always @(posedge clk)begin //Stage 1: Fetch.
	iord = 0;
	alusrca = 0;
	alusrcb = 2'b01;
	aluop = 2'b00;
	pcsrc = 0;
	irwrite = 1;
	pcwrite = 1;
	always @(posedge clk) begin //Stage 2: buffer.
		// do nothing to let the memory output and the register store.
		always @(posedge clk) begin
	


			end
		end
	end
endmodule


// We are currently setting all the control signals by looking at the opcode of the instrunctions.
// We created an reg (=array) of control signals so that it is easier to implement.
// In order to understand this section please refer to page 376 of the book (table 7.3) for team.

