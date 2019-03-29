In order to make a new SC file, there are a couple steps.

First, you must run the model to get a file like L91/91-layer.p that has
the bits from a model run that look like:

```
$ head L91/91-layer.p
   k       A(k)       B(k)       Pref        DelP
 ----   ----------  --------  ----------  ---------
      1    0.000000    0.0000      0.0000
      2    0.020000    0.0000      0.0200     0.0200
      3    0.039808    0.0000      0.0398     0.0198
      4    0.073872    0.0000      0.0739     0.0341
      5    0.129083    0.0000      0.1291     0.0552
      6    0.214136    0.0000      0.2141     0.0851
      7    0.339529    0.0000      0.3395     0.1254
      8    0.517466    0.0000      0.5175     0.1779
```
and put that in an L<number> directory.

Second, copy the rsf91.F90 file and change all the 91 to <number>.

Finally, run build.bash. Note at the moment it expects mpiifort.
