      SUBROUTINE ADRPRT (CASECC,PKF,SPLINE,SILA,USETA,FREQ,NFREQ,       
     1                   NCORE,NLOAD)        
C        
C     ADRPRT FORMATS PKF BY USER SET REQUEST FOR EACH FREQUENCY        
C        
      EXTERNAL        ANDF        
      INTEGER         CASECC,PKF,SPLINE,SILA,USETA,SYSBUF,OUT,NAM(2),   
     1                LSP(2),ANDF,SETNO,ALL,EXTID,TRL(7)        
      REAL            FREQ(1),Z(1),BUF(12),TSAVE(96)        
      COMMON /SYSTEM/ SYSBUF,OUT,DUM1(6),NLPP        
      COMMON /UNPAKX/ ITO,II,NN,INCR        
      COMMON /TWO   / ITWO(32)        
      COMMON /BITPOS/ IBIT(64)        
      COMMON /OUTPUT/ HEAD(96)        
CZZ   COMMON /ZZADRX/ IZ(1)        
      COMMON /ZZZZZZ/ IZ(1)        
      EQUIVALENCE     (Z(1),IZ(1))        
      DATA    IAERO / 176 /, LCS /200/        
      DATA    NHFSSU, NAM /  4HFSSU,4HADRP,4HRT  /        
      DATA    LSP   / 200,2/        
C        
C     CORE LAYOUT        
C       FREQ LIST          NFREQ        
C       SPLINE TRIPLETS    3*K POINTS        
C       SILS FOR K POINTS  1 PER K        
C       USET MASKS         6*K POINTS        
C       CASECC RECORD      TRL(4) LONG        
C       LOAD VECTOR        K SIZE        
C       BUFFERS            2 * SYSBUF        
C        
      MASK = IBIT(19)        
      MASK = ITWO(MASK)        
      DO 5 I = 1,96        
    5 TSAVE(I) = HEAD(I)        
      IBUF1 = NCORE - SYSBUF - 1        
      IBUF2 = IBUF1 - SYSBUF        
      IZSPL = NFREQ        
      NR = IBUF2 - IZSPL        
      CALL PRELOC (*1000,Z(IBUF1),SPLINE)        
      CALL LOCATE (*1000,Z(IBUF1),LSP,DUM)        
      CALL READ (*1000,*10,SPLINE,Z(IZSPL+1),NR,0,NWR)        
      GO TO 999        
   10 NSPL  = NWR        
      IZSIL = IZSPL + NWR        
      CALL CLOSE (SPLINE,1)        
C        
C     FIND SMALLEST SILGA POINTER (-1+NEXTRA = NSKIP ON SILA)        
C        
      ISMAL = 1000000        
      DO 20 I = 1,NSPL,3        
      ISMAL = MIN0(ISMAL,IZ(IZSPL+I+1))        
   20 CONTINUE        
      ISMAL = ISMAL - 1        
      TRL(1)= SILA        
      CALL RDTRL (TRL)        
      IF (TRL(1) .LT. 0) GO TO 1000        
      NEXTRA = TRL(3)        
      CALL GOPEN (SILA,Z(IBUF1),0)        
      NSKIP = ISMAL + NEXTRA        
      NR = IBUF2 - IZSIL        
      CALL READ (*1000,*1000,SILA,Z(IZSIL+1),-NSKIP,0,NWR)        
      CALL READ (*1000,*30,SILA,Z(IZSIL+1),NR,0,NWR)        
      GO TO 999        
   30 NSIL = NWR        
      CALL CLOSE (SILA,1)        
      IZUSET = IZSIL + NWR        
      NR = IBUF2 - IZUSET        
      NSKIP = IZ(IZSIL+1) -1        
      CALL OPEN (*1000,USETA,Z(IBUF1),0)        
      CALL FWDREC (*1000,USETA)        
      CALL READ (*1000,*1000,USETA,Z(IZUSET+1),-NSKIP,0,NWR)        
      CALL READ (*1000,*40,USETA,Z(IZUSET+1),NR,0,NWR)        
      GO TO 999        
   40 ICC = IZUSET + NWR        
      CALL CLOSE (USETA,1)        
C        
C     ADJUST SILA AND USET POINTERS FOR SHRUNKEN LISTS        
C        
      DO 50 I = 1,NSPL,3        
      IZ(IZSPL+I+1) = IZ(IZSPL+I+1) - ISMAL        
   50 CONTINUE        
      DO 60 I = 1,NSIL        
      IZ(IZSIL+I) = IZ(IZSIL+I) - NSKIP        
   60 CONTINUE        
      CALL BUG (NHFSSU,60,Z,ICC)        
      TRL(1) = CASECC        
      CALL RDTRL (TRL)        
      LCC = TRL(4) + 1        
      IZVECT = ICC + LCC        
      TRL(1) = PKF        
      CALL RDTRL (TRL)        
      ITO = 3        
      II  = 1        
      NN  = TRL(3)        
      INCR  = 1        
      NVECT = TRL(3)*2        
      IEND  = IZVECT + NVECT        
      IF (IEND .GT. IBUF2) GO TO 999        
      CALL OPEN (*1000,CASECC,Z(IBUF1),0)        
      CALL FWDREC (*1000,CASECC)        
      CALL OPEN (*1000,PKF,Z(IBUF2),0)        
      CALL FWDREC (*1000,PKF)        
