#!/usr/bin/env python

import os, sys
import shutil
import argparse

import subprocess as sp

def rename_dirs(directory, in_pattern, out_pattern):

    for root, dirs, file in os.walk(directory, topdown=False):
        for dir in dirs:
            if dir == in_pattern:
                os.rename(os.path.join(root, in_pattern), os.path.join(root, out_pattern))

def main():
    comm_args = parse_args()

    numlevs = comm_args['levs']
    outdir = comm_args['output']

    currdir = os.path.dirname(os.path.realpath(__file__))

    print "Num levs: %d" % numlevs
    print "Current Directory: %s" % currdir
    print "Output Directory: %s" % outdir

    shutil.copytree(currdir, outdir, symlinks=True, 
            ignore=shutil.ignore_patterns('*.bash', '*.py', '.git*'))

    levdir = 'L'+str(numlevs)

    rename_dirs(outdir, 'scripts', levdir)

def parse_args():

    p = argparse.ArgumentParser(description="Utility to create new files for new number of levels")

    p.add_argument('-l','--levs', type=int, help="Number of levels", required=True)
    p.add_argument('-o','--output', type=str, help="Output directory", required=True)

    return vars(p.parse_args())

if __name__ == "__main__":
    main()


