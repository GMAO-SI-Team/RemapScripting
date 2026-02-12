## Steps to regrid just ACCMIP

### Clone repo
```
git clone git@github.com:GMAO-SI-Team/RemapScripting.git
```

### Do Remapping

The remapping script is in the `fvInput/AeroCom/scripts` directory as `doremap`.

#### Define BINDIR

The environment needs to have `BINDIR` defined a la:

```console
$ export BINDIR=/discover/nobackup/mathomp4/SystemTests/builds/AGCM/CURRENT/GEOSgcm/install-Release/bin
```

The scripts might only work with the Git GEOS now...unsure.

#### Edit the script

By default the script will run *all* the cases for that directory. Here, we only
need ACCMIP and it only needs the 144x91 PSDELP files and we only need 2020 and onward:
```diff
diff --git a/fvInput/AeroCom/scripts/doremap b/fvInput/AeroCom/scripts/doremap
index 0187456..ee2bb47 100755
--- a/fvInput/AeroCom/scripts/doremap
+++ b/fvInput/AeroCom/scripts/doremap
@@ -64,7 +64,7 @@ if ( ! -x $BINDIR/GFIO_remap.x ) then
    exit 1
 endif

-set TYPE_TABLE = ( AeroCom.aircraft_fuel A2_ACCMIP gmi_oh_ch4 GMI.vmr )
+set TYPE_TABLE = ( A2_ACCMIP )

 set indir = "/discover/nobackup/projects/gmao/share/dasilva/fvInput/fvInput_nc3/PIESA/L72"

@@ -76,7 +76,7 @@ cd $outdir
 # Copy input ps_delp files for safety
 # -----------------------------------

-set RES_TYPES = ( x288_y181 x144_y091 )
+set RES_TYPES = ( x144_y091 )

 set input_psdir = $outdir/inputps
 mkdir -p $input_psdir
@@ -110,7 +110,7 @@ foreach TYPE ( `echo $TYPE_TABLE` )
       set TAGO = "x144_y91.t12"
    endif

-   foreach IFILE ( `find $indir -type f -iname "${TYPE}*"` )
+   foreach IFILE ( `find $indir -type f -iname "${TYPE}*202*"` )
       set FILE = `basename $IFILE`
       set TAG1 = `echo $FILE | awk -F. '{print $1 }'`
       set TAG2 = `echo $FILE | awk -F. '{print $2 }'` ```
```

#### Run the script

Go to `fvInput/AeroCom/scripts`. There is a `doremap` script:
```console
$ ./doremap --help

usage: doremap -levs numlevels -outdir OUTDIR
```

```console
$ ./doremap -levs 181 -outdir /discover/nobackup/mathomp4/ACCMIP-2021/L181-2021Feb19
Remapping to 181 levels
Output will be saved to /discover/nobackup/mathomp4/ACCMIP-2021/L181-2021Feb19
BINDIR: /discover/nobackup/mathomp4/SystemTests/builds/AGCM/CURRENT/GEOSgcm/install-Release/bin
g5_modules: Setting BASEDIR and modules for discover35
...
'/discover/nobackup/projects/gmao/SIteam/Merra2_PSDELP_forRemap/PerMonth/merra2.aer_Nv.ps_delp.x144_y091.2003-2014.200801clm.nc4' -> '/discover/nobackup/mathomp4/ACCMIP-2021/L181-2021Feb19/inputps/merra2.aer_Nv.ps_delp.x144_y091.2003-2014.200801clm.nc4'
...
Running A2_ACCMIP...
...
```
