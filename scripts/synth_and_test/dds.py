import numpy as np
from pathlib import Path
from bitstring import BitArray

from scripts.synth_and_test.utils import (
    format_as_bstring,
    compare_value,
)
from ..models.dds.dds import dds


class dds_checker:
    def __init__(self, a_cfg: dict):
        self.dds_object = dds(
            a_amp_width=16,
            a_data_width=a_cfg["G_DATA_WIDTH"],
            a_lut_addr_width=a_cfg["G_LUT_ADDR_WIDTH"],
            a_clk_freq=a_cfg["G_SYS_CLK_HZ"],
            a_accumulator_width=a_cfg["G_ACCUMULATOR_WIDTH"],
        )

    def pre_config_wrapper(self, a_freq_list: list, a_cfg: dict):
        def pre_config(output_path) -> bool:

            # 1. Dump LUT values to text
            self.dds_object.dump_to_text(a_output_dir=Path(output_path))

            # 2. Generate input freqs & Dump to text
            input_path: Path = Path(output_path) / "input_freqs.txt"
            input_path.parent.mkdir(exist_ok=True, parents=True)
            with open(input_path, "w") as f:
                for freq in a_freq_list:
                    # 1. Convert to signed value
                    input_fixed = int(round(freq))

                    # 2. Format as binary string
                    input_fixed_bstring = format_as_bstring(
                        a_val_fixed=input_fixed, a_data_width=a_cfg["G_FREQ_WIDTH"]
                    )

                    # 3. Write data
                    f.write(f"{input_fixed_bstring}\n")
            return True

        return pre_config

    def post_check_wrapper(self, a_freq_list: list, a_cfg: dict, a_save_plot: bool):
        def post_check(output_path: str):

            checker = True

            # 0. Loop for data output entries:
            input_data_path: Path = Path(output_path) / "input_freqs.txt"

            plt_output_i = list()
            plt_output_q = list()
            plt_reference_i = list()
            plt_reference_q = list()

            for i, freq in enumerate(a_freq_list):
                output_data_path: Path = Path(output_path) / f"output_data_{i}.txt"
                with open(output_data_path, "r") as f_out:

                    # 1. Configure DDS
                    self.dds_object.configure(a_freq=freq)

                    for rd_idx, line in enumerate(f_out):
                        #  2. Fetch output
                        output_data_i, output_data_q = line.split()
                        output_data_i_f = BitArray(bin=output_data_i).int
                        output_data_q_f = BitArray(bin=output_data_q).int

                        # 3. Generate new reference data
                        ref_data_i, ref_data_q = self.dds_object.tick()
                        print(
                            f"New reference I=", ref_data_i, " & Q=", ref_data_q, "\n"
                        )

                        # Compare I data
                        comparison_i = compare_value(
                            a_actual=output_data_i_f,
                            a_reference=ref_data_i,
                        )
                        # Compare Q data
                        comparison_q = compare_value(
                            a_actual=output_data_q_f,
                            a_reference=ref_data_q,
                        )
                        plt_output_i.append(output_data_i_f)
                        plt_output_q.append(output_data_q_f)
                        plt_reference_i.append(ref_data_i)
                        plt_reference_q.append(ref_data_q)

                        # 4. Compare to data output entry
                        print()
                        print("i=", rd_idx, " & freq=", freq)
                        print()
                        print()
                        print("output I=", output_data_i_f, "\t\tQ=", output_data_q_f)
                        print("output I=", ref_data_i, "\t\tQ=", ref_data_q)
                        print()
                        print()
                        print("=====================================================")
                        checker = checker and comparison_i and comparison_q

            # Plot
            # TODO create plotter in /utils/
            return checker

        return post_check


if __name__ == "__main__":
    print("Hello world!")
