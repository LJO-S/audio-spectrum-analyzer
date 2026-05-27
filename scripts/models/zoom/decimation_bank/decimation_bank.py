import numpy as np
from .halfband_filter import Halfband_decimate_part


class Decimation_bank:
    """
    Python model of decimation_bank.vhd: 4 cascaded /2 halfband stages for I and Q,
    all always running, with a configurable output tap at /2, /4, /8, or /16.
    """

    def __init__(
        self,
        a_atten_db: float,
        a_fs: int,
        a_data_width: int = 16,
    ):
        self.atten_db = a_atten_db
        self.fs = a_fs
        self.data_width = a_data_width
        self.decimation_factor = 2

        self.stages_i = []
        self.stages_q = []
        fs_local = float(a_fs)
        for _ in range(4):
            fpass = (fs_local / 4) * 0.8
            fstop = fs_local / 2.0 - fpass
            if fstop <= fpass:
                raise ValueError(
                    f"Invalid filter design: fstop={fstop} <= fpass={fpass} at fs={fs_local}"
                )
            stage_kwargs = dict(
                a_fpass=fpass,
                a_fstop=fstop,
                a_atten_db=self.atten_db,
                a_fs=fs_local,
                a_data_width=self.data_width,
            )
            self.stages_i.append(Halfband_decimate_part(**stage_kwargs))
            self.stages_q.append(Halfband_decimate_part(**stage_kwargs))
            fs_local /= 2.0

    def configure(self, a_decimation_factor: int):
        assert a_decimation_factor in (
            2,
            4,
            8,
            16,
        ), f"Decimation factor must be 2, 4, 8, or 16 — got {a_decimation_factor}"
        self.decimation_factor = a_decimation_factor

    def tick(self, a_sample_i: float, a_sample_q: float):
        """
        Feed one I/Q sample. Returns (out_i, out_q) when the selected tap produces
        output, otherwise (None, None). Mirrors VHDL: all 4 stages always run,
        each stage only ticks when the previous stage produced a valid output.
        """
        tap_idx = int(np.log2(self.decimation_factor)) - 1

        out_i = [None] * 4
        out_q = [None] * 4

        out_i[0] = self.stages_i[0].tick(a_new_sample=a_sample_i)
        out_q[0] = self.stages_q[0].tick(a_new_sample=a_sample_q)

        for i in range(1, 4):
            if out_i[i - 1] is not None:
                out_i[i] = self.stages_i[i].tick(a_new_sample=out_i[i - 1])
                out_q[i] = self.stages_q[i].tick(a_new_sample=out_q[i - 1])

        return out_i[tap_idx], out_q[tap_idx]
