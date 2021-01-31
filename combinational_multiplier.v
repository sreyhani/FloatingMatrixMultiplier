module multiplier(
    input [31:0] input_a,
    input [31:0] input_b,
    output [31:0] input_z,
);
    reg [7:0] a_e;
    reg [7:0] b_e;
    reg [23:0] a_m;
    reg [23:0] b_m;
    reg a_s;
    reg b_s;

    always @(*) begin
        a_e = a[30:23]-127;
        b_e = b[30:23]-127;
        a_m[22:0] = a[22:0];
        b_m[22:0] = b[22:0];
        a_s = a[31];
        b_s = b[31];

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
        end
    end
endmodule: multiplier