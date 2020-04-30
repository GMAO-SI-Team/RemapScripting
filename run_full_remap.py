#!/usr/bin/env python

import os, sys
import shutil
import argparse

import subprocess as sp

SHAREDIR = '/discover/nobackup/projects/gmao/share/gmao_ops'

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

def link_surface_dirs(directory, in_pattern):
    """
    This function takes a directory and will rename any
    subdirectories called 'in_pattern' to be named
    'out_pattern'
    """

    for root, dirs, files in os.walk(directory, topdown=False):
        for dir in dirs:
            if dir == in_pattern:
                #print root, dir
                # First, grab the end of the root where in_pattern exists
                #   /a/b/c/AeroCom/L132 ==> root = /a/b/c/AeroCom
                # Then:
                #      os.path.split(root)[1] = AeroCom

                emissionspath, emissionsdir = os.path.split(root)

                inputrootdir = os.path.split(emissionspath)[1]

                sfcdir = os.path.join(SHAREDIR,inputrootdir,emissionsdir,'sfc')
                xdir =   os.path.join(SHAREDIR,inputrootdir,emissionsdir,'x')

                os.symlink(sfcdir,os.path.join(root,'sfc'))
                os.symlink(  xdir,os.path.join(root,'x'))



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

    assert(os.environ.has_key("BINDIR")), 'BINDIR not found in environment, set so that $BINDIR/g5_modules exists'

    bindir = os.environ['BINDIR']

    g5modfile = os.path.join(bindir, 'g5_modules')
    if not os.path.exists(g5modfile):
        raise Exception("g5_modules file not found in %s" % bindir)

    gfioremapfile = os.path.join(bindir, 'GFIO_remap.x')
    if not os.path.exists(gfioremapfile):
        raise Exception("GFIO_remap.x file not found in %s" % bindir)

    convertaerofile = os.path.join(bindir, 'convert_aerosols.x')
    if not os.path.exists(convertaerofile):
        raise Exception("convert_aerosols.x file not found in %s" % bindir)

def print_advice(outdir):
    """
    Print a message on what to set in gcm_run.j
    """

    chmdirstr = "setenv CHMDIR   %s" % os.path.join(outdir,'fvInput')

    print "*" * 72
    print "*" * 72
    print "**" + " "*68+"**"
    print "**" + "In order to test these, in gcm_run.j, for CHMDIR use:".center(68)+"**"
    print "**" + " "*68+"**"
    print "**" + chmdirstr.center(68) + "**"
    print "**" + " "*68+"**"
    print "**" + "Also go into SC-CFC and make a new SC file there".center(68)+"**"
    print "**" + " "*68+"**"
    print "*" * 72
    print "*" * 72


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
    print "Share directory: %s" % SHAREDIR
    print

    levdir = 'L'+str(numlevs)

    if overwrite:
        if os.path.isdir(outdir):
            shutil.rmtree(outdir)

    # Copy the current directory tree to outdir,
    # ignoring any bash, py, or git files
    shutil.copytree(currdir, outdir, symlinks=True, 
            ignore=shutil.ignore_patterns('*.bash', '*.py', '.git*'))

    # Copytree keeps the access time of whatever was copied. This
    # command will essentially "touch" the directory
    os.utime(outdir, None)

    # Rename the scripts directorys to L<numlevs>
    rename_dirs(outdir, 'scripts', levdir)

    # Run the doremap script
    doremap_scripts = find_script(outdir, 'doremap')
    execute_scripts(outdir, doremap_scripts, numlevs, 'doremap', dryrun)

    # Run the remap script
    remap_scripts = find_script(outdir, 'remap')
    execute_scripts(outdir, remap_scripts, numlevs, 'remap', dryrun)

    # Run the remap_gfed script
    remap_gfed_scripts = find_script(outdir, 'remap_gfed')
    execute_scripts(outdir, remap_gfed_scripts, numlevs, 'remap_gfed', dryrun)

    # Create links to the sfc and x directories in SHAREDIR
    link_surface_dirs(outdir, levdir)

    # Create a link to the g5chem dir in the fvinput dir
    os.symlink( os.path.join(outdir,'fvInput_nc3','g5chem'), os.path.join(outdir,'fvInput','g5chem'))
    os.symlink( os.path.join(outdir,'fvInput_nc3','g5gcm'), os.path.join(outdir,'fvInput','g5gcm'))

    # Finally, print out a nice advice to users
    print_advice(outdir)

def parse_args():

    p = argparse.ArgumentParser(description="Utility to create new files for new number of levels")

    group1 = p.add_argument_group('required arguments')

    group1.add_argument('-l','--levs', type=int, help="Number of levels", required=True)
    group1.add_argument('-o','--output', type=str, help="Output directory", required=True)

    p.add_argument(     '--overwrite', help="Remove output directory", action='store_true')
    p.add_argument(     '--dryrun', help="Create the tree, but don't execute the scripts", action='store_true')

    return vars(p.parse_args())

if __name__ == "__main__":
    main()


