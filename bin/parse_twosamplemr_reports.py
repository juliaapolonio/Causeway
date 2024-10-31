#!/usr/bin/env python

import sys
import re
import argparse
import pandas as pd
from io import StringIO

def parse_args(args=None):
    Description = "Parse TwoSampleMR reports and write metrics table to a CSV file."
    Epilog = "Example usage: python parse_twosamplemr_reports.py <REPORT>"

    parser = argparse.ArgumentParser(description=Description, epilog=Epilog)
    parser.add_argument("REPORT", help="TwoSampleMR Markdown Report")
    return parser.parse_args(args)


def parse_twosamplemr_reports(report):
    
    prefix = re.search(r"TwoSampleMR\.([A-Z0-9]+)GSMRtxt_against_.*", report).group(1)
    metrics_table = []
    pleiotropy_table = []
    steiger_table = []
    hetero_table = []

    with open(report) as rep_file:
        lines = rep_file.readlines()
        for line in lines[15:21]:
            if line.startswith('|'):
                metrics_table.append(line)
        table = (
            pd.read_csv(
                StringIO("".join(metrics_table)),
                sep="|",
                header=0,
                index_col=1,
                skipinitialspace=True,
            )
            .dropna(axis=1, how="all")
            .iloc[1:]
        )


        table.to_csv(f"{prefix}_metrics.csv")
        
        for index,line in enumerate(lines):
            if line.startswith('| egger'):
                pleiotropy_table.append(line)
                index_egger = index
                pleiotropy_table.append(lines[index_egger+1])
                pleiotropy_table.append(lines[index_egger+2])
                pleiotropy_table.append(lines[index_egger+3])

        pl_table = (
            pd.read_csv(
                StringIO("".join(pleiotropy_table)),
                sep="|",
                header=0,
                index_col=1,
                skipinitialspace=True,
            )
            .dropna(axis=1, how="all")
            .iloc[1:]
        )
        pl_table.to_csv(f"{prefix}_pleiotropy.csv")
        for index,line in enumerate(lines):
            if line.startswith('| snp'):
                steiger_table.append(line)
                index_egger = index
                steiger_table.append(lines[index_egger+1])
                steiger_table.append(lines[index_egger+2])
                steiger_table.append(lines[index_egger+3])

        st_table = (
            pd.read_csv(
                StringIO("".join(steiger_table)),
                sep="|",
                header=0,
                index_col=1,
                skipinitialspace=True,
            )
            .dropna(axis=1, how="all")
            .iloc[1:]
        )

        st_table.to_csv(f"{prefix}_steiger.csv") 

        for index,line in enumerate(lines):
            if re.match('### Heterogeneity', line):
                index_egger = index
                hetero_table.append(lines[index_egger+3])
                hetero_table.append(lines[index_egger+4])
                hetero_table.append(lines[index_egger+5])
                hetero_table.append(lines[index_egger+6])

        het_table = (
            pd.read_csv(
                StringIO("".join(hetero_table)),
                sep="|",
                header=0,
                index_col=1,
                skipinitialspace=True,
            )
            .dropna(axis=1, how="all")
            .iloc[1:]
        )

        het_table.to_csv(f"{prefix}_heterogeneity.csv")

def main(args=None):
    args = parse_args(args)
    parse_twosamplemr_reports(args.REPORT)


if __name__ == "__main__":
    sys.exit(main())
