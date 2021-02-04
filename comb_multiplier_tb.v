`timescale 1ns / 1ps

module comb_mul_tb;
reg [31:0] flp_a, flp_b,valid_z;
wire [31:0] flp_z;
initial
$monitor ("a = %h, b = %h, z = %h valid result: %h", flp_a, flp_b, flp_z,valid_z);

initial
begin
    #1 flp_a = 32'h00000000;
    flp_b = 32'h00000000;
    valid_z = 32'h00000000;
    //+5 x +3 = +15
    #1 flp_a = 32'h40A00000;
    flp_b = 32'h40400000;
    valid_z = 32'h41700000;
    //+7 x -5 = -35
    #10 flp_a = 32'hC0A00000;
    flp_b = 32'h40E00000;
    valid_z = 32'hC20C0000;

#1 $stop;
end
 
comb_multiplier inst1 (
.a(flp_a),
.b(flp_b),
.output_z(flp_z)
);
endmodule