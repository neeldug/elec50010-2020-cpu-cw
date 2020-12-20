module aludec (
    input  logic [5:0] funct,
    op,
    input  logic storeloop,
    input logic [1:0] state,
    input  logic [4:0] dest,
    input  logic [1:0] aluop,
    output logic [4:0] alucontrol
);

  always @(*)
    case (aluop)  //edge what if we have a 2'b11 eventhough it is illegal.

      2'b00: alucontrol = 5'b00011;  //ADDI -- USED FOR LOAD AND STORE INSTRUCTIONS
      2'b01:
      alucontrol = 5'b11000;	//Jump instruction use the alu operation needed for Jump Register else don't need alu.
      2'b10:
      case (op)
/*
		6'b100000: alucontrol = 5'b; //Load byte				
		6'b100100: alucontrol = 5'b; //Load byte unsigned
		6'b100001: alucontrol = 5'b; //Load halfword			
		6'b100101: alucontrol = 5'b; //Load halfword unsigned
		6'b100011: alucontrol = 5'b; //Load word
		6'b100010: alucontrol = 5'b; //Load word left         
		6'b100110: alucontrol = 5'b; //Load word right
		6'b101000: alucontrol = 5'b; //Store byte
		6'b101001: alucontrol = 5'b; //Store halfword
		6'b101011: alucontrol = 5'b; //Store word
*/
        6'b001111: alucontrol = 5'b11001;  //Load upper immidiate
        6'b000100: alucontrol = 5'b00100;  //Branch on equal use SUBU
        6'b000001:
        case (dest)
          5'b00001: alucontrol = 5'b10101;  //Branch on >= 0
          5'b10001:
          alucontrol = 5'b10101; //Branch on >= 0 & link (regwrite active) use SLT mod in control sign
          5'b00000: alucontrol = 5'b10011;  //Branch on < 0 
          5'b10000: alucontrol = 5'b10011;  //Branch on < 0 & link
          default: alucontrol = 5'bxxxxx;
        endcase
        6'b000110: alucontrol = 5'b10111;  //Branch on <= 0
        6'b000111: alucontrol = 5'b10100;  //Branch on > 0
        6'b000101: alucontrol = 5'b10110;  //Branch on != 0
        6'b001001: alucontrol = 5'b00011;  //ADD unsigned immediate
/*
		6'b000010: alucontrol = 5'b; //Jump
		6'b000011: alucontrol = 5'b; //Jump and link
*/
        6'b001100: alucontrol = 5'b00000;  //ANDI
        6'b001101: alucontrol = 5'b00001;  //ORI
        6'b001110: alucontrol = 5'b00010;  //XORI
        6'b001010: alucontrol = 5'b00110;  //Set on less than immediate (signed)
        6'b001011: alucontrol = 5'b00101;  //Set on less than immediate unsigned

        6'b000000:
        case (funct)
          6'b100001: alucontrol = 5'b00011;  //ADD -> ADDU
          6'b100100: alucontrol = 5'b00000;  //AND -> AND
          6'b100011: alucontrol = 5'b00100;  //SUB unsigned -> SUBU
          6'b100101: alucontrol = 5'b00001;  //bitwise OR -> OR
          6'b100110: alucontrol = 5'b00010;  //bitwise XOR -> XOR
          6'b101010: alucontrol = 5'b00110;  //SLT -> SLT
          6'b101011: alucontrol = 5'b00101;  //SLTUnsigned -> SLTU
          6'b011001: alucontrol = 5'b00111;  //Multiply unsigned -> MULTU
          6'b011000: alucontrol = 5'b01000;  //Multiply -> MULT
          6'b000000: alucontrol = 5'b01001;  //Shift left logical ->SLL
          6'b000100: alucontrol = 5'b01010;  //Shift left logical variable -> SLLV
          6'b000011: alucontrol = 5'b01011;  //Shift right arithmetic -> SRA
          6'b000010: alucontrol = 5'b01100;  //Shift right logical -> SRL
          6'b000111: alucontrol = 5'b01101;  //Shift right arithmetic variable -> SRAV
          6'b000110: alucontrol = 5'b01110;  //Shift right logical variable -> SRLV
          6'b011010: alucontrol = 5'b01111;  //Divide signed DIV
          6'b011011: alucontrol = 5'b10000;  //Divide unsigned DIVU
          6'b010001: alucontrol = 5'b10001;  //MTHI
          6'b010011: alucontrol = 5'b10010;  //MTLO
          6'b010000: alucontrol = 5'b11010;  //MFHI
          6'b010010: alucontrol = 5'b11011;  //MFLO
/*
		  6'b001000: alucontrol = 5'b10111; //Jump register JR
		  6'b001001: alucontrol = 5'b10111; //Jump and link register
*/
          default:   alucontrol = 5'bxxxxx;  //???
        endcase
        default: alucontrol = 5'bxxxxx;  //???		
      endcase
      default: alucontrol = 5'bxxxxx;  //case aluop= 11 ???
    endcase
endmodule


// In this module we are setting the control signals for the ALU. Refer to the table 7.2 page 376. (for team)
// Note: The aluop can't be 2'b11. 
// The default: case(funct) replaces an iterative: 2'b10 & 5'bxxxxx (funct).

//For all jump Instruction we set the alu to Jump register option, so the result bit will take the value of srcA but will have an effect on register/pc only when the control signals are right.


