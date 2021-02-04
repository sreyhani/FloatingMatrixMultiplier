`timescale 1ns / 1ps

module comb_multiplier(
    input [31:0] input_a,
    input [31:0] input_b,
    output [31:0] output_z
);
    reg       [31:0]  z;
    reg       [23:0] a_m, b_m, z_m;
    reg       [9:0] a_e, b_e, z_e;
    reg       a_s, b_s, z_s;
    reg       guard, round_bit, sticky;
    reg       [49:0] product;
    integer i;

    always @(input_a,input_b) begin
        a_e = input_a[30:23]-127;
        b_e = input_b[30:23]-127;
        a_m[22:0] = input_a[22:0];
        b_m[22:0] = input_b[22:0];
        a_s = input_a[31];
        b_s = input_b[31];
        //if a is NaN or b is NaN return NaN
        if ((a_e == 128 && a_m != 0) || (b_e == 128 && b_m != 0)) begin
            z[31] = 1;
            z[30:23] = 255;
            z[22] = 1;
            z[21:0] = 0;
            //if a is inf return inf
        end else if (a_e == 128) begin
            z[31] = a_s ^ b_s;
            z[30:23] = 255;
            z[22:0] = 0;
            //if b is zero return NaN
            if (($signed(b_e) == -127) && (b_m == 0)) begin
                z[31] = 1;
                z[30:23] = 255;
                z[22] = 1;
                z[21:0] = 0;
            end
            //if b is inf return inf
        end else if (b_e == 128) begin
            z[31] = a_s ^ b_s;
            z[30:23] = 255;
            z[22:0] = 0;
            //if a is zero return NaN
            if (($signed(a_e) == -127) && (a_m == 0)) begin
                z[31] = 1;
                z[30:23] = 255;
                z[22] = 1;
                z[21:0] = 0;
            end
            //if a is zero return zero
        end else if (($signed(a_e) == -127) && (a_m == 0)) begin
            z[31] = a_s ^ b_s;
            z[30:23] = 0;
            z[22:0] = 0;
            //if b is zero return zero
        end else if (($signed(b_e) == -127) && (b_m == 0)) begin
            z[31] = a_s ^ b_s;
            z[30:23] = 0;
            z[22:0] = 0;
        end else begin
            //Denormalised Number
            if ($signed(a_e) == -127) begin
                a_e = -126;
            end else begin
                a_m[23] = 1;
            end
            //Denormalised Number
            if ($signed(b_e) == -127) begin
                b_e = -126;
            end else begin
                b_m[23] = 1;
            end
            //normalize a
            for (i = 0; i < 23;i = i + 1)
            begin
                if (a_m[23] == 0)
                begin
                    a_m = a_m << 1;
                    a_e = a_e - 1;
                end
                if (b_m[23] == 0)
                begin
                    b_m = b_m << 1;
                    b_e = b_e - 1;
                end
            end
            //multiply    
            z_s = a_s ^ b_s;
            z_e = a_e + b_e + 1;
            product = a_m * b_m * 4;
            z_m = product[49:26];
            guard = product[25];
            round_bit = product[24];
            sticky = (product[23:0] != 0);
            //normalize product
            for (i = 0; i < 23;i = i + 1)
            begin
                if (z_m[23] == 0)
                begin
                    z_e = z_e - 1;
                    z_m = z_m << 1;
                    z_m[0] = guard;
                    guard = round_bit;
                    round_bit = 0;
                end
            end
      
            for(i = 0; i < 128; i = i+1)
            begin
                if ($signed(z_e) < -126) begin
                    z_e = z_e + 1;
                    z_m = z_m >> 1;
                    guard = z_m[0];
                    round_bit = guard;
                    sticky = sticky | round_bit;
                end
            end 
            //round
            if (guard && (round_bit | sticky | z_m[0])) begin
                z_m <= z_m + 1;
                if (z_m == 24'hffffff) begin
                    z_e <=z_e + 1;
                end
            end
            //pack
            z[22 : 0] = z_m[22:0];
            z[30 : 23] = z_e[7:0] + 127;
            z[31] = z_s;
            if ($signed(z_e) == -126 && z_m[23] == 0) begin
                z[30 : 23] = 0;
            end
            //if overflow occurs, return inf
            if ($signed(z_e) > 127) begin
                z[22 : 0] = 0;
                z[30 : 23] = 255;
                z[31] = z_s;
            end
        end
    end
    assign output_z = z;
endmodule: comb_multiplier