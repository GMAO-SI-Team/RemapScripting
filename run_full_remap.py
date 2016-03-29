#!/usr/bin/env python

import os, sys
import shutil
import argparse

import subprocess as sp

def rename_dirs(directory, in_pattern, out_pattern):
    """
    This function takes a directory and will rename any
    subdirectories called 'in_pattern' to be named
    'out_pattern'
    """

    for root, dirs, files in os.walk(directory, topdown=False):
        for dir in dirs:
            if dir == in_pattern:
                os.rename(os.path.join(root, in_pattern), os.path.join(root, out_pattern))

def find_script(directory, scriptname):
    """
    This function takes a directory and finds executable 
    files that are in that directory and returns a list
    of files that match
    """

    scripts = []

    for root, dirs, files in os.walk(directory, topdown=False):
        for file in files:
            if file == scriptname:
                if os.access(os.path.join(root, file), os.X_OK):
                    scripts.append(os.path.join(root,file))

    return scripts

def execute_scripts(outdir, scripts, levels, scriptname, dryrun):
    """
    """

    for script in scripts:
        scriptdir = os.path.dirname(script)
        logfile = os.path.dirname(script) + os.sep + scriptname + '.log'
        spcmd = [script,'-levs',str(levels),'-outdir',scriptdir]

        print 'Executing: %s ' % script
        print 'Logfile: %s' % logfile

        if not dryrun:
            with open(logfile, 'w') as f:
                sp.call(spcmd, stdout=f)
            print 'Execution of %s complete' % scriptname

        print

def check_env():
    """
    Check of environment to make sure all is okay
    """

    assert(os.environ.has_key("ESMADIR")), 'ESMADIR not found in environment'

    esmadir = os.environ['ESMADIR']

    bindir = os.path.join(esmadir, 'Linux/bin')

    g5modfile = os.path.join(bindir, 'g5_modules')
    if not os.path.exists(g5modfile):
        raise Exception("g5_modules file not found in %s" % bindir)

    gfioremapfile = os.path.join(bindir, 'GFIO_remap.x')
    if not os.path.exists(gfioremapfile):
        raise Exception("GFIO_remap.x file not found in %s" % bindir)

    postdir = os.path.join(esmadir, 'src/GMAO_Shared/GEOS_Util/post')

    convertaerofile = os.path.join(postdir, 'convert_aerosols.x')
    if not os.path.exists(convertaerofile):
        raise Exception("convert_aerosols.x file not found in %s" % postdir)

def main():

    check_env()

    comm_args = parse_args()

    numlevs   = comm_args['levs']
    outdir    = comm_args['output']
    overwrite = comm_args['overwrite']
    dryrun    = comm_args['dryrun']

    currdir = os.path.dirname(os.path.realpath(__file__))

    print "Num levs: %d" % numlevs
    print "Current Directory: %s" % currdir
    print "Output Directory: %s" % outdir
    print

    levdir = 'L'+str(numlevs)

    if overwrite:
        if os.path.isdir(outdir):
            shutil.rmtree(outdir)

    # Copy the current directory tree to outdir,
    # ignoring any bash, py, or git files
    shutil.copytree(currdir, outdir, symlinks=True, 
            ignore=shutil.ignore_patterns('*.bash', '*.py', '.git*'))

    # Rename the scripts directorys to L<numlevs>
    rename_dirs(outdir, 'scripts', levdir)

    doremap_scripts = find_script(outdir, 'doremap')
    execute_scripts(outdir, doremap_scripts, numlevs, 'doremap', dryrun)

    remap_scripts = find_script(outdir, 'remap')
    execute_scripts(outdir, remap_scripts, numlevs, 'remap', dryrun)

    remap_gfed_scripts = find_script(outdir, 'remap_gfed')
    execute_scripts(outdir, remap_gfed_scripts, numlevs, 'remap_gfed', dryrun)

def parse_args():

    p = argparse.ArgumentParser(description="Utility to create new files for new number of levels")

    p.add_argument('-l','--levs', type=int, help="Number of levels", required=True)
    p.add_argument('-o','--output', type=str, help="Output directory", required=True)
    p.add_argument(     '--overwrite', help="Remove output directory", action='store_true')
    p.add_argument(     '--dryrun', help="Create the tree, but don't execute the scripts", action='store_true')

    return vars(p.parse_args())

if __name__ == "__main__":
    main()


