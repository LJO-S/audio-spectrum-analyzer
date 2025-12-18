"""
This script generates the lookup-table values used in determining the linear fractional from a fixed-point log2 value.

Usage: simply run the script to generate data to expected location
"""

import math
from pathlib import Path
import os


def gen_frac_table(a_filename, a_frac_bits, a_lut_frac_bits):
    depth = 1 << a_frac_bits
    width = a_lut_frac_bits + 1
    lut = []

    a_filename.parent.mkdir(exist_ok=True, parents=True)
    with open(a_filename, "w") as f:
        for i in range(depth):
            # 1. Calculate fractional value (0 <= x < 1)
            x = i / depth

            # 2. Calculate the anti-log: 2^x
            #    Since (0 <= x < 1), the result is (1.0 <= 2^x < 2.0)
            val_linear = 2.0**x

            # 3. Convert to fixed-point
            val_fixed = int(round(val_linear * (2**a_lut_frac_bits)))

            # 4. Format as binary string
            binary_string = f"{val_fixed:0{width}b}"

            # Check for (unlikely) overflow
            if len(binary_string) > width:
                raise ValueError("Binary string was longer than allowed depth!")

            f.write(f"{binary_string}\n")


if __name__ == "__main__":
    root = Path(os.getcwd())
    FILE_NAME = root / "log2lin_frac_lut" / "log2lin_frac_lut.txt"
    FRAC_BITS = 3
    LUT_FRAC_BITS = 16
    gen_frac_table(
        a_filename=FILE_NAME, a_frac_bits=FRAC_BITS, a_lut_frac_bits=LUT_FRAC_BITS
    )
