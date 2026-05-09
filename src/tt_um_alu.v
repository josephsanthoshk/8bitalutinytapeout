module tt_um_alu (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire ena,
    input  wire clk,
    input  wire rst_n
);

// data bus
wire [7:0] ui = ui_in;

// operand registers
reg [7:0] A;
reg [7:0] B;

// ALU outputs
reg [7:0] result;
reg zero;
reg carry;

// control signals
wire loadA   = uio_in[0];
wire loadB   = uio_in[1];
wire execute = uio_in[2];
wire [2:0] opcode = uio_in[5:3];

// combinational ALU
reg [7:0] alu_result;
reg alu_zero;
reg alu_carry;
reg [8:0] temp;

always @(*) begin
    alu_result = result;
    alu_zero = zero;
    alu_carry = carry;
    temp = 9'b0;

    case(opcode)

        3'b000: begin
            temp = A + B;
            alu_result = temp[7:0];
            alu_carry = temp[8];
        end

        3'b001: begin
            temp = A - B;
            alu_result = temp[7:0];
            alu_carry = temp[8];
        end

        3'b010: begin
            alu_result = A & B;
            alu_carry = 0;
        end

        3'b011: begin
            alu_result = A | B;
            alu_carry = 0;
        end

        3'b100: begin
            alu_result = A ^ B;
            alu_carry = 0;
        end

        3'b101: begin
            alu_result = A << 1;
            alu_carry = A[7];
        end

        3'b110: begin
            alu_result = A >> 1;
            alu_carry = A[0];
        end

        3'b111: begin
            alu_result = (A == B) ? 8'hFF : 8'h00;
            alu_carry = 0;
        end

    endcase

    alu_zero = (alu_result == 8'b0);
end


// sequential registers
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        A <= 8'b0;
        B <= 8'b0;
        result <= 8'b0;
        zero <= 0;
        carry <= 0;
    end

    else if(ena) begin

        if(loadA)
            A <= ui;

        if(loadB)
            B <= ui;

        if(execute) begin
            result <= alu_result;
            zero   <= alu_zero;
            carry  <= alu_carry;
        end

    end
end


// output result
assign uo_out = result;


// flag outputs
assign uio_out[6] = zero;
assign uio_out[7] = carry;

// unused outputs
assign uio_out[5:0] = 6'b000000;

// enable flag outputs
assign uio_oe = 8'b11000000;

endmodule
