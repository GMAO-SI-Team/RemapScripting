      SUBROUTINE interp(xin,yin,n,xout,yout,m)
!----------------------------------------------------------------------
! Given a set of input coordinates, xin and yin, and a set of
! desired abscissa values, xout, which are not, in general,
! equal to xin, at which you want to know the corresponding
! ordinates, yout, this subroutine will do a third order polynomial
! fit while xout lies within the range of xin, and a linear
! extrtapolation if xout lies outside the range of xin.

! xin and yin have dimension n, xout and yout have dimension m.

! Originally written by Mark Schoeberl
!----------------------------------------------------------------------

      IMPLICIT NONE

      INTEGER, INTENT(IN) :: m,n
      REAL, INTENT(IN) :: xin(n),yin(n),xout(m)
      REAL, INTENT(OUT) :: yout(m)

      REAL :: q(4),r(4),s(3),t(2),e(3)
      REAL :: d

      INTEGER :: iflag,ir,j,k,ksave,l,ln,lq

      DO 90 j=1,m
       IF(xout(j) .GE. xin(n)) GO TO 70
       IF(xout(j) .LE. xin(1)) GO TO 80
       iflag=0

       DO 20 k=1,n
        IF(iflag .EQ. 1) GO TO 20
        IF(xout(j) .LE. xin(k)) iflag=1
        ksave=k
   20  CONTINUE

       lq=ksave-2
       IF(lq .LE. 1) lq=1
       ir=n-3
       IF(lq .GE. ir) lq=n-3

       DO 30 l=1,4
        ln=l+lq-1
        q(l)=xin(ln)
        r(l)=yin(ln)
   30  CONTINUE

       DO 40 l=1,3
        s(l)=(r(l+1)-r(l))/(q(l+1)-q(l))
   40  CONTINUE

       DO 50 l=1,2
        t(l)=(s(l+1)-s(l))/(q(l+2)-q(l))
   50  CONTINUE

       d=(t(2)-t(1))/(q(4)-q(1))
       DO 60 l=1,3
        e(l)=xout(j)-q(l)
   60  CONTINUE

       yout(j)=r(1)+s(1)*e(1)+t(1)*e(1)*e(2)+d*e(1)*e(2)*e(3)
       GO TO 90

   70  yout(j)=(yin(n)-yin(n-1))/(xin(n)-xin(n-1))*
     +         (xout(j)-xin(n-1))+yin(n-1)
       GO TO 90

   80  yout(j)=(yin(2)-yin(1))/(xin(2)-xin(1))*
     +         (xout(j)-xin(1))+yin(1)

   90 CONTINUE

      RETURN
      END SUBROUTINE interp
