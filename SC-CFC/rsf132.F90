PROGRAM rsf132

! --------------------------------------------------------
!
! Radiative source function and O2 Js for 132 layers.
!
! WARNING: Original binary files are 72 layers and 
! oriented bottom-up.
!
! Notes:
!
! SUBROUTINE interp requires the abscissas be
! monotonically increasing.
! L132 pressures 1 (995.367) is > L72 pressure 1 (992.5000).
!
! --------------------------------------------------------

 IMPLICIT NONE

INCLUDE 'netcdf.inc'

 INTEGER, PARAMETER :: nsza=20, numO3=12, nlam=79, km=72
 INTEGER, PARAMETER :: nts=200, nx=40, nxdo=38
 INTEGER :: i, j, k, l, m, n
 INTEGER :: szadim, szaid, levdim, levid, oo3dim, oo3id, lamdim, lamid
 INTEGER :: tdim, tid, xdim, xid, cdim, cid, aqdim, aqid
 INTEGER :: unit, status, fid

 REAL :: r, s
 REAL(KIND=4), ALLOCATABLE :: pr_tab(:)
 REAL(KIND=4), ALLOCATABLE :: rlam(:)
 REAL(KIND=4), ALLOCATABLE :: sza_tab(:)
 REAL(KIND=4), ALLOCATABLE :: o3_tab(:,:)

 REAL, ALLOCATABLE :: levs(:)
 REAL(KIND=4), ALLOCATABLE :: sdat(:,:,:,:)
 REAL(KIND=4), ALLOCATABLE :: o2jdat(:,:,:)
 REAL(KIND=4), ALLOCATABLE :: dxtab(:,:,:)
 REAL, ALLOCATABLE :: x1(:),x2(:,:),x3(:,:,:),x4(:,:,:,:),xo(:)

 INTEGER, PARAMETER :: km132 = 132
 REAL, ALLOCATABLE :: levs132(:)
 REAL, ALLOCATABLE :: levsr(:),levs132r(:)

 LOGICAL :: exists, found, opened

 CHARACTER(LEN=255) :: fileName, varName, longName
 CHARACTER(LEN=255) :: string
 CHARACTER(LEN=255) :: units
 CHARACTER(LEN=16) :: specieName(nxdo) = (/ &
 "BrONO2          ", &
 "BrO             ", &
 "Cl2O2           ", &
 "ClONO2          ", &
 "H2O2            ", &
 "HCl             ", &
 "HNO3            ", &
 "HO2NO2          ", &
 "HOCl            ", &
 "N2O5            ", &
 "NO2             ", &
 "NO3_NO          ", &
 "NO3_NO2         ", &
 "OClO            ", &
 "O2              ", &
 "O3_O1D          ", &
 "O3_3P           ", &
 "HOBr            ", &
 "CH3OOH          ", &
 "N2O             ", &
 "CH2O_HCO        ", &
 "CH2O_CO         ", &
 "CO2 -> CO + O   ", &
 "CFC-11          ", &
 "CFC-12          ", &
 "CCl4            ", &
 "CH3CCl3         ", &
 "HCFC-22         ", &
 "CFC-113         ", &
 "CH3Cl           ", &
 "CH3Br           ", &
 "H1301           ", &
 "H1211           ", &
 "CHBr3 	  ", &
 "CH2Br2	  ", &
 "CH2ClBr	  ", &
 "CHClBr2	  ", &
 "CHCl2Br	  " /)

! Find an available logical unit 
! ------------------------------
 found = .FALSE.
 i = 11

 DO WHILE (.NOT. found .AND. i <= 99)
  INQUIRE(UNIT=i, EXIST=exists, OPENED=opened)
  IF(exists .AND. .NOT. opened) THEN
   found = .TRUE.
   unit = i
  END IF
  i = i+1
  print *,i
 END DO

 IF(.NOT. found) THEN
  WRITE(*,FMT="(/,'No available logical units')")
  STOP
 ELSE
  WRITE(*,FMT="(' ','Reading from UNIT ',I3)") unit
 END IF

! 72-layer mean reference pressures (hPa)
! ---------------------------------------
 ALLOCATE(levs(km), STAT=status)
 fileName = "L72/72-layer.p"
 OPEN(UNIT=unit,FILE=TRIM(fileName),STATUS="old",FORM="formatted",ACTION="read")
 READ(UNIT,FMT="(A10)") string
 READ(UNIT,FMT="(A10)") string
 READ(UNIT,FMT="(30X,F9.4)") r
 DO k = 1,km
  READ(UNIT,FMT="(30X,F9.4)") s
  levs(km-k+1) = 0.50*(r+s)
  r = s
 END DO
 CLOSE(UNIT=unit)

