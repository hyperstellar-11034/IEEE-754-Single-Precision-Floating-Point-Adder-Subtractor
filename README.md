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


Now I'll walk through the code with actual numbers
let's say **Number1 = 1.5**, **Number2 = 2.5**, **mode = 0 (addition)**

##### Stage 1
Extract exponents:
Number1 exponent = 0 (since 1.5 = 1.5 × 2⁰)
Number2 exponent = 1 (since 2.5 = 1.25 × 2¹)
Find difference `t` = |0 - 1| = 1
Larger exponent `r` = max(0, 1) = 1 --> So Number2 has the larger exponent
Identify which mantissa is small (Number1) and which is large (Number2)
###### Pipeline registers after Stage 1:
`s1` = sign of 1.5 = 0
`s2` = sign of 2.5 = 0
`e1` = 0, `e2` = 1
`m1` = mantissa of 1.5 (without leading 1) = 0.5
`m2` = mantissa of 2.5 (without leading 1) = 0.25
`Num_shift` = 1 (number of bits to shift smaller mantissa)

##### Stage 2
Add implicit 1 to mantissas:
Number1 mantissa becomes 1 + 0.5 = 1.5
Number2 mantissa becomes 1 + 0.25 = 1.25
Shift smaller mantissa right by t = 1:
Number1 mantissa → 1.5 / 2 = 0.75
Larger mantissa remains the same: 1.25
###### Pipeline registers after Stage 2:
`S_exp_mantissa_pipe2` = 0.75 (shifted smaller mantissa)
`L1_mantissa_pipe2` = 1.25 (larger mantissa)

##### Stage 3
Compare shifted mantissas: 0.75 (small) < 1.25 (large), so order remains
###### Pipeline registers after Stage 3:
`S_mantissa` = 0.75
`L_mantissa` = 1.25

##### Stage 4
Since both signs are 0 (same), perform addition:
`Add_mant` = 0.75 + 1.25 = 2.0
Count leading zeros (not needed here)
The result mantissa is now 2.0 (which is larger than 1.0, so it’s not normalized according to IEEE 754)

##### Stage 5
Because mantissa > 1 (2.0), shift right and increase exponent by 1:
Normalized mantissa = 1.0
Exponent = `r` + 1 = 1 + 1 = 2
Final sign = 0 (both inputs positive)
Compose final floating-point number: sign=0, exponent=2, mantissa=0 
1.5 + 2.5 = 4.0


New (better) Example for Stage 4: Subtraction with Leading Zeros
Number1 = 5.0 (positive), Number2 = 3.0 (positive), mode = 1 (subtraction) 

Stage 3 output (ready for Stage 4):
`S_mantissa` = 0.6 (smaller mantissa, after alignment)
`L_mantissa` = 1.25 (larger mantissa, after alignment)
Signs:
`s1` = 0 (Number1 positive)
`s2` = 1 (Number2 sign inverted due to subtraction mode)

##### Stage 4
Subtract mantissas: 1.25 - 0.6 = 0.65
Leading Zero Counting:
In binary, 0.65 is roughly 0.1010 
The leading bit of mantissa should be 1 (normalized), but here, the leading 1 is not in the MSB position; it’s shifted right.
We need to count how many leading zeros before the first 1 in the result mantissa. (1)
This means we must shift the mantissa left by 1 bit in the next stage to normalize it.
Exponent from previous stage = r (max exponent of inputs)

###### Renormalization values from Stage 4:
`renorm_shift` = 1 (shift left by 1)
`renorm_exp` = -1 (decrement exponent by 1)

##### Stage 5
Shift mantissa left by the number of leading zeros found: Final Mantissa = `Add_mant`<<`renorm_shift` 
0.65 * 2 = 1.3 (shifting left by 1 bit doubles the mantissa)
Adjust exponent accordingly: Final Exponent=`r`+`renorm_exp`=`r−1`
Determine final sign:
Since mode = subtract and signs differ, final sign is taken from the larger magnitude input (in this case, Number1’s sign = 0)
Assemble the final IEEE-754 result
