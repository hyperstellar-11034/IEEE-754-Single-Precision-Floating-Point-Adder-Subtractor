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