! 132-layer mean reference pressures (hPa)
! ---------------------------------------
 ALLOCATE(levs132(km132), STAT=status)
 fileName = "L132/132-layer.p"
 OPEN(UNIT=unit,FILE=TRIM(fileName),STATUS="old",FORM="formatted",ACTION="read")
 READ(UNIT,FMT="(A10)") string
 READ(UNIT,FMT="(A10)") string
 READ(UNIT,FMT="(30X,F9.4)") r
 DO k = 1,km132
  READ(UNIT,FMT="(30X,F9.4)") s
  levs132(km132-k+1) = 0.50*(r+s)
  r = s
 END DO
 CLOSE(UNIT=unit)

! Set up for linear-in-ln p interpolation
! ---------------------------------------
 ALLOCATE(levsr(km), STAT=status)
 levsr(1:km) = ALOG(levs(km:1:-1))
 ALLOCATE(levs132r(km132), STAT=status)
 levs132r(1:km132) = ALOG(levs132(km132:1:-1))
 PRINT *,'----------- ALOG(levsr) ------------'
 PRINT *,levsr
 PRINT *,'---------- ALOG(levs132r) ----------'
 PRINT *,levs132r

 ALLOCATE(pr_tab(km), STAT=status)
 ALLOCATE(rlam(nlam), STAT=status)
 rlam(:) = 0.00
 ALLOCATE(sza_tab(nsza), STAT=status)
 sza_tab(:) = 0.00
 ALLOCATE(o3_tab(numo3,km), STAT=status)
 o3_tab(:,:) = 0.00
 fileName = "data/b72.SC.O3SZA"
 OPEN(UNIT=unit,FILE=TRIM(fileName),STATUS="old",FORM="unformatted",ACTION="read")
 READ(UNIT=unit) i, j, k, l
 READ(UNIT=unit) pr_tab
 READ(UNIT=unit) rlam
 READ(UNIT=unit) sza_tab
 READ(UNIT=unit) o3_tab
 PRINT *,"o3_tab: ",MINVAL(o3_tab),MAXVAL(o3_tab)
 CLOSE(UNIT=unit)

 ALLOCATE(sdat(nsza,numo3,km,nlam), STAT=status)
 sdat(:,:,:,:) = 0.00
 ALLOCATE(o2jdat(nsza,numo3,km), STAT=status)
 o2jdat(:,:,:) = 0.00
 fileName = "data/b72.SC.J.calc"
 OPEN(UNIT=unit,FILE=TRIM(fileName),STATUS="old",FORM="unformatted",ACTION="read")
 READ(UNIT=unit) sdat, o2jdat
 PRINT *,"Sdat: ",MINVAL(sdat),MAXVAL(sdat)
 PRINT *,"o2Jdat: ",MINVAL(o2jdat),MAXVAL(o2jdat)
 CLOSE(UNIT=unit)

! Create a NetCDF file
! --------------------
 fileName = "output/SC.J_20_12_79_132_200_38.nc4"
 PRINT *,"Creating ",TRIM(fileName)," ..."
 status = NF_CREATE(TRIM(fileName), IOR(NF_CLOBBER,NF_NETCDF4), fid)

 IF(status /= NF_NOERR) THEN
  PRINT *,'Error creating file ',status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

! Provide dimensions for SZA, overhead O3, levels, lambdas
! ---------------------------------------------------------
 status = NF_DEF_DIM(fid, 'nsza', nsza, szadim)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error defining zenith angle dimension: ',status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

 status = NF_DEF_DIM(fid, 'numO3', numO3, oo3dim)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error defining overhead O3 dimension: ',status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

 status = NF_DEF_DIM(fid, 'layers', km132, levdim)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error defining level dimension: ',status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

 status = NF_DEF_DIM(fid, 'nlam', nlam, lamdim)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error defining wavelength dimension: ',status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

 status = NF_DEF_DIM(fid, 'nts', nts, tdim)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error defining temperatures dimension: ',status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

 status = NF_DEF_DIM(fid, 'nxdo', nxdo, xdim)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error defining specie dimension: ',status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

 status = NF_DEF_DIM(fid, 'length', 16, cdim)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error defining character dimension: ',status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

 status = NF_DEF_DIM(fid, 'aqsize', 5, aqdim)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error defining lat dimension: ',status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 ENDIF

