`timescale 1ns/10ps

module IEEE_SP_FP_ADDER(
    input clk,
    input reset,
    input mode,                    // 0 = add, 1 = sub
    input [31:0] Number1,
    input [31:0] Number2,
    output [31:0] Result
);

    // Signal declarations
    reg [31:0] Num_shift;
    reg [7:0] Larger_exp, Larger_exp_pipe2, Larger_exp_pipe3, Larger_exp_pipe4, Larger_exp_pipe5, Final_expo;
    reg [22:0] Small_exp_mantissa, Small_exp_mantissa_pipe2, S_exp_mantissa_pipe2, S_exp_mantissa_pipe3, Small_exp_mantissa_pipe3;
    reg [22:0] S_mantissa, L_mantissa;
    reg [22:0] L1_mantissa_pipe2, L1_mantissa_pipe3, Large_mantissa, Final_mant;
    reg [22:0] Large_mantissa_pipe2, Large_mantissa_pipe3, S_mantissa_pipe4, L_mantissa_pipe4;
    reg [23:0] Add_mant, Add1_mant, Add_mant_pipe5;
    reg [7:0] e1, e1_pipe2, e1_pipe3, e1_pipe4, e1_pipe5;
    reg [7:0] e2, e2_pipe2, e2_pipe3, e2_pipe4, e2_pipe5;
    reg [22:0] m1, m1_pipe2, m1_pipe3, m1_pipe4, m1_pipe5;
    reg [22:0] m2, m2_pipe2, m2_pipe3, m2_pipe4, m2_pipe5;

    reg s1, s2, Final_sign, s1_pipe2, s1_pipe3, s1_pipe4, s1_pipe5;
    reg s2_pipe2, s2_pipe3, s2_pipe4, s2_pipe5;
    reg [3:0] renorm_shift, renorm_shift_pipe5;
    integer signed renorm_exp;

    reg [31:0] Result_reg;
    assign Result = Result_reg;

    always @(*) begin
        // Adjust sign of Number2 if subtract
        s1 = Number1[31];
        s2 = mode ? ~Number2[31] : Number2[31];  // invert sign for subtraction

        e1 = Number1[30:23];
        e2 = Number2[30:23];
        m1 = Number1[22:0];
        m2 = Number2[22:0];

        if (e1 > e2) begin
            Num_shift = e1 - e2;
            Larger_exp = e1;
            Small_exp_mantissa = m2;
            Large_mantissa = m1;
        end else begin
            Num_shift = e2 - e1;
            Larger_exp = e2;
            Small_exp_mantissa = m1;
            Large_mantissa = m2;
        end

        if (e1 == 0 || e2 == 0)
            Num_shift = 0;

        if (e1_pipe2 != 0)
            S_exp_mantissa_pipe2 = {1'b1, Small_exp_mantissa_pipe2[22:1]} >> Num_shift;
        else
            S_exp_mantissa_pipe2 = Small_exp_mantissa_pipe2;

        if (e2 != 0)
            L1_mantissa_pipe2 = {1'b1, Large_mantissa_pipe2[22:1]};
        else
            L1_mantissa_pipe2 = Large_mantissa_pipe2;

        if (S_exp_mantissa_pipe3 < L1_mantissa_pipe3) begin
            S_mantissa = S_exp_mantissa_pipe3;
            L_mantissa = L1_mantissa_pipe3;
        end else begin
            S_mantissa = L1_mantissa_pipe3;
            L_mantissa = S_exp_mantissa_pipe3;
        end

        if (e1_pipe4 != 0 && e2_pipe4 != 0) begin
            if (s1_pipe4 == s2_pipe4)
                Add_mant = S_mantissa_pipe4 + L_mantissa_pipe4;
            else
                Add_mant = L_mantissa_pipe4 - S_mantissa_pipe4;
        end else
            Add_mant = L_mantissa_pipe4;

        // Renormalization
        if (Add_mant[23]) begin
            renorm_shift = 4'd1; renorm_exp = 1;
        end else if (Add_mant[22]) begin
            renorm_shift = 4'd2; renorm_exp = 0;
        end else if (Add_mant[21]) begin
            renorm_shift = 4'd3; renorm_exp = -1;
        end else if (Add_mant[20]) begin
            renorm_shift = 4'd4; renorm_exp = -2;
        end else begin
            renorm_shift = 4'd0; renorm_exp = 0;
        end

        Final_expo = Larger_exp_pipe5 + renorm_exp;
        Add1_mant = (renorm_shift_pipe5 != 0) ? Add_mant_pipe5 << renorm_shift_pipe5 : Add_mant_pipe5;
        Final_mant = Add1_mant[23:1];

        if (s1_pipe5 == s2_pipe5)
            Final_sign = s1_pipe5;
        else if (e1_pipe5 > e2_pipe5)
            Final_sign = s1_pipe5;
        else if (e2_pipe5 > e1_pipe5)
            Final_sign = s2_pipe5;
        else
            Final_sign = (m1_pipe5 > m2_pipe5) ? s1_pipe5 : s2_pipe5;

        Result_reg = {Final_sign, Final_expo, Final_mant};
    end

    always @(posedge clk) begin
        if (reset) begin
            s1_pipe2 <= 0; s2_pipe2 <= 0;
            e1_pipe2 <= 0; e2_pipe2 <= 0;
            m1_pipe2 <= 0; m2_pipe2 <= 0;
            Larger_exp_pipe2 <= 0;
            Small_exp_mantissa_pipe2 <= 0;
            Large_mantissa_pipe2 <= 0;
            s1_pipe3 <= 0; s2_pipe3 <= 0;
            e1_pipe3 <= 0; e2_pipe3 <= 0;
            m1_pipe3 <= 0; m2_pipe3 <= 0;
            Larger_exp_pipe3 <= 0;
            s1_pipe4 <= 0; s2_pipe4 <= 0;
            e1_pipe4 <= 0; e2_pipe4 <= 0;
            m1_pipe4 <= 0; m2_pipe4 <= 0;
            Larger_exp_pipe4 <= 0;
            s1_pipe5 <= 0; s2_pipe5 <= 0;
            e1_pipe5 <= 0; e2_pipe5 <= 0;
            m1_pipe5 <= 0; m2_pipe5 <= 0;
            Larger_exp_pipe5 <= 0;
            S_exp_mantissa_pipe3 <= 0;
            L1_mantissa_pipe3 <= 0;
            S_mantissa_pipe4 <= 0;
            L_mantissa_pipe4 <= 0;
            Add_mant_pipe5 <= 0;
            renorm_shift_pipe5 <= 0;
            Result_reg <= 0;
        end else begin
            s1_pipe2 <= s1; s2_pipe2 <= s2;
            e1_pipe2 <= e1; e2_pipe2 <= e2;
            m1_pipe2 <= m1; m2_pipe2 <= m2;
            Larger_exp_pipe2 <= Larger_exp;
            Small_exp_mantissa_pipe2 <= Small_exp_mantissa;
            Large_mantissa_pipe2 <= Large_mantissa;
            s1_pipe3 <= s1_pipe2; s2_pipe3 <= s2_pipe2;
            e1_pipe3 <= e1_pipe2; e2_pipe3 <= e2_pipe2;
            m1_pipe3 <= m1_pipe2; m2_pipe3 <= m2_pipe2;
            Larger_exp_pipe3 <= Larger_exp_pipe2;
            s1_pipe4 <= s1_pipe3; s2_pipe4 <= s2_pipe3;
            e1_pipe4 <= e1_pipe3; e2_pipe4 <= e2_pipe3;
            m1_pipe4 <= m1_pipe3; m2_pipe4 <= m2_pipe3;
            Larger_exp_pipe4 <= Larger_exp_pipe3;
            s1_pipe5 <= s1_pipe4; s2_pipe5 <= s2_pipe4;
            e1_pipe5 <= e1_pipe4; e2_pipe5 <= e2_pipe4;
            m1_pipe5 <= m1_pipe4; m2_pipe5 <= m2_pipe4;
            Larger_exp_pipe5 <= Larger_exp_pipe4;
            S_exp_mantissa_pipe3 <= S_exp_mantissa_pipe2;
            L1_mantissa_pipe3 <= L1_mantissa_pipe2;
            S_mantissa_pipe4 <= S_mantissa;
            L_mantissa_pipe4 <= L_mantissa;
            Add_mant_pipe5 <= Add_mant;
            renorm_shift_pipe5 <= renorm_shift;
        end
    end
endmodule