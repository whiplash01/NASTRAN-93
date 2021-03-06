      SUBROUTINE FAILRS (FTHR,ULTSTN,STRESL,FINDEX)        
C        
C     THIS ROUTINE COMPUTES THE FAILURE INDEX OF A LAYER IN A LAMINATED 
C     COMPOSITE ELEMENT USING ONE OF THE FOLLOWING FIVE FAILURE THEORIES
C     CURRENTLY AVAILABLE        
C        1.   HILL        
C        2.   HOFFMAN        
C        3.   TSAI-WU        
C        4.   MAX STRESS        
C        5.   MAX STRAIN        
C        
C        
C     DEFINITIONS        
C        
C     XT = ULTIMATE UNIAXIAL TENSILE STRENGTH IN THE FIBER DIRECTION    
C     XC = ULTIMATE UNIAXIAL COMPRESSIVE STRENGTH IN THE FIBER DIRECTION
C     YT = ULTIMATE UNIAXIAL TENSILE STRENGTH PERPENDICULAR TO THE FIBER
C          DIRECTION        
C     YC = ULTIMATE UNIAXIAL COMPRESSIVE STRENGTH PERPENDICULAR TO THE  
C          FIBER DIRECTION        
C     S  = ULTIMATE PLANAR SHEAR STRENGTH UNDER PURE SHEAR LOADING      
C        
C     SIMILARILY FOR THE ULTIMATE STRAINS        
C        
C        
      INTEGER FTHR        
      REAL    ULTSTN(6),STRESL(3)        
C        
C        
C     CHECK FOR ZERO STRENGTH VALUES        
C        
      DO 50 I = 1,5        
   50 IF (ULTSTN(I) .EQ. 0.0) GO TO 700        
C        
C     ULTIMATE STRENGTH VALUES        
C        
      XT   = ULTSTN(1)        
      XC   = ULTSTN(2)        
      YT   = ULTSTN(3)        
      YC   = ULTSTN(4)        
      S    = ULTSTN(5)        
      F12  = ULTSTN(6)        
C        
C     LAYER STRESSES        
C        
      SIG1 = STRESL(1)        
      SIG2 = STRESL(2)        
      TAU12= STRESL(3)        
C        
C     LAYER STRAINS        
C        
      EPS1 = STRESL(1)        
      EPS2 = STRESL(2)        
      GAMA = STRESL(3)        
C        
      GO TO (100,200,300,400,500), FTHR        
C        
C     HILL FAILURE THEORY        
C     -------------------        
C        
  100 X = XT        
      IF (SIG1 .LT. 0.0) X = XC        
C        
      Y = YT        
      IF (SIG2 .LT. 0.0) Y = YC        
C        
      XX = XT        
      IF (SIG1*SIG2 .LT. 0.0) XX = XC        
C        
      FINDEX = (SIG1*SIG1)/(X*X)        
      FINDEX = FINDEX + (SIG2 * SIG2)/(Y * Y)        
      FINDEX = FINDEX - (SIG1 * SIG2)/(XX*XX)        
      FINDEX = FINDEX + (TAU12*TAU12)/(S * S)        
      GO TO 600        
C        
C        
C     HOFFMAN FAILURE THEORY        
C     ----------------------        
C        
  200 FINDEX = (1.0/XT-1.0/XC)*SIG1        
      FINDEX = FINDEX + (1.0/YT-1.0/YC)*SIG2        
      FINDEX = FINDEX + (SIG1 * SIG1)/(XT*XC)        
      FINDEX = FINDEX + (SIG2 * SIG2)/(YT*YC)        
      FINDEX = FINDEX + (TAU12*TAU12)/(S * S)        
      FINDEX = FINDEX + (SIG1 * SIG2)/(XT*XC)        
      GO TO 600        
C        
C        
C     TSAI-WU FAILURE THEORY        
C     ----------------------        
C        
C     CHECK STABILITY CRITERIA FOR THE INTERACTION TERM F12        
C        
  300 IF (F12 .EQ. 0.0) GO TO 350        
C        
      CRIT = (1.0/(XT*XC))*(1.0/(YT*YC)) - F12*F12        
      IF (CRIT .GT. 0.0) GO TO 350        
C        
C     IF STABILITY CRITERIA IS VIOLATED THEN SET THE F12 THE INTERACTION
C     TERM TO ZERO        
C        
      F12 = 0.0        
C        
C        
  350 FINDEX = (1.0/XT-1.0/XC)*SIG1        
      FINDEX = FINDEX + (1.0/YT-1.0/YC)*SIG2        
      FINDEX = FINDEX + (SIG1 * SIG1)/(XT*XC)        
      FINDEX = FINDEX + (SIG2 * SIG2)/(YT*YC)        
      FINDEX = FINDEX + (TAU12*TAU12)/(S * S)        
      IF (F12 .EQ. 0.0) GO TO 600        
      FINDEX = FINDEX + 2.0*F12*SIG1*SIG2        
      GO TO 600        
C        
C        
C     MAX STRESS FAILURE THEORY        
C     -------------------------        
C        
  400 FI1 = SIG1/XT        
      IF (SIG1 .LT. 0.0) FI1 = ABS(SIG1/XC)        
C        
      FI2 = SIG2/YT        
      IF (SIG2 .LT. 0.0) FI2 = ABS(SIG2/YC)        
C        
      FI12 = ABS(TAU12)/S        
C        
      FINDEX = FI1        
      IF (FI2  .GT. FINDEX) FINDEX = FI2        
      IF (FI12 .GT. FINDEX) FINDEX = FI12        
      GO TO 600        
C        
C        
C     MAX STRAIN FAILURE THEORY        
C     -------------------------        
C        
  500 FI1 = EPS1/XT        
      IF (EPS1 .LT. 0.0) FI1 = ABS(EPS1/XC)        
C        
      FI2 = EPS2/YT        
      IF (EPS2 .LT. 0.0) FI2 = ABS(EPS2/YC)        
C        
      FI12 = ABS(GAMA)/S        
C        
      FINDEX = FI1        
      IF (FI2  .GT. FINDEX) FINDEX = FI2        
      IF (FI12 .GT. FINDEX) FINDEX = FI12        
C        
  600 CONTINUE        
C        
      RETURN        
C        
C        
C     NON-FATAL ERROR        
C        
  700 FINDEX = 0.0        
      RETURN        
      END        