! Attributes
! ----------
 string = "Photolysis tables for StratChem JPL2010 including Br"
 i = LEN_TRIM(string)
 status = NF_PUT_ATT_TEXT(fid, NF_GLOBAL, "title", i, TRIM(string))

 string = "Dr. S. Randy Kawa, Atmospheric Chemistry and Dynamics, NASA GSFC"
 i = LEN_TRIM(string)
 status = NF_PUT_ATT_TEXT(fid, NF_GLOBAL, "source", i, TRIM(string)) 

 string = "stephan.r.kawa@nasa.gov"
 i = LEN_TRIM(string)
 status = NF_PUT_ATT_TEXT(fid, NF_GLOBAL, "contact", i, TRIM(string))

 string = "NetCDF version created on 2016-Dec-28 by jon.e.nielsen@nasa.gov SSAI/GMAO"
 i = LEN_TRIM(string)
 status = NF_PUT_ATT_TEXT(fid, NF_GLOBAL, "history", i, TRIM(string))

! Zenith angles
! -------------
 status = NF_DEF_VAR(fid, "sza", NF_FLOAT, 1, szadim, szaid)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error defining SZA variable ID: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

 string = "radians"
 i = LEN_TRIM(string)
 status = NF_PUT_ATT_TEXT(fid, szaid, "units", i, TRIM(string))
 string = "solar_zenith_angle"
 i = LEN_TRIM(string)
 status = NF_PUT_ATT_TEXT(fid, szaid, "long_name", i, TRIM(string))

 ALLOCATE(x1(nsza), STAT=status)
 x1(:) = sza_tab(:)*3.14159265/180.00

 status = NF_PUT_VAR(fid, szaid, x1)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error writing zenith angles: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF
 DEALLOCATE(x1)

! Levels
! ------
 status = NF_DEF_VAR(fid, "lev", NF_FLOAT, 1, levdim, levid)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error defining levels variable ID: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

 string = "hPa"
 i = LEN_TRIM(string)
 status = NF_PUT_ATT_TEXT(fid, levid, "units", i, TRIM(string))
 string = "pressure at layer midpoints"
 i = LEN_TRIM(string)
 status = NF_PUT_ATT_TEXT(fid, levid, "long_name", i, TRIM(string))
 string = "up"
 i = LEN_TRIM(string)
 status = NF_PUT_ATT_TEXT(fid, levid, "positive", i, TRIM(string))

 status = NF_PUT_VAR(fid, levid, levs132)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error writing levels: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

! Wavelengths
! -----------
 status = NF_DEF_VAR(fid, "lambda", NF_FLOAT, 1, lamdim, lamid)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error defining wavelength variable ID: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

 string = "angstroms"
 i = LEN_TRIM(string)
 status = NF_PUT_ATT_TEXT(fid, lamid, "units", i, TRIM(string))
 string = "wavelength"
 i = LEN_TRIM(string)
 status = NF_PUT_ATT_TEXT(fid, lamid, "long_name", i, TRIM(string))

 ALLOCATE(x1(nlam), STAT=status)
 x1(:) = rlam(:)

 status = NF_PUT_VAR(fid, lamid, x1)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error writing wavelengths: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF
 DEALLOCATE(x1)

! Temperatures
! ------------
 status = NF_DEF_VAR(fid, "T", NF_FLOAT, 1, tdim, tid)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error defining temperature variable ID: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

 string = "K"
 i = LEN_TRIM(string)
 status = NF_PUT_ATT_TEXT(fid, tid, "units", i, TRIM(string))
 string = "temperature"
 i = LEN_TRIM(string)
 status = NF_PUT_ATT_TEXT(fid, tid, "long_name", i, TRIM(string))

 ALLOCATE(x1(nts), STAT=status)
 DO n=1,nts
  x1(n) = 150.00+(n-1.00)
 END DO

 status = NF_PUT_VAR(fid, tid, x1)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error writing temperatures: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF
 DEALLOCATE(x1)

! Species list
! ------------
 status = NF_DEF_VAR(fid, "specie", NF_CHAR, 2, (/cdim,xdim/), n)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error defining specie variable ID: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

 string = "name"
 i = LEN_TRIM(string)
 status = NF_PUT_ATT_TEXT(fid, n, "content", i, TRIM(string))
 string = "species_table"
 i = LEN_TRIM(string)
 status = NF_PUT_ATT_TEXT(fid, n, "long_name", i, TRIM(string))

 status = NF_PUT_VAR(fid, n, specieName)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error writing names: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