C        
C     LOOP OVER NLOAD (CASECC RECORDS)        
C     THEN LOOP OVER NFREQ  (PKF COLUMNS)        
C     OUTPUT K POINTS FOR SET LIST        
C        
      DO 300 K = 1,NLOAD        
      CALL READ (*1000,*65,CASECC,Z(ICC+1),LCC,1,NWR)        
   65 SETNO = IZ(ICC+IAERO)        
      ALL = 0        
      DO 61 I = 1,96        
   61 HEAD(I) = Z(ICC+I+38)        
      IF(SETNO) 70,250,80        
   70 ALL = 1        
      GO TO 100        
   80 ISETNO = LCS + IZ(ICC+LCS) + 1 + ICC        
   90 ISET = ISETNO + 2        
      NSET = IZ(ISETNO+1) + ISET - 1        
      IF (IZ(ISETNO) .EQ. SETNO) GO TO 100        
      ISETNO = NSET +1        
      IF (ISETNO .LT. IZVECT) GO TO 90        
      ALL = 1        
  100 DO 240 J = 1,NFREQ        
      NLPPP = NLPP        
      CALL UNPACK (*110,PKF,Z(IZVECT+1))        
      GO TO 120        
  110 CALL ZEROC (Z(IZVECT+1),NVECT)        
C        
C     PRINT LOOP        
C        
  120 IF (ALL .EQ. 0) GO TO 150        
      ASSIGN 140 TO IRET        
      L = 1        
      GO TO 181        
  140 L = L + 3        
      IF (L .GE. NSPL) GO TO 240        
      GO TO 181        
  150 I = ISET        
  155 IF (I .EQ. NSET) GO TO 170        
      IF (IZ(I+1) .GT. 0) GO TO 170        
      ID = IZ(I  )        
      N  =-IZ(I+1)        
      I  = I+1        
      ASSIGN 160 TO IRET1        
      GO TO 180        
  160 ID = ID + 1        
      IF (ID .LE. N) GO TO 180        
      GO TO 175        
  170 ID = IZ(I)        
      ASSIGN 175 TO IRET1        
      GO TO 180        
  175 I = I + 1        
      IF (I .LE. NSET) GO TO 155        
      GO TO 240        
C        
C     LOCATE ELEMENT THEN  PRINT DATA        
C        
  180 ASSIGN 190 TO IRET        
      CALL BISLOC (*190,ID,IZ(IZSPL+1),3,NSPL/3,L)        
  181 EXTID = IZ(IZSPL+L)        
      IPSIL = IZ(IZSPL+L+1)        
      IROW  = IZ(IZSPL+L+2) *2 - 1 + IZVECT        
      IPUSET= IZ(IZSIL+IPSIL) + IZUSET - 1        
      GO TO 200        
  190 GO TO IRET1, (160,175)        
C        
C     PRINT        
C        
  200 IF (NLPPP .LT. NLPP) GO TO 210        
      CALL PAGE1        
      WRITE  (OUT,201) J,FREQ(J)        
  201 FORMAT (44X,42HAERODYNAMIC LOADS  (UNIT DYNAMIC PRESSURE),  /     
     1  30X,7HVECTOR ,I8,10X,12HFREQUENCY = ,1P,E14.6,7H  HERTZ,  /,    
     2  11H BOX OR    ,12X,7HT1 / R1,23X,7HT2 / R2,23X,7HT3 / R3, /,    
     3  11H BODY ELMT., 3(4X,4HREAL,10X,12HIMAGINARY   ))        
      NLPPP = 1        
  210 DO 220 M = 1,6        
      MM = M*2 - 1        
      BUF(MM  ) = 0.0        
      BUF(MM+1) = 0.0        
      IF (ANDF(IZ(IPUSET+M),MASK) .EQ. 0) GO TO 220        
      BUF(MM  ) = Z(IROW  )        
      BUF(MM+1) = Z(IROW+1)        
      IROW = IROW + 2        
  220 CONTINUE        
      WRITE  (OUT,221) EXTID,BUF        
  221 FORMAT (1H0,I10,6(1P,E15.6), /11X,6(1P,E15.6))        
      NLPPP = NLPPP + 3        
      GO TO IRET, (140,190)        
  240 CONTINUE        
  250 IF (K .EQ. NLOAD) GO TO 300        
      CALL REWIND (PKF)        
      CALL SKPREC (PKF,1)        
  300 CONTINUE        
C        
C     CLOSE UP AND RETURN        
C        
 1000 CALL CLOSE (CASECC,1)        
      CALL CLOSE (PKF,1)        
      CALL CLOSE (SILA,1)        
      CALL CLOSE (SPLINE,1)        
      DO 1001 I = 1,96        
 1001 HEAD(I) = TSAVE(I)        
      CALL PAGE2 (1)        
      RETURN        
C        
C     ERROR MESSAGES        
C        
  999 CALL MESAGE (8,0,NAM)        
      GO TO 1000        
      END        