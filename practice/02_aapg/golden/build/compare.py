import argparse
import sys
import os

from ibex_log_to_trace_csv  import process_ibex_sim_log
from spike_log_to_trace_csv import process_spike_sim_log
from instr_trace_compare    import compare_trace_csv

parser = argparse.ArgumentParser()

parser.add_argument('--iss_log', required=True)
parser.add_argument('--rtl_log', required=True)
parser.add_argument('--out',     required=True)

args = parser.parse_args()

rtl_csv = os.path.splitext(args.rtl_log)[0] + ".csv"
iss_csv = os.path.splitext(args.iss_log)[0] + ".csv"

process_ibex_sim_log (args.rtl_log, rtl_csv, 1)
process_spike_sim_log(args.iss_log, iss_csv, 1)

compare_result = compare_trace_csv(rtl_csv, iss_csv, "DUT", "ISS", args.out)

print(compare_result)