! AQs quickly
! ------------------------
 ALLOCATE(x1(5), STAT=status)
 x1(1) = 557.95835182
 x1(2) = -7.31994058026
 x1(3) = 0.03553521598
 x1(4) = -7.54849718E-05
 x1(5) = 5.91001021E-08

 status = NF_DEF_VAR(fid, "CH2O_AQ", NF_FLOAT, 1, aqdim, aqid)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error defining AQ variable ID: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

 string = "unknown"
 i = LEN_TRIM(string)
 status = NF_PUT_ATT_TEXT(fid, aqid, "units", i, TRIM(string))
 string = "CH2O_quantum_yield_coeficients_JPL_2010"
 i = LEN_TRIM(string)
 status = NF_PUT_ATT_TEXT(fid, aqid, "long_name", i, TRIM(string))

 status = NF_PUT_VAR(fid, aqid, x1)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error writing CH2O AQs: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

 DEALLOCATE(x1)

! Data put
! --------
PRINT *,szadim,oo3dim,levdim,lamdim
PRINT *, nsza,numo3,km,km132,nlam

 varName = "O3TAB"
 longName = "overhead_ozone_interpolation_table"
 units = "cm-2"
 status = NF_DEF_VAR(fid, TRIM(varName), NF_FLOAT, 2, (/oo3dim,levdim/), n)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error defining o3_tab variable ID: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

 i = LEN_TRIM(varName)
 status = NF_PUT_ATT_TEXT(fid, n, "short_name", i, TRIM(varName))
 i = LEN_TRIM(longName)
 status = NF_PUT_ATT_TEXT(fid, n, "long_name", i, TRIM(longName))
 i = LEN_TRIM(units)
 status = NF_PUT_ATT_TEXT(fid, n, "units", i, TRIM(units))

 ALLOCATE(x2(numo3,km132), STAT=status)
 ALLOCATE(x1(km), STAT=status)
 ALLOCATE(xo(km132), STAT=status)
 
 DO m = 1,numo3
  x1(1:km) = o3_tab(m,km:1:-1)
  CALL interp(levsr,x1,km,levs132r,xo,km132)
  x2(m,1:km132) = xo(km132:1:-1)
  x2(m,1:3) = o3_tab(m,1)
  IF(m == numo3/3) THEN
   PRINT *,'---------- o3_tab ----------'
   PRINT *,o3_tab(m,1:km)
   PRINT *,'----------------------------'
   PRINT *,x2(m,1:km132)
  END IF
 END DO

 status = NF_PUT_VAR(fid, n, x2)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error writing o3_tab: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF
 DEALLOCATE(x2)
 DEALLOCATE(x1)
 DEALLOCATE(xo)

 varName = "SDAT"
 longName = "radiative_source_function"
 units = "dimensionless"
 status = NF_DEF_VAR(fid, TRIM(varName), NF_FLOAT, 4, (/szadim,oo3dim,levdim,lamdim/), n)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error defining radiative source function variable ID: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

 i = LEN_TRIM(varName)
 status = NF_PUT_ATT_TEXT(fid, n, "short_name", i, TRIM(varName))
 i = LEN_TRIM(longName)
 status = NF_PUT_ATT_TEXT(fid, n, "long_name", i, TRIM(longName))
 i = LEN_TRIM(units)
 status = NF_PUT_ATT_TEXT(fid, n, "units", i, TRIM(units))

 ALLOCATE(x4(nsza,numo3,km132,nlam), STAT=status)
 ALLOCATE(x1(km), STAT=status)
 ALLOCATE(xo(km132), STAT=status)

 DO l = 1,nlam
  DO m = 1,numo3
   DO j = 1,nsza
    x1(1:km) = sdat(j,m,km:1:-1,l)
    CALL interp(levsr,x1,km,levs132r,xo,km132)
    x4(j,m,1:km132,l) = xo(km132:1:-1)
    x4(j,m,1:3,l) = sdat(j,m,1,l)
    IF(m == numo3/3 .AND. j == nsza/3 .AND. l == nlam/3) THEN
     PRINT *,'----------  sdat  ----------'
     PRINT *,sdat(j,m,1:km,l)
     PRINT *,'----------------------------'
     PRINT *,x4(j,m,1:km132,l)
    END IF
   END DO
  END DO
 END DO

 status = NF_PUT_VAR(fid, n, x4)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error writing radiative source function: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF
 DEALLOCATE(x4)
 DEALLOCATE(x1)
 DEALLOCATE(xo)

 varName = "O2JDAT"
 longName = "photolysis_table_for_molecular_oxygen"
 units = "s-1"
 status = NF_DEF_VAR(fid, TRIM(varName), NF_FLOAT, 3, (/szadim,oo3dim,levdim/), n)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error defining O2 J ID: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

 i = LEN_TRIM(varName)
 status = NF_PUT_ATT_TEXT(fid, n, "short_name", i, TRIM(varName))
 i = LEN_TRIM(longName)
 status = NF_PUT_ATT_TEXT(fid, n, "long_name", i, TRIM(longName))
 i = LEN_TRIM(units)
 status = NF_PUT_ATT_TEXT(fid, n, "units", i, TRIM(units))

 ALLOCATE(x3(nsza,numo3,km132), STAT=status)
 ALLOCATE(x1(km), STAT=status)
 ALLOCATE(xo(km132), STAT=status)
 
 DO m = 1,numo3
  DO j = 1,nsza
   x1(1:km) = o2jdat(j,m,km:1:-1)
   CALL interp(levsr,x1,km,levs132r,xo,km132)
   x3(j,m,1:km132) = xo(km132:1:-1)
   x3(j,m,1:3) = o2jdat(j,m,1)
   IF(m == numo3/3 .AND. j == nsza/3) THEN
    PRINT *,'---------- o2jdat ----------'
    PRINT *,o2jdat(j,m,1:km)
    PRINT *,'----------------------------'
    PRINT *,x3(j,m,1:km132)
   END IF
  END DO
 END DO

 status = NF_PUT_VAR(fid, n, x3)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error writing O2 Js: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF
 DEALLOCATE(x3)
 DEALLOCATE(x1)
 DEALLOCATE(xo)

