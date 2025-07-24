# IEEE-754-Single-Precision-Floating-Point-Adder-Subtractor
to practice pipelining

| Stage | Name                                | Function in Code                                                       |
| ----- | ----------------------------------- | ---------------------------------------------------------------------- |
| S1    | Exponent Subtractor                 | Extracts, compares exponents; determines `Num_shift` and larger number |
| S2    | Fraction Selector + Right Shifter   | Aligns mantissas and adds implicit 1s                                  |
| S3    | ★ Mantissa Reordering               | Ensures always subtract smaller from larger                            |
| S4    | Add/Subtract + Leading Zero Counter | Performs mantissa addition/subtraction, counts leading zeros           |
| S5    | Normalize & Assemble                | Shifts, adjusts exponent, determines sign, builds final 32-bit result  |

[EDA Playground](https://www.edaplayground.com) --> Tools & Simulators --> Icarus Verilog 12.0 --> Open EPWave after run


Now I'll walk through the code with actual numbers <br>
let's say **Number1 = 1.5**, **Number2 = 2.5**, **mode = 0 (addition)**

##### Stage 1
Extract exponents: <br>
Number1 exponent = 0 (since 1.5 = 1.5 × 2⁰)<br>
Number2 exponent = 1 (since 2.5 = 1.25 × 2¹)<br>
Find difference `t` = |0 - 1| = 1<br>
Larger exponent `r` = max(0, 1) = 1 --> So Number2 has the larger exponent<br>
Identify which mantissa is small (Number1) and which is large (Number2)<br>
###### Pipeline registers after Stage 1:
`s1` = sign of 1.5 = 0<br>
`s2` = sign of 2.5 = 0<br>
`e1` = 0, `e2` = 1  (`e` is exponent) <br>
`m1` = mantissa of 1.5 (without leading 1) = 0.5<br>
`m2` = mantissa of 2.5 (without leading 1) = 0.25<br>
`Num_shift` = 1 (number of bits to shift smaller mantissa)<br>

##### Stage 2
Add implicit 1 to mantissas:<br>
This step is essential because the IEEE-754 format only stores the fractional part of the mantissa, implicitly assuming a leading 1 for normalized numbers.
Number1 mantissa becomes 1 + 0.5 = 1.5<br>
Number2 mantissa becomes 1 + 0.25 = 1.25<br>
Shift smaller mantissa right by t = 1:<br>
Number1 mantissa → 1.5 / 2 = 0.75<br>
Larger mantissa remains the same: 1.25<br>
###### Pipeline registers after Stage 2:
`S_exp_mantissa_pipe2` = 0.75 (shifted smaller mantissa)<br>
`L1_mantissa_pipe2` = 1.25 (larger mantissa)<br>

##### Stage 3
Compare shifted mantissas: 0.75 (small) < 1.25 (large), so order remains<br>
###### Pipeline registers after Stage 3:
`S_mantissa` = 0.75<br>
`L_mantissa` = 1.25<br>

(The comparison ensures that subsequent arithmetic (addition or subtraction) is performed such that the result always has a non-negative mantissa when subtraction occurs. This simplifies hardware design and supports correct sign calculation in special cases.)

##### Stage 4
Since both signs are 0 (same), perform addition:<br>
`Add_mant` = 0.75 + 1.25 = 2.0<br>
Count leading zeros (not needed here)<br>
The result mantissa is now 2.0 (which is larger than 1.0, so it’s not normalized according to IEEE 754)<br>

##### Stage 5
Because mantissa > 1 (2.0), shift right and increase exponent by 1:<br>
Normalized mantissa = 1.0 (from 10. ... we shifted right and got 1. ... then fix exponent) <br>
Exponent = `r` + 1 = 1 + 1 = 2<br>
Final sign = 0 (both inputs positive)<br>
Compose final floating-point number: sign=0, exponent=2, mantissa=0 <br>
1.5 + 2.5 = 4.0<br>


New (better) Example for Stage 4: Subtraction with Leading Zeros<br>
Number1 = 5.0 (positive), Number2 = 3.0 (positive), mode = 1 (subtraction) <br>

Stage 3 output (ready for Stage 4):<br>
`S_mantissa` = 0.6 (smaller mantissa, after alignment)<br>
`L_mantissa` = 1.25 (larger mantissa, after alignment)<br>
Signs:<br>
`s1` = 0 (Number1 positive)<br>
`s2` = 1 (Number2 sign inverted due to subtraction mode)<br>

##### Stage 4
Subtract mantissas: 1.25 - 0.6 = 0.65<br>
Leading Zero Counting:<br>
In binary, 0.65 is roughly 0.1010  (0.1010011001100110011...)<br>
The leading bit of mantissa should be 1 (normalized), but here it’s shifted right and we have 0 in its place.<br>
We need to count how many leading zeros before the first 1 in the result mantissa. (1)<br>
This means we must shift the mantissa left by 1 bit in the next stage to normalize it.<br>
Exponent from previous stage = r (max exponent of inputs)<br>

###### Renormalization values from Stage 4:
`renorm_shift` = 1 (shift left by 1)<br>
`renorm_exp` = -1 (decrement exponent by 1)<br>

##### Stage 5
Shift mantissa left by the number of leading zeros found: Final Mantissa = `Add_mant`<<`renorm_shift` <br>
0.65 * 2 = 1.3 (shifting left by 1 bit doubles the mantissa)<br>
Adjust exponent accordingly: Final Exponent=`r`+`renorm_exp`=`r−1`<br>
Determine final sign:<br>
Since mode = subtract and signs differ, final sign is taken from the larger magnitude input (in this case, Number1’s sign = 0)<br>
Assemble the final IEEE-754 result<br>
