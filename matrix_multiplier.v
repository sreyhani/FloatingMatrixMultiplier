`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2021 09:43:27 AM
// Design Name: 
// Module Name: matrix_multiplier
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module matrix_multiplier
#(
parameter NUM_FIRST_ROW = 2,
parameter NUM_FIRST_COL = 2,
parameter NUM_SECOND_COL = 2
)
(
In1,In2,out_ack,clk,rst,load,Out,out_ready
);
localparam ELEMENT_LENGTH = 32;
localparam NUM_SECOND_ROW = NUM_FIRST_COL;
localparam NUM_FINAL_ROW = NUM_FIRST_ROW;
localparam NUM_FINAL_COL = NUM_SECOND_COL;
localparam FIRST_IN_LENGTH = ELEMENT_LENGTH * NUM_FIRST_ROW * NUM_FIRST_COL;
localparam SECOND_IN_LENGTH = ELEMENT_LENGTH * NUM_SECOND_ROW * NUM_SECOND_COL;
localparam OUT_LENGTH = ELEMENT_LENGTH * NUM_FINAL_ROW * NUM_FINAL_COL;

input [FIRST_IN_LENGTH - 1 : 0] In1;
input [SECOND_IN_LENGTH - 1 : 0] In2;
input clk,rst,load;
input out_ack;
output [OUT_LENGTH - 1 : 0] Out;
output reg out_ready;

localparam SELECT_LENGTH = NUM_FIRST_COL;
localparam get_input_s = 0;
localparam mult_elements_in1_s = 1;
localparam mult_elements_in2_s = 2;
localparam wait_for_mult_s = 3;
localparam add_elements_s = 4;
localparam wait_for_add_s = 5;
localparam out_is_ready_s = 6;

reg [ELEMENT_LENGTH-1:0] out_matrix [1:NUM_FINAL_ROW][1:NUM_FINAL_COL];
wire [ELEMENT_LENGTH-1:0] temp_matrix [1:NUM_FINAL_ROW][1:NUM_FINAL_COL];
wire [ELEMENT_LENGTH-1:0] temp2_matrix [1:NUM_FINAL_ROW][1:NUM_FINAL_COL];
reg [FIRST_IN_LENGTH - 1 : 0] In1_Copy;
reg [SECOND_IN_LENGTH - 1 : 0] In2_Copy;
reg [SELECT_LENGTH - 1:0] select_signal;
reg [ELEMENT_LENGTH * NUM_FIRST_COL - 1:0] first_rows [1:NUM_FIRST_ROW];
reg [ELEMENT_LENGTH * NUM_SECOND_ROW - 1:0] second_cols [1:NUM_SECOND_COL];
wire [ELEMENT_LENGTH - 1:0] out_rows_mux [1:NUM_FIRST_ROW];
wire [ELEMENT_LENGTH - 1:0] out_cols_mux [1:NUM_SECOND_COL];
reg [2:0] state;

// multiplier signals
reg rst_mult = 0;
reg in1_stb = 0;
reg in2_stb = 0;
reg output_ack = 0;
wire output_stb[1:NUM_FIRST_ROW][1:NUM_SECOND_COL];
wire in1_ack[1:NUM_FIRST_ROW][1:NUM_SECOND_COL];
wire in2_ack[1:NUM_FIRST_ROW][1:NUM_SECOND_COL];
reg in1_full_ack = 1;
reg in2_full_ack = 1;
reg output_full_stb = 1;

// adder signals
reg reset_adder = 0;
reg load_input = 0;
reg res_ack = 0;
wire res_ready[1:NUM_FIRST_ROW][1:NUM_SECOND_COL];
reg res_full_ready = 1;

integer k,t,g,l,n,m;
genvar i,j;

generate
    for(i=0; i<NUM_FINAL_ROW; i=i+1) begin
        for (j=0 ;j<NUM_FINAL_COL; j=j+1) begin
            assign Out[OUT_LENGTH-1-ELEMENT_LENGTH*(i*NUM_FINAL_COL+j):OUT_LENGTH-1-ELEMENT_LENGTH*(i*NUM_FINAL_COL+j)-(ELEMENT_LENGTH-1)] = out_matrix[i+1][j+1];
        end
    end
endgenerate
generate
    for(i=0; i<NUM_FIRST_ROW; i=i+1) begin
        always @* begin
            first_rows[i+1] = In1_Copy[FIRST_IN_LENGTH - 1 - i * NUM_FIRST_COL * ELEMENT_LENGTH:FIRST_IN_LENGTH - 1 - i * NUM_FIRST_COL * ELEMENT_LENGTH -(NUM_FIRST_COL*ELEMENT_LENGTH - 1)];
        end
        mux #(.WIDTH(32),.NUM_INPUTS(NUM_FIRST_COL)) mux_i(
                .In(first_rows[i+1]),
                .select(select_signal),
                .Out(out_rows_mux[i+1]));
    end
endgenerate
generate
    for(j=0; j<NUM_SECOND_COL; j=j+1) begin
        always @* begin
            second_cols[j+1] = In2_Copy[SECOND_IN_LENGTH - 1 - j * NUM_SECOND_ROW * ELEMENT_LENGTH:SECOND_IN_LENGTH - 1 - j * NUM_SECOND_ROW * ELEMENT_LENGTH -(NUM_SECOND_ROW*ELEMENT_LENGTH - 1)];
        end
        mux #(.WIDTH(32),.NUM_INPUTS(NUM_SECOND_ROW)) mux_j(
                .In(second_cols[j+1]),
                .select(select_signal),
                .Out(out_cols_mux[j+1]));
    end
endgenerate
generate
    for(i=1; i<= NUM_FIRST_ROW; i=i+1) begin
        for(j=1; j<=NUM_SECOND_COL; j=j+1) begin
            single_multiplier multiplier_i(
                .clk(clk),
                .rst(rst_mult),
                .input_a(out_rows_mux[i]),
                .input_a_stb(in1_stb),
                .input_a_ack(in1_ack[i][j]),
                .input_b(out_cols_mux[j]),
                .input_b_stb(in2_stb),
                .input_b_ack(in2_ack[i][j]),
                .output_z(temp_matrix[i][j]),
                .output_z_stb(output_stb[i][j]),
                .output_z_ack(output_ack));
            adder adder_i(
                .clk(clk),
                .reset(reset_adder),
                .load(load_input),
                .Number1(temp_matrix[i][j]),
                .Number2(out_matrix[i][j]),
                .result_ack(res_ack),
                .Result(temp2_matrix[i][j]),
                .result_ready(res_ready[i][j]));
        end
    end
endgenerate
always @* 
begin
    in1_full_ack = 1;
    in2_full_ack = 1;
    output_full_stb = 1;
    res_full_ready = 1;
    for(n=1; n<= NUM_FIRST_ROW; n=n+1) begin
        for(m=1; m<=NUM_SECOND_COL; m=m+1) begin
                in1_full_ack = in1_full_ack & in1_ack[n][m];
                in2_full_ack = in2_full_ack & in2_ack[n][m];
                output_full_stb = output_full_stb & output_stb[n][m];
                res_full_ready = res_full_ready & res_ready[n][m];
         end
    end
 end
always @(posedge clk, negedge rst) begin
    if (!rst) begin
        state <= get_input_s;
        In1_Copy <= 0;
        In2_Copy <= 0;
        rst_mult <= 1;
        reset_adder <= 0;
        select_signal <= 0;
        for(g=1; g<=NUM_FINAL_ROW; g=g+1) begin
                for (l=1 ;l<=NUM_FINAL_COL; l=l+1) begin
                   out_matrix[g][l] <= 0;
            end
        end
    end
    else begin
        case (state)
            get_input_s: begin
                    if (load) begin
                       In1_Copy <= In1;
                       In2_Copy <= In2;
                       state <= mult_elements_in1_s;
                       rst_mult <= 0;
                    end
                    else begin
                        for(g=1; g<=NUM_FINAL_ROW; g=g+1) begin
                            for (l=1 ;l<=NUM_FINAL_COL; l=l+1) begin
                                out_matrix[g][l] <= 0;
                            end
                        end
                        state <= get_input_s;
                        rst_mult <= 1;
                        select_signal <= 0;
                        output_ack <= 0;
                        res_ack <= 0;
                        in1_stb <= 0;
                        in2_stb <= 0;
                        load_input <= 0;
                    end
                end
            mult_elements_in1_s: begin
                    
                    if(in1_full_ack) begin
                        in1_stb <= 1;
                        output_ack <= 0;
                        state <= mult_elements_in2_s;
                    end
                    else begin
                        state <= mult_elements_in1_s;
                    end
                end
            mult_elements_in2_s: begin
                    if(in2_full_ack) begin
                        in2_stb <= 1;
                        output_ack <= 0;
                        state <= wait_for_mult_s;
                    end
                    else begin
                        state <= mult_elements_in2_s;
                    end
            end
            wait_for_mult_s: begin
                   if(output_full_stb) begin
                        state <= add_elements_s;
                        reset_adder <= 1;
                   end
                   else begin
                        state <= wait_for_mult_s;
                   end
                end
            add_elements_s: begin
                    load_input <= 1;
                    state <= wait_for_add_s;
                end
            wait_for_add_s: begin
                    if (res_full_ready) begin
                        for(k=1; k<= NUM_FIRST_ROW; k=k+1) begin
                            for(t=1; t<=NUM_SECOND_COL; t=t+1) begin
                                out_matrix[k][t] <= temp2_matrix[k][t];
                            end
                        end
                        output_ack <= 1;
                        res_ack <= 1;
                        in1_stb <= 0;
                        in2_stb <= 0;
                        load_input <= 0;
                        if (select_signal == NUM_FIRST_ROW - 1) begin
                            state <= out_is_ready_s;
                        end
                        else begin
                            select_signal <= select_signal + 1;
                            state <= mult_elements_in1_s;
                        end
                    end
                    else begin
                        output_ack <= 0;
                        res_ack <= 0;
                        state <= wait_for_add_s;
                    end
                end
            out_is_ready_s: begin
                    out_ready <= 1;
                    if (out_ack) begin
                        state <= get_input_s;
                        output_ack <= 0;
                        res_ack <= 0;
                        in1_stb <= 0;
                        in2_stb <= 0;
                        load_input <= 0;
                    end
                    else begin
                        state <= out_is_ready_s;
                    end
                end
            default: begin
                    state <= get_input_s;
                    In1_Copy <= 0;
                    In2_Copy <= 0;
                end
        endcase
    end     
end
endmodule
