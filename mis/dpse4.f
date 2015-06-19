      SUBROUTINE DPSE4        
C        
C     PRESSURE STIFFNESS CALCULATIONS FOR A QUADRILATERAL MEMBRANE      
C     ELEMENT, WHICH HAS 4 GRID POINTS.        
C     THREE 6X6 STIFFNESS MATRICES FOR THE PIVOT POINT ARE INSERTED.    
C        
C     DOUBLE PRECISION VERSION        
C        
C     WRITTEN BY E. R. CHRISTENSEN/SVERDRUP,  9/91,  VERSION 1.1        
C     INSTALLED IN NASTRAN AS ELEMENT DPSE4 BY G.CHAN/UNISYS, 2/92      
C
C     REFERENCE - E. CHRISTENEN: 'ADVACED SOLID ROCKET MOTOR (ASRM)
C                 MATH MODELS - PRESSURE STIFFNESS EFFECTS ANALYSIS',
C                 NASA TD 612-001-02, AUGUST 1991
C        
C     LIMITATION -        
C     (1) ALL GRID POINTS USED BY ANY OF THE CPSE2/3/4 ELEMENTS MUST BE 
C         IN BASIC COORDINATE SYSTEM!!!        
C     (2) CONSTANT PRESSURE APPLIED OVER AN ENCLOSED VOLUMN ENCOMPASSED 
C         BY THE CPSE2/3/4 ELEMENTRS        
C     (3) PRESSURE ACTS NORMALLY TO THE CPSE2/3/4 SURFACES        
C        
C     SEE NASTRAN DEMONSTRATION PROBLEM -  T13022A
C        
      DOUBLE PRECISION GAMMA,KIJ,DP,C,SIGN        
      DIMENSION        NECPT(6)        
C     COMMON /SYSTEM/  IBUF,NOUT        
      COMMON /DS1AAA/  NPVT,ICSTM,NCSTM        
      COMMON /DS1AET/  ECPT(26),DUM2(2),DUM12(12)        
      COMMON /DS1ADP/  GAMMA,KIJ(36),DP(26),C(12),SIGN(3),NK(3),IK(3)   
      EQUIVALENCE      (NECPT(1),ECPT(1))        
C        
C     ECPT FOR THE PRESSURE STIFFNESS CPES4 ELEMENT        
C        
C     ECPT( 1) = ELEMENT ID        
C     ECPT( 2) = SIL FOR GRID POINT A OR 1        
C     ECPT( 3) = SIL FOR GRID POINT B OR 2        
C     ECPT( 4) = SIL FOR GRID POINT C OR 3        
C     ECPT( 5) = SIL FOR GRID POINT C OR 4        
C     ECPT( 6) = PRESSURE        
C     ECPT( 7) = NOT USED        
C     ECPT( 8) = NOT USED        
C     ECPT( 9) = NOT USED        
C     ECPT(10) = COORD. SYSTEM ID 1        
C     ECPT(11) = X1        
C     ECPT(12) = Y1        
C     ECPT(13) = Z1        
C     ECPT(14) = COORD. SYSTEM ID 2        
C     ECPT(15) = X2        
C     ECPT(16) = Y2        
C     ECPT(17) = Z2        
C     ECPT(18) = COORD. SYSTEM ID 3        
C     ECPT(19) = X3        
C     ECPT(20) = Y3        
C     ECPT(21) = Z3        
C     ECPT(22) = COORD. SYSTEM ID 4        
C     ECPT(23) = X4        
C     ECPT(24) = Y4        
C     ECPT(25) = Z4        
C     ECPT(26) = ELEMENT TEMPERATURE        
C     ECPT(27) THRU ECPT(40) = DUM2 AND DUM12, NOT USED IN THIS ROUTINE 
C        
C     STORE ECPT IN DOUBLE PRECISION        
C        
      DP(6) = ECPT(6)        
      K = 10        
      DO 20 I = 1,4        
      DO 10 J = 1,3        
      K = K + 1        
   10 DP(K) = ECPT(K)        
   20 K = K + 1        
