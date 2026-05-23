# ===================================================================
# Utilities
# ===================================================================
import math
import numpy as np
from matplotlib import pyplot as plt
from scipy.signal import freqz
from pathlib import Path


def generate_sine(a_frequency: float):
    pass


def format_as_bstring(a_val_fixed: int, a_data_width: int):

    if a_data_width <= 0:
        raise ValueError(f"Invalid width: {a_data_width}")

    # produce two's-complement bit pattern of 'width' bits
    mask = (1 << a_data_width) - 1
    val_masked = mask & a_val_fixed
    bstring = format(val_masked, f"0{a_data_width}b")

    if len(bstring) != a_data_width:
        raise ValueError(
            "Binary string was longer than allowed depth! Actual=",
            len(bstring),
            "vs Expected=",
            1 << a_data_width,
        )
    return bstring


def compare_value(a_actual, a_reference):
    if a_reference is not None:
        match = math.isclose(a=a_actual, b=a_reference, rel_tol=0.01, abs_tol=1e-3)
        diff_rel = abs(a_actual - a_reference) / (a_reference + 1e-9)
        if not match:
            print(
                f"Mismatch! Reference={a_reference} vs Actual={a_actual} <===> %diff={diff_rel}"
            )
            return False
        else:
            print(
                f"Pass!! Reference={a_reference} vs Actual={a_actual} <===> %diff={diff_rel}"
            )
    return True


def save_postcheck_plot_dds(
    a_output_data_i: list,
    a_output_data_q: list,
    a_ref_data_i: list,
    a_ref_data_q: list,
    a_save_plot: bool,
    a_output_path: str,
):
    # Input data
    fig = plt.figure()
    ax1 = fig.add_subplot(231)
    ax1.plot(a_output_data_i, label="output")
    ax1.plot(a_ref_data_i, label="ref")
    ax1.legend(loc="lower right")
    ax1.grid(True)
    ax1.set_title(f"In Phase")
    # Output & reference data
    ax2 = fig.add_subplot(234)
    ax2.plot(a_output_data_q, label="output")
    ax2.plot(a_ref_data_q, label="ref")
    ax2.legend(loc="lower right")
    ax2.grid(True)
    if a_save_plot:
        fig.set_size_inches(32, 18)
        plt.savefig(str(Path(a_output_path)) + "/" + f"results.svg", dpi=1000)
    else:
        plt.show()
