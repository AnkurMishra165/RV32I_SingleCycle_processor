
// main_decoder.v - logic for main decoder

module main_decoder (
    input  [6:0] op,
	 input [2:0] funct3,
	 input funct7b5,
	 input Zero, ALUR31,
    output [1:0] ResultSrc,
    output       MemWrite, Branch, ALUSrc,
    output       RegWrite, Jump,Jalr,
    output [2:0] ImmSrc,
    output [1:0] ALUOp
);

reg [11:0] controls;
reg TakeBranch;
always @(*) begin
TakeBranch=0;
    casez (op)
        // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_ALUOp_Jump_jalr
        7'b0000011: controls = 12'b1_000_1_0_01_00_0_0; // lw
        7'b0100011: controls = 12'b0_010_1_1_00_00_0_0; // sw
        7'b0110011: controls =  12'b1_xxx_0_0_00_10_0_0; // R–type
		              
		
        7'b1100011: begin
		              controls=  12'b0_100_0_0_00_01_0_0;
						  case(funct3)
						  3'b000: TakeBranch=Zero;  //beq
						  3'b001: TakeBranch=!Zero;  //bne
						  3'b101: TakeBranch=!ALUR31;  //bge
						  3'b100: TakeBranch= ALUR31;  //blt
						  3'b110: TakeBranch= ALUR31; //bltu
						  3'b111: TakeBranch= !ALUR31; //bgeu
						  endcase
		  
		  
		  end
        7'b0010011: begin
		  case(funct3)
		  3'b000:controls = 12'b1_000_1_0_00_10_0_0; // Addi
		  3'b001:controls = 12'b1_101_1_0_00_10_0_0; //slli
		  3'b011:controls = 12'b1_001_1_0_00_10_0_0; //SLTUI
		  3'b100:controls = 12'b1_000_1_0_00_10_0_0; //xori
		  3'b101: begin
		  if(!funct7b5) controls= 12'b1_101_1_0_00_10_0_0; //srli
		  else if(funct7b5) controls= 12'b1_101_1_0_00_10_0_0; //srai
		  end
		  endcase
		  
		  end
		  
        7'b1101111: controls = 12'b1_110_0_0_10_00_1_0; // jal
		  7'b1100111: controls = 12'b1_000_1_0_10_00_0_1; // jalr
		  7'b0?10111: controls = 12'b1_xxx_x_0_11_xx_0_0; // lui or auipc
		  
		  
        default:    controls = 12'bx_xxx_x_x_xx_xx_x_x; // ???
    endcase
end

assign Branch=TakeBranch;
assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, ALUOp, Jump, Jalr} = controls;

endmodule

