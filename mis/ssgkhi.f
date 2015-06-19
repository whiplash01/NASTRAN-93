      SUBROUTINE SSGKHI (TREAL,TINT,FN)        
C        
C     THIS SUBROUTINE COMPUTES THE (5X1) KHI  VECTOR FOR USE BY TRBSC,  
C                                           E        
C     TRPLT, AND QDPLT.        
C        
C     WHEN PROCESSING THE TRPLT OR QDPLT THIS ROUTINE SHOULD BE CALLED  
C     AFTER THE FIRST SUBTRIANGLE ONLY DUE TO THE D MATRIX ORIENTATION. 
C        
      INTEGER         TINT(6),INDEX(9)        
      REAL            TREAL(6),KHI        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SSGTRI/ D(9),KHI(5),KS(30),P(6)        
      COMMON /MATOUT/ DUM(7),ALPHA1,ALPHA2,ALPH12        
      COMMON /TRIMEX/ EID        
      COMMON /SYSTEM/ SYSBUF,IOUT        
C        
C     DETERMINE TYPE OF TEMPERATURE DATA        
C        
      IF (TINT(6) .NE. 1) GO TO 100        
C        
C     TEMPERATURE DATA IS TEMPP1 OR TEMPP3 TYPE.        
C        
      KHI(1) = -ALPHA1*TREAL(2)*FN        
      KHI(2) = -ALPHA2*TREAL(2)*FN        
      KHI(3) = -ALPH12*TREAL(2)*FN        
      GO TO 120        
C        
C     TEMPERATURE DATA IS TEMPP2 TYPE.        
C        
C     NO NEED TO COMPUTE DETERMINANT SINCE IT IS NOT USED SUBSEQUENTLY. 
C        
  100 ISING = -1        
      CALL INVERS (3,D(1),3,0,0,DETERM,ISING,INDEX)        
      IF (ISING .NE. 2) GO TO 110        
      WRITE  (IOUT,105) UFM,EID        
  105 FORMAT (A23,' 4018, A SINGULAR MATERIAL MATRIX -D- FOR ELEMENT',  
     1       I9,' HAS BEEN DETECTED BY ROUTINE SSGKHI', /26X,'WHILE ',  
     2       'TRYING TO COMPUTE THERMAL LOADS WITH TEMPP2 CARD DATA.')  
      CALL MESAGE (-61,0,0)        
  110 CALL GMMATS (D(1),3,3,0, TREAL(2),3,1,0, KHI(1))        
      KHI(1) = KHI(1)*FN        
      KHI(2) = KHI(2)*FN        
      KHI(3) = KHI(3)*FN        
  120 KHI(4) = 0.0        
      KHI(5) = 0.0        
      RETURN        
      END        