! Photolysis table
! ----------------
 ALLOCATE(dxtab(nlam,nts,nx), STAT=status)
 dxtab(:,:,:) = 0.00
 !fileName = "data/SC.X.35.79.JPL2006_ldo"
 fileName = "data/SC.X.40.79.JPL2010"
 OPEN(UNIT=unit,FILE=TRIM(fileName),STATUS="old",FORM="unformatted",ACTION="read")
 READ(UNIT=unit) dxtab
 PRINT *,"dxtab: ",MINVAL(dxtab),MAXVAL(dxtab)
 CLOSE(UNIT=unit)

 varName = "XTAB"
 longName = "cross_section_table"
 units = "s-1 interval-1"
 status = NF_DEF_VAR(fid, TRIM(varName), NF_FLOAT, 3, (/lamdim,xdim,tdim/), n)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error defining X ID: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF

 i = LEN_TRIM(varName)
 status = NF_PUT_ATT_TEXT(fid, n, "short_name", i, TRIM(varName))
 i = LEN_TRIM(longName)
 status = NF_PUT_ATT_TEXT(fid, n, "long_name", i, TRIM(longName))
 i = LEN_TRIM(units)
 status = NF_PUT_ATT_TEXT(fid, n, "units", i, TRIM(units))
 longName = "cross_section*quantum_yield*solar_flux_except_CH2O"
 i = LEN_TRIM(longName)
 status = NF_PUT_ATT_TEXT(fid, n, "content", i, TRIM(longName))
 
 ALLOCATE(x3(nlam,nxdo,nts), STAT=status)
 DO j = 1,nts
  DO m = 1,nxdo
   DO l = 1,nlam
    x3(l,m,j) = dxtab(l,j,m)
   END DO
  END DO
 END DO
 PRINT *,"xtab: ",MINVAL(x3),MAXVAL(x3)

 status = NF_PUT_VAR(fid, n, x3)
 IF(status /= NF_NOERR) THEN
  PRINT *,'Error writing Xs: ', status
  PRINT *, TRIM(NF_STRERROR(status))
  STOP
 END IF
 DEALLOCATE(x3)
 DEALLOCATE(dxtab)
 
 DEALLOCATE(levsr)
 DEALLOCATE(levs132r)
 DEALLOCATE(levs)
 DEALLOCATE(levs132)

 STOP
END PROGRAM rsf132

