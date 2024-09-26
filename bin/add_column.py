#!/usr/bin/env python

import sys
import argparse
from pandas import read_csv


def parse_args(args=None):
    Description = "Add gene ID column to annotation results"
    Epilog = (
        "Example usage: python add_column.py <FILE_IN> <GENE> <FILE_OUT>"
    )

    parser = argparse.ArgumentParser(description=Description, epilog=Epilog)
    parser.add_argument("FILE_IN", help="Input alignment file.")
    parser.add_argument("GENE", help="Gene name")
    parser.add_argument("FILE_OUT", help="Output file.")
    return parser.parse_args(args)


def add_column(file_in, genome, file_out):
    ann_df = read_csv(file_in)

    # Add genome_id column
    ann_df["gene"] = genome

    ann_df.to_csv(file_out, index=False)


def main(args=None):
    args = parse_args(args)
    add_column(args.FILE_IN, args.GENE, args.FILE_OUT)


if __name__ == "__main__":
    sys.exit(main())