C        
C     CALCULATE THE FOUR VECTORS GAB, GAC, GAD, AND GBD USED IN        
C     COMPUTING THE PRESSURE STIFFNESS MATRIC        
C        
C     GAB = RA + RB - RC - RD        
C     GAC = RB - RD        
C     GAD =-RA + RB + RC - RD        
C     GBD =-RA + RC        
C        
C     GAB STORED IN C( 1), C( 2), C( 3)        
C     GAC STORED IN C( 4), C( 5), C( 6)        
C     GAD STORED IN C( 7), C( 8), C( 9)        
C     GBD STORED IN C(10), C(11), C(12)        
C        
      C(1) = DP(11) + DP(15) - DP(19) - DP(23)        
      C(2) = DP(12) + DP(16) - DP(20) - DP(24)        
      C(3) = DP(13) + DP(17) - DP(21) - DP(25)        
C        
      C(4) = DP(15) - DP(23)        
      C(5) = DP(16) - DP(24)        
      C(6) = DP(17) - DP(25)        
C        
      C(7) =-DP(11) + DP(15) + DP(19) - DP(23)        
      C(8) =-DP(12) + DP(16) + DP(20) - DP(24)        
      C(9) =-DP(13) + DP(17) + DP(21) - DP(25)        
C        
      C(10)=-DP(11) + DP(19)        
      C(11)=-DP(12) + DP(20)        
      C(12)=-DP(13) + DP(21)        
C        
      DO 30 I = 1,4        
      IF (NECPT(I+1) .NE. NPVT) GO TO 30        
      NPIVOT = I        
      GO TO 40        
   30 CONTINUE        
      RETURN        
C        
C     GENERATE THE THREE BY THREE PARTITIONS IN GLOBAL COORDINATES HERE 
C        
C     SET COUNTERS ACCORDING TO WHICH GRID POINT IS THE PIVOT        
C        
   40 IF (NPIVOT .EQ. 4) GO TO 80        
      IF (NPIVOT-2) 50,60,70        
C        
C     SET COUNTERS AND POINTERS FOR CALCULATING KAB, KAC, KAD        
C        
   50 NK(1) = 2        
      NK(2) = 3        
      NK(3) = 4        
      IK(1) = 1        
      IK(2) = 4        
      IK(3) = 7        
      SIGN(1) = 1.0D0        
      SIGN(2) = 1.0D0        
      SIGN(3) = 1.0D0        
      GO TO 90        
C        
C     SET COUNTERS AND POINTERS FOR CALCULATING KBA, KBC, KBD        
C     NOTE THAT KBA = -KAB        
C        
   60 NK(1) = 1        
      NK(2) = 3        
      NK(3) = 4        
      IK(1) = 1        
      IK(2) = 7        
      IK(3) = 10        
      SIGN(1) =-1.0D0        
      SIGN(2) = 1.0D0        
      SIGN(3) = 1.0D0        
      GO TO 90        
C        
C     SET COUNTERS AND POINTERS FOR CALCULATING KCA, KCB, KCD        
C     NOTE THAT KCA = -KAC, KCB = -KBC        
C        
   70 NK(1) = 1        
      NK(2) = 2        
      NK(3) = 4        
      IK(1) = 4        
      IK(2) = 7        
      IK(3) = 1        
      SIGN(1) =-1.0D0        
      SIGN(2) =-1.0D0        
      SIGN(3) =-1.0D0        
      GO TO 90        
C        
   80 NK(1) = 1        
      NK(2) = 2        
      NK(3) = 3        
      IK(1) = 7        
      IK(2) = 10        
      IK(3) = 1        
      SIGN(1) =-1.0D0        
      SIGN(2) =-1.0D0        
      SIGN(3) = 1.0D0        
C        
   90 GAMMA =-DP(6)/12.0D0        
      DO 110 I = 1,3        
      DO 100 J = 1,36        
  100 KIJ(J) = 0.0D0        
      K1 = IK(I)        
      K2 = K1 + 1        
      K3 = K1 + 2        
      SG = GAMMA*SIGN(I)        
      KIJ( 2) =-C(K3)*SG        
      KIJ( 3) = C(K2)*SG        
      KIJ( 7) = C(K3)*SG        
      KIJ( 9) =-C(K1)*SG        
      KIJ(13) =-C(K2)*SG        
      KIJ(14) = C(K1)*SG        
C        
C     ASSEMBLE INTO THE GLOBAL STIFFNESS MATRIX        
C        
      IAS = NK(I)        
      CALL DS1B (KIJ(1),NECPT(IAS+1))        
  110 CONTINUE        
C        
      RETURN        
      END        