      SUBROUTINE ANISOP        
C        
C     COMPUTES DIRECTION COSINES FOR RECTANGULAR COORD. SYSTEMS        
C     (W.R.T. BASIC COORD. SYSTEM) DESCRIBING ORIENTATION OF ANIS.      
C     MATERIAL FOR ISOPARAMETRIC SOLIDS        
C        
C     ANISOP  GEOM1,EPT,BGPDT,EQEXIN,MPT/MPTA/S,N,ISOP $        
C     EQUIV   MPTA,MPT/ISOP $        
C     ISOP=-1 MEANS SUCH MATERIALS EXIST        
C        
      INTEGER         GEOM1,EPT,BGPDT,FILE,BUF1,BUF2,EQEXIN        
      DIMENSION       IZ(1),NAM(2),IC1(2),IC2(2),IPI(2),IMAT6(2),       
     1                IDUM(31),A(3),B(3),C(3),XP(3),YP(3),ZP(3),        
     2                STORE(9),XD(9),ITRL(7),MAT1(2)        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /BLANK / ISOP        
      COMMON /SYSTEM/ IBUF,NOUT        
CZZ   COMMON /ZZANIS/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (Z(1),IZ(1))        
      DATA    GEOM1 , EPT,BGPDT,EQEXIN,MPT,MPTA /        
     1        101   , 102,103  ,104   ,105,201  /        
      DATA    IPI   / 7002,70/ ,IC1 / 1801,18   /, IC2 / 2101,21 /,     
     1        IMAT6 / 2503,25/ ,MAT1/  103, 1   /        
      DATA    NAM   / 4HANIS, 4HOP  /        
C        
      ISOP  = 1        
      LCORE = KORSZ(Z)        
      BUF1  = LCORE - IBUF - 1        
      BUF2  = BUF1  - IBUF        
      LCORE = BUF2 - 1        
      IF (LCORE .LE. 0) GO TO 1008        
C        
C     GET LIST OF MAT1 AND MAT6 ID-S        
C        
      NMAT1 = 0        
      NMAT6 = 0        
      I     = 0        
      CALL PRELOC (*1001,Z(BUF1),MPT)        
      CALL LOCATE (*2,Z(BUF1),MAT1,IDX)        
      FILE  = MPT        
    1 CALL READ (*1002,*2,MPT,IDUM,12,0,M)        
      NMAT1 = NMAT1 + 1        
      I = I + 1        
      IF (I .GT. LCORE) GO TO 1008        
      IZ(I) = IDUM(1)        
      GO TO 1        
C        
C     DONE WITH MAT1        
C        
    2 CALL LOCATE (*4,Z(BUF1),IMAT6,IDX)        
    3 CALL READ (*1002,*4,MPT,IDUM,31,0,M)        
      NMAT6 = NMAT6 + 1        
      I = I + 1        
      IF (I .GT. LCORE) GO TO 1008        
      IZ(I) = IDUM(1)        
      GO TO 3        
    4 CALL CLOSE (MPT,1)        
C        
C     LOCATE PIHEX CARDS ON EPT AND FORM A LIST OF MATERIAL COORD.      
C     SYSTEM ID        
C        
      CALL PRELOC (*310,Z(BUF1),EPT)        
      CALL LOCATE (*310,Z(BUF1),IPI,IDX)        
      FILE = EPT        
   10 CALL READ (*1002,*40,EPT,IDUM,7,0,M)        
C        
      ICID = IDUM(3)        
      MID  = IDUM(2)        
C        
C     IF CID = 0, MID MUST BE MAT1        
C     IF CID IS NOT 0, MID MUST BE MAT6        
C        
      IF (ICID  .GT. 0) GO TO 11        
      IF (NMAT1 .EQ. 0) GO TO 14        
      II = 1        
      NN = NMAT1        
      GO TO 12        
   11 IF (NMAT6 .EQ. 0) GO TO 14        
      II = NMAT1 + 1        
      NN = NMAT1 + NMAT6        
   12 DO 13 III = II,NN        
      IF (MID .EQ. IZ(III)) GO TO 1141        
   13 CONTINUE        
   14 WRITE  (NOUT,1140) UFM,MID        
 1140 FORMAT (A23,', MATERIAL',I8,', SPECIFIED ON A PIHEX CARD, DOES ', 
     1       'NOT REFERENCE THE PROPER MATERIAL TYPE', /5X,        
     2       'CID = 0 MEANS MAT1, CID NOT 0 MEANS MAT6')        
      GO TO 115        
 1141 CONTINUE        
C        
C     STORE ALL CID,MID PAIRS WHERE CID IS NOT 0        
C        
      IF (ICID .EQ. 0) GO TO 10        
      I = I + 1        
      IZ(I) = ICID        
      I = I + 1        
      IZ(I) = MID        
      GO TO 10        
C        
C     LIST IS MADE. MOVE IT UP TO IZ(1)        
C        
   40 CALL CLOSE (EPT,1)        
      NCID = I - NMAT1 - NMAT6        
      IF (NCID .EQ. 0) RETURN        
C        
      DO 41 II = 1,NCID        
      JJ = NMAT1 + NMAT6 + II        
      IZ(II) = IZ(JJ)        
   41 CONTINUE        
C        
C     NOW MAKE A UNIQUE LIST OF CID-S        
C        
      IJK = NCID + 1        
      NUM = 1        
      IZ(IJK) = IZ(1)        
      IF (NCID .EQ. 2) GO TO 44        
      DO 43 II = 3,NCID,2        
      ICID = IZ(II)        
      DO 42 JJ = 1,NUM        
      NCJJ = NCID + JJ        
      IF (ICID .EQ. IZ(NCJJ)) GO TO 43        
   42 CONTINUE        
C        
C     UNIQUE - LIST IT        
C        
      IJK = IJK + 1        
      NUM = NUM + 1        
      IF (IJK .GT. LCORE) GO TO 1008        
      IZ(IJK) = ICID        
   43 CONTINUE        
C        
C     UNIQUE LIST IS MADE- CHECK AGAINST CORD1R AND CORD2R ID-S        
C        
   44 ICORD = NCID + NUM + 1        
C        
      NCORD1 = 0        
      NCORD2 = 0        
      FILE   = GEOM1        
      CALL PRELOC (*1001,Z(BUF1),GEOM1)        
      CALL LOCATE (*70,Z(BUF1),IC1,IDX)        
   45 IF (ICORD+12 .GT. LCORE) GO TO 1008        
      CALL READ (*1002,*70,GEOM1,Z(ICORD),6,0,M)        
C        
C     COMPARE AGAINST CIDS ON PIHEX-S        
C        
      DO 50 JJ = 1,NUM        
      J = NCID + JJ        
      IF (IZ(ICORD) .EQ. IZ(J)) GO TO 60        
   50 CONTINUE        
      GO TO 45        
C        
C     MATCH- RESERVE 13 WORDS SINCE THIS CORD1R WILL BE CONVERTED TO    
C     CORD2R TYPE ENTRY LATER        
C        
   60 IZ(J)  =-IZ(J)        
      NCORD1 = NCORD1 + 1        
      ICORD  = ICORD  + 13        
      IF (NCORD1 .EQ. NUM) GO TO 120        
      GO TO 45        
C        
C     TRY CORD2R        
C        
   70 CALL LOCATE (*100,Z(BUF1),IC2,IDX)        
   75 IF (ICORD+12 .GT. LCORE) GO TO 1008        
      CALL READ (*1002,*100,GEOM1,Z(ICORD),13,0,M)        
C        
C     COMPARE        
C        
      DO 80 JJ = 1,NUM        
      J = NCID + JJ        
      IF (IZ(ICORD) .EQ. IZ(J)) GO TO 90        
   80 CONTINUE        
      GO TO 75        
C        
C     MATCH ON CORD2R. CHECK FOR RID. MUST BE 0        
C        
   90 IF (IZ(ICORD+3) .NE. 0) GO TO 330        
C        
      IZ(J)  =-IZ(J)        
      NCORD2 = NCORD2 + 1        
      ICORD  = ICORD  + 13        
      IF (NCORD1+NCORD2 .EQ. NUM) GO TO 120        
      GO TO 75        
C        
C     EXHAUSTED CORD2R-S, BUT NOT ALL  CID-S ARE LOCATED        
C        
  100 DO 110 JJ = 1,NUM        
      J = NCID + JJ        
      IF (IZ(J) .LT. 0) GO TO 110        
      WRITE  (NOUT,105) UFM,IZ(J)        
  105 FORMAT (A23,', CID',I8,' ON A PIHEX CARD IS NOT DEFINED TO BE ',  
     1       'CORD1R OR CORD2R')        
  110 CONTINUE        
  115 CALL MESAGE (-61,0,NAM)        
C        
C        
C     MATCHING IS COMPLETE        
C        
  120 CALL CLOSE (GEOM1,1)        
C        
C     CID,MATID PAIRS ARE IN Z(1)-Z(NCID). UNIQUE CID LIST IS IN        
C     Z(NCID+1)-Z(NCID+NUM). THERE ARE NCORD1 CORD1R-S AND NCORD2       
C     CORD2R-S AT 13 WORDS EACH STARTING AT Z(NCID+NUM+1).        
C     NEXT AVAILABLE OPEN CORE IS AT Z(ICORD)        
C        
      DO 130 JJ = 1,NUM        
      J = NCID + JJ        
  130 IZ(J) =-IZ(J)        
C        
C     FOR CID-S ON CORD1R WE MUST OBTAIN THE BASIC COORDINATES OF EACH  
C     POINT FROM BGPDT. FIRST, THE EXTERNAL POINT NUMBERS ON CORD1R MUST
C     BE CONVERTED TO  INTERNAL.        
C        
      LCORE = LCORE - (ICORD-1)        
      IF (LCORE .LE. 0) GO TO 1008        
      MCORE  = LCORE        
      IBGPDT = ICORD        
      IF (NCORD1 .EQ. 0) GO TO 200        
      CALL GOPEN (BGPDT,Z(BUF1),0)        
      FILE = BGPDT        
      CALL READ (*1002,*140,BGPDT,Z(IBGPDT),LCORE,0,M)        
      GO TO 1008        
  140 CALL CLOSE (BGPDT,1)        
      IEQ   = IBGPDT + M        
      LCORE = LCORE  - M        
      CALL GOPEN (EQEXIN,Z(BUF1),0)        
      FILE = EQEXIN        
      CALL READ (*1002,*150,EQEXIN,Z(IEQ),LCORE,0,M)        
      GO TO 1008        
  150 CALL CLOSE (EQEXIN,1)        
      LCORE = LCORE - M        
C        
C     FOR EACH CORD1R ENTRY, FIND THE BASIC COORDINATES FOR EACH POINT  
C     AND FORM A CORD2R ENTRY BACK WHERE THE CORD1R IS STORED        
C        
      DO 190 J = 1,NCORD1        
      IPOINT = 13*(J-1) + NCID + NUM        
      ICID   = IZ(IPOINT+1)        
      DO 170 K = 1,3        
      ISUBK = IPOINT + 3 + K        
      K3 = 3*(K-1)        
      IGRID = IZ(ISUBK)        
      CALL BISLOC (*350,IGRID,Z(IEQ),2,M/2,JP)        
C        
C     IM IS POINTER TO INTERNAL NUMBER. NOW FIND BGPDT ENTRY        
C        
      IM = IEQ + JP        
      IP = 4*(IZ(IM)-1)        
      DO 160 L = 1,3        
      ISUBB = IBGPDT + IP + L        
      ISUBL = K3 + L        
      STORE(ISUBL) = Z(ISUBB)        
  160 CONTINUE        
  170 CONTINUE        
C        
C     WE HAVE THE BASIC COORDINATES OF THE 3 POINTS. STORE IT BACK INTO 
C     THE CORD1R ENTRY. THE ENTRY STARTS AT Z(IPOINT+1)        
C        
      IP4 = IPOINT + 4        
      IZ(IP4) = 0        
      DO 180 L = 1,9        
      ISUBL = IP4 + L        
      Z(ISUBL) = STORE(L)        
  180 CONTINUE        
C        
C     GO BACK FOR ANOTHER CORD1R        
C        
  190 CONTINUE        
C        
C     FOR EACH COORDINATE SYSTEM, COMPUTE THE 9 DIRECTION COSINES FROM  
C     THE BASIC COORDINATE SYSTEM. Z(ICORD) IS THE NEXT AVAILABLE       
C     LOCATION OF OPEN CORE SINCE WE NO LONGER NEED EQEXIN OR BGPDT     
C     INFO.        
C        
  200 LCORE = MCORE        
      CALL GOPEN (MPT,Z(BUF1),0)        
      CALL GOPEN (MPTA,Z(BUF2),1)        
      IF (ICORD+30 .GT. LCORE) GO TO 1008        
C        
C     COPY MPT TO MPTA UNTIL MAT6 IS REACHED        
C        
      FILE = MPT        
  210 CALL READ (*280,*1003,MPT,Z(ICORD),3,0,M)        
      CALL WRITE (MPTA,Z(ICORD),3,0)        
      IF (IZ(ICORD) .EQ. IMAT6(1)) GO TO 240        
  220 CALL READ (*1002,*230,MPT,Z(ICORD),LCORE,0,M)        
      CALL WRITE (MPTA,Z(ICORD),LCORE,0)        
      GO TO 220        
  230 CALL WRITE (MPTA,Z(ICORD),M,1)        
      GO TO 210        
C        
C     MAT6 RECORD FOUND. EACH MAT6 CONTAINS 31 WORDS. INCREASE THAT     
C     TO 40        
C        
  240 CALL READ (*1002,*270,MPT,Z(ICORD),31,0,M)        
C        
C     SEE IF THIS ID MATCHES A CID ON PIHEX) IT NEED NOT        
C        
      DO 250 J = 2,NCID,2        
      IF (IZ(J) .EQ. IZ(ICORD)) GO TO 258        
  250 CONTINUE        
C        
C     NO MATCH. MAT6 NOT REFERENCED BY PIHEX. COPY IT TO MAT6 AND FILL  
C     IN ALL 3 DIRECTION COSINES. THIS MAT6 IS NOT REFERENCED BY PIHEX  
C        
      DO 255 K = 1,9        
  255 XD(K) = 0.        
      GO TO 265        
C        
C     MATCH. NOW FIND IT IN CORD1R,CORD2R LIST        
C        
  258 ICID = IZ(J-1)        
      DO 259 II = 1,NUM        
      IPOINT = NCID + NUM + 13*(II-1)        
      IF (ICID .EQ. IZ(IPOINT+1)) GO TO 260        
  259 CONTINUE        
C        
C     LOGIC ERROR        
C        
      GO TO 370        
C        
  260 IZ(IPOINT+1) = -IZ(IPOINT+1)        
      A(1) = Z(IPOINT+ 5)        
      A(2) = Z(IPOINT+ 6)        
      A(3) = Z(IPOINT+ 7)        
      B(1) = Z(IPOINT+ 8)        
      B(2) = Z(IPOINT+ 9)        
      B(3) = Z(IPOINT+10)        
      C(1) = Z(IPOINT+11)        
      C(2) = Z(IPOINT+12)        
      C(3) = Z(IPOINT+13)        
C        
C     ZP AXIS IS B-A. YP IS ZP X (C-A). XP IS YP X ZP        
C        
      ZP(1) = B(1) - A(1)        
      ZP(2) = B(2) - A(2)        
      ZP(3) = B(3) - A(3)        
      STORE(1) = C(1) - A(1)        
      STORE(2) = C(2) - A(2)        
      STORE(3) = C(3) - A(3)        
      YP(1) = ZP(2)*STORE(3) - ZP(3)*STORE(2)        
      YP(2) = ZP(3)*STORE(1) - ZP(1)*STORE(3)        
      YP(3) = ZP(1)*STORE(2) - ZP(2)*STORE(1)        
      XP(1) = YP(2)*ZP(3) - YP(3)*ZP(2)        
      XP(2) = YP(3)*ZP(1) - YP(1)*ZP(3)        
      XP(3) = YP(1)*ZP(2) - YP(2)*ZP(1)        
C        
C     NOW COMPUTE DIRECTION COSINES BETWEEN XP,YP, ZP AND BASIC X,Y,Z   
C     X=(1,0,0),Y=(0,1,0),Z=(0,0,1)        
C     COS(THETA)=(DP.D)/(LENGTH OF DP)*(LENGTH OF D) WHERE DP=XP,YP,OR  
C     ZP   AND D=X,Y,OR Z. LENGTH OF D=1        
C        
      DL    = SQRT(XP(1)**2 + XP(2)**2 + XP(3)**2)        
      XD(1) = XP(1)/DL        
      XD(2) = XP(2)/DL        
      XD(3) = XP(3)/DL        
      DL    = SQRT(YP(1)**2 + YP(2)**2 + YP(3)**2)        
      XD(4) = YP(1)/DL        
      XD(5) = YP(2)/DL        
      XD(6) = YP(3)/DL        
      DL    = SQRT(ZP(1)**2 + ZP(2)**2 + ZP(3)**2)        
      XD(7) = ZP(1)/DL        
      XD(8) = ZP(2)/DL        
      XD(9) = ZP(3)/DL        
C        
C     WRITE OUT NEW MAT6 RECORD WITH DIRECTION COSINES APPENDED        
C        
  265 CALL WRITE (MPTA,Z(ICORD),31,0)        
      CALL WRITE (MPTA,XD,9,0)        
C        
C     GET ANOTHER MAT6        
C        
      GO TO 240        
C        
C     MAT6 RECORD FINISHED. WRITE EOR, COPY REMAINDER OF MPT, AND CHECK 
C     TO SEE THAT ALL PIHEX CID-S HAVE BEEN ACCOUNTED FOR.        
C        
  270 CALL WRITE (MPTA,0,0,1)        
      GO TO 210        
C        
C     MPT EXHAUSTED        
C        
  280 CALL CLOSE (MPT,1)        
      CALL CLOSE (MPTA,1)        
      ITRL(1) = MPT        
      CALL RDTRL (ITRL)        
      ITRL(1) = MPTA        
      CALL WRTTRL (ITRL)        
      ISOP = -1        
  285 RETURN        
C        
  310 WRITE  (NOUT,320) UWM        
  320 FORMAT (A25,', EITHER EPT IS PURGED OR NO PIHEX CARDS FOUND ON ', 
     1       'EPT IN ANISOP')        
      GO TO 285        
  330 WRITE  (NOUT,340) UFM,IZ(J)        
  340 FORMAT (A23,', CORD2R',I8,' DEFINES A PIHEX CID BUT HAS NONZERO', 
     1       ' RID')        
      GO TO 115        
  350 WRITE  (NOUT,360) UFM,IGRID        
  360 FORMAT (A23,', EXTERNAL GRID',I8,' CANNOT BE FOUND ON EQEXIN IN ',
     1       'ANISOP')        
      GO TO 115        
  370 WRITE  (NOUT,380) UFM        
  380 FORMAT (A23,', NON-UNIQUE COORDINATE SYSTEMS ON PIHEX CARDS', /5X,
     1       '(SEE USER MANUAL P.2.4-233(05/30/86))')        
      GO TO 115        
C        
 1001 N = -1        
      GO TO 1010        
 1002 N = -2        
      GO TO 1010        
 1003 N = -3        
      GO TO 1010        
 1008 FILE = 0        
      N = -8        
 1010 CALL MESAGE (N,FILE,NAM)        
      RETURN        
      END        