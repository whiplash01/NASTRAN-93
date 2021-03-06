      SUBROUTINE INPTT5        
C        
C     DRIVER OF INPUTT5 MODULE        
C     THIS MODULE HANDLES BOTH TABLE AND MATRIX DATA BLOCKS     5/88    
C        
C     THIS IS A COMPANION MODULE TO OUTPUT5        
C        
C     ==== TABLE  ====        
C     CALLS TABLE-V ROUTINE TO COPY FROM A FORTRAN UNIT (FORMATTED OR   
C     BINARY TAPE) TABLE DATA TO NASTRAN GINO TABLE DATA BLOCKS        
C        
C     ==== MATRIX ====        
C     COPIES FROM A FORTRAN UNIT (BINARY OR FORMATTED TAPE) OF BANDED   
C     MATRICES ONTO NASTRAN GINO MATRIX DATA BLOCKS, IN GINO PACKED     
C     FORMAT        
C        
C     UNFORMATTED RECORDS CAN ONLY BE USED BY THE SAME COMPUTER SYSTEM, 
C     WHILE FORMATTED RECORDS CAN BE USED ACROSS COMPUTER BOUNDARY      
C     (E.G. WRITTEN BY CDC MACHINE AND READ BY IBM), AND ASLO, IT CAN   
C     BE EDITED BY SYSTEM EDITOR, OR PRINTED OUT BY SYSTEM PRINT COMMAND
C        
C     ******************************************************************
C     *                                                                *
C     *                       - IMPORTANT -                            *
C     *                                                                *
C     *  IF USER ASSEMBLES HIS OWN MATRIX IN INPUTT5 FORMAT, AND USES  *
C     *  INPUTT5 MODULE TO READ IT INTO NASTRAN, BE SURE THAT THE      *
C     *  DENSITY TERM (DENS) OF THE MATRIX TRAILER IS SET TO NON-ZERO  *
C     *  (NEED NOT BE EXACT) AND THE PRECISION TERM (TYPE) IS 1,2,3,   *
C     *  OR 4. OTHERWISE, HIS MATRIX WILL BE TREATED AS TABLE AND      *
C     *  EVERYTHING GOES HAYWIRE.                                      *
C     *                                                                *
C     ******************************************************************
C        
C     CALL TO THIS MODULE IS        
C        
C     INPUTT5  /O1,O2,O3,O4,O5/C,N,P1/C,N,P2/C,N,P3/C,N,P4 $        
C        
C              P1=+N, SKIP FORWARD N MATRIX DATA BLOCKS OR TABLES BEFORE
C                     COPYING (EXCEPT THE FIRST HEADER RECORD. EACH     
C                     MATRIX DATA BLOCK OR TABLE, PRECEEDED BY A HEADER 
C                     RECORD, IS A COMPLETE MATRIX OR TABLE, MADE UP OF 
C                     MANY PHYSICAL RECORDS.        
C                     SKIP TO THE END OF TAPE IF P1 EXCEEDS THE NO. OF  
C                     DATA BLOCKS AVAILABLE ON THE OUTPUT TAPE        
C                     NO REWIND BEFORE SKIPPING)        
C              P1= 0, NO ACTION TAKEN BEFORE COPYING. (DEFAULT)        
C                     HOWEVER, IF TAPE IS POSITIONED AT THE BEGINNING,  
C                     THE TAPE ID RECORD IS SKIPPED FIRST.        
C              P1=-1, INPUT TAPE IS REWOUND, AND TAPEID CHECKED. IF     
C                     OUTPUT GINO FILES ARE PRESENT, DATA FROM TAPE ARE 
C                     THEN COPIED TO GINO FILES - IN PACKED MATRIX FORM 
C                     IF MATRIX DATA, OR TABLE FORM IF TABLE DATA.      
C              P1=-3, TAPE IS REWOUND AND READ. THE NAMES OF ALL DATA   
C                     BLOCKS ON FORTRAN TAPE ARE PRINTED. AT END, TAPE  
C                     IS REWOUND AND POSITIONED AFTER TAPE HEADER RECORD
C                     (NOTE - SERVICE UP TO 15 FILE NAMES ON ONE INPUT  
C                     TAPE. AND THE 'AT END' TREATMENT IS NOT THE SAME  
C                     AS IN OUTPUT5)        
C              P1=-4  THRU -8 ARE NOT USED        
C              P1=-9, REWIND TAPE        
C        
C              P2  IS THE FORTRAN UNIT NO. ON WHICH THE DATA BLOCKS WILL
C                     WRITTEN.  DEFAULT IS 16 (INP2 FOR UNIVAC,IBM,VAX),
C                     OR 12 (UT2 FOR CDC)        
C        
C              P3  IS TAPE ID IF GIVEN BY USER. DEFAULT IS XXXXXXXX     
C        
C              P4=0, OUTPUT TAPE IS FORTRAN WRITTEN, UNFORMATTED RECORDS
C              P4=1, OUTPUT TAPE IS FORTRAN WRITTED, FORMATTED        
C                    BCD IN 2A4, INTEGER IN I8, S.P. REAL IN 10E13.6,   
C                    AND D.P. IN 5D26.17.        
C              P4=2, SAME AS P4=1, EXECPT FORMAT 5E26.17 IS USED FOR    
C                    S.P. REAL DATA. (THIS OPTION IS USED ONLY IN       
C                    MACHINES WITH 60 OR MORE BITS PER WORD)        
C        
C        
C     CONTENTS OF INPUT TAPE, AS WRITTEN BY OUTPUT5        
C                                                       (P4=0)   (P4=1) 
C     RECORD  WORD        CONTENTS                      BINARY   FORMAT 
C     ------  ----  --------------------------------   -------  ------- 
C        0            TAPE HEADER RECORD -        
C              1,2    TAPEID                             2*BCD      2A4 
C              3,4    MACHINE                            2*BCD      2A4 
C              5-7    DATE                               3*INT      3I8 
C               8     BUFFSIZE                             INT       I8 
C               9     0 (BINARY), OR 1 OR 2 (FORMATTED)    INT       I8 
C       1/2@          FIRST MATRIX HEADER RECORD -        
C               1     ZERO                                 INT       I8 
C              2,3    1,1                                2*INT      2I8 
C               1     DUMMY (D.P.)                        F.P.   D26.17 
C              2-7    MATRIX TRAILER                     6*INT      6I8 
C                     (COL,ROW,FORM,TYPE,MAX,DENS)        
C              8-9    MATRIX DMAP NAME                   2*BCD      2A4 
C       3/4     1     1 (FIRST COLUMN ID)                  INT       I8 
C               2     LOC. OF FIRST NON-ZERO ELEMENT, L1   INT       I8 
C               3     LOC. OF LAST  NON-ZERO ELEMENT, L2   INT       I8 
C              1-W    FIRST MATRIX COLUMN DATA            F.P.     (**) 
C                     (W=L2-L1+1)        
C       5/6     1     2 (SECOND COLUMN ID)                 INT       I8 
C              2-3    LOC. OF FIRST AND LAST NON-ZERO    2*INT      2I8 
C                     ELEMENTS        
C              1-W    SECOND MATRIX COLUMN DATA           F.P.     (**) 
C       7/8    1-3    THIRD MATRIX COLUMN, SAME FORMAT   3*INT      3I8 
C              1-W    AS RECORD 1                         F.P.     (**) 
C        :      :       :        
C       M/M+1  1-3    LAST MATRIX COLUMN, SAME FORMAT    3*INT      3I8 
C                     AS RECORD 1                         F.P.     (**) 
C     M+2/M+3  1-3    SECOND MATRIX HEADER RECORD        3*INT      3I8 
C               1     DUMMY                               F.P.     (**) 
C              2-7    MATRIX TRAILER                     6*INT      6I8 
C              8,9    MATRIX DMAP NAME                   2*BCD      2A4 
C     M+4-N     :     FIRST THRU LAST COLUMNS OF MATRIX  3*INT      3I8 
C                                                        +F.P.    +(**) 
C        :      :     REPEAT FOR 3RD,4TH,5TH MATRICES        
C        :      :     (UP TO 5 MATRIX DATA BLOCKS PER ONE OUTPUT TAPE)  
C        
C       EOF    1-3    -1,1,1                              3*INT     3I8 
C               1     ZEROS (D.P.)                         F.P.  D26.17 
C        
C     @  RECORDS 1/2 (3/4, 5/6, ETC) ARE TWO RECORDS IN THE FORMATTED   
C        TAPE, AND ARE PHYSICALLY ONE RECORD IN THE BINARY TAPE (AND    
C        THE WORD COUNT SHOULD BE ADDED)        
C     ** IS (10E13.6) FOR S.P.REAL OR (5D26.17) FOR D.P.DATA        
C        (5E26.17) FOR LONG WORD MACHINE        
C        
C                                                               - NOTE -
C                                                  BCD AND INTEGERS IN 8
C                                                     S.P. REAL IN  13.7
C                                                     D.P. DATA IN 26.17
C                                             LONG WORD MACHINE IN 26.17
C        
C     NO SYSTEM END-OF-FILE MARK WRITTEN BETWEEN MATRICES        
C     EXCEPT FOR THE TAPE HEADER RECORD, AND THE MATRIX HEADERS, THE    
C     ENTIRE FORMATTED INPUT TAPE CAN BE READ BY A STANDARD FORMAT      
C     (3I8,/,(10E13.6)), (3I8,/,(5D26.17)), OR (3I8,/,(5E26.17))        
C        
C     ALSO, USER MAY OR MAY NOT CALL OUTPUT5 WITH P1=-9 TO WRITE AN     
C     'OUPUT5 E-O-F' MARK ON TAPE. THIS CAUSED PROBLEM BEFORE.        
C        
C     THE PROCEDURE TO READ AND/OR WRITE THE TAPE IS COMMONLY USED      
C     AMONG INPUTT5, OUTPUT5, AND DUMOD5. ANY PROCEDURE CHANGE SHOULD   
C     BE MADE TO ALL THREE SUBROUTINES.        
C        
C     WRITTEN BY G.CHAN/UNISYS   1987        
C     MAJOR REVISED 12/1992 BY G.C.        
C        
      IMPLICIT INTEGER (A-Z)        
      LOGICAL          OPN,P40,P40S,P40D,P41,P41S,P41D,P41C,DEBUG       
      INTEGER          NAME(2),TAPEID(2),MAC(2),SUBNAM(2),DT(3),        
     1                 IZ(7),FN(3,15),BK        
      REAL             RZ,X        
      DOUBLE PRECISION DZ(7),DX        
      CHARACTER*8      BINARY,FORMTD,BF        
      CHARACTER        UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG /  UFM,UWM,UIM,SFM        
      COMMON /BLANK /  P1,P2,P3(2),P4        
      COMMON /INPUT5/  MCB(1),COL,ROW,FORM,TYPE,MAX,DENS        
      COMMON /MACHIN/  MACH        
      COMMON /SYSTEM/  IBUF,NOUT,NOGO,DUM36(36),NBPW        
CZZ   COMMON /ZZINP5/  RZ(1)        
      COMMON /ZZZZZZ/  RZ(1)        
      COMMON /PACKX /  TYPIN,TYPOUT,II,JJ,INCR        
      EQUIVALENCE      (RZ(1),IZ(1),DZ(1))        
      DATA    BINARY,  FORMTD,       SUBNAM,         FN,BK    /        
     1       'BINARY','FORMATTD',    4HINPT, 2HT5,   46*2H    /        
      DATA    MTRX,    TBLE,SKIP   / 4HMTRX, 4HTBLE, 4HSKIP   /        
      DATA    DEBUG /  .FALSE.     /        
C        
C     IF MACHINE IS CDC OR UNIVAC, CALL CDCOPN OR UNVOPN TO OPEN OUTPUT 
C     FILE, A SEQUENTIAL FORMATTED TAPE. NO CONTROL WORDS ARE TO BE     
C     ADDED TO EACH SEQUENTIAL RECORD. RECORD LENGTH IS 132 CHARACTERS, 
C     AN ANSI STANDARD.        
C        
      IF (MACH .EQ. 3) CALL UNVOPN (P2)        
      IF (MACH .EQ. 4) CALL CDCOPN (P2)        
      BF = BINARY        
      IF (P4 .GE. 1) BF = FORMTD        
      CALL PAGE1        
      WRITE  (NOUT,10) UIM,BF,P1        
   10 FORMAT (A29,', MODULE INPUTT5 CALLED BY USER DMAP ALTER, ON ',A8, 
     1        ' INPUT FILE,',/5X,'WITH THE FOLLOWING REQUEST.  (P1=',   
     2        I2,1H))        
      IF (P1 .EQ. -9) WRITE (NOUT,20)        
      IF (P1 .EQ. -3) WRITE (NOUT,30)        
      IF (P1 .EQ. -1) WRITE (NOUT,40)        
      IF (P1 .EQ.  0) WRITE (NOUT,50)        
      IF (P1 .GT.  0) WRITE (NOUT,60) P1        
   20 FORMAT (5X,'REWIND TAPE ONLY')        
   30 FORMAT (5X,'REWIND AND READ TAPE. PRINT ALL DATA BLOCK NAMES ON ',
     1       'TAPE. AT END, TAPE IS REWOUND', /5X,'AND POSITIONED ',    
     2       'PASS TAPE HEADER RECORD')        
   40 FORMAT (5X,'REWIND, POSITION PAST TAPE HEADER RECORD, THEN READ ',
     1       'TAPE. AT END, NO REWIND')        
   50 FORMAT (5X,'READ TAPE STARTING AT CURRENT POSITION, OR POSITION ',
     1       'PAST THE TAPE HEADER RECORD (FIRST USE OF TAPE).', /5X,   
     2       ' NO REWIND AT BEGINNING AND AT END')        
   60 FORMAT (5X,'SKIP FORWARD',I4,' DATA BLOCKS (NOT COUNTING TAPE ',  
     1       'HEADER RECORD) BEFORE READING, AT END NO REWIND')        
C        
      BUF1 = KORSZ(RZ(1)) - IBUF - 1        
      IF (BUF1 .LE. 0) CALL MESAGE (-8,0,SUBNAM)        
      INPUT= P2        
      OPN  = .FALSE.        
      LL   = 0        
      P41  =.FALSE.        
      IF (P4 .GE.  1) P41 =.TRUE.        
      P40  =.NOT.P41        
      P40S =.FALSE.        
      P41S =.FALSE.        
      P40D = P40        
      P41D = P41        
      P41C = P4.EQ.2 .AND. NBPW.GE.60        
      IF (P41C) P40D = .FALSE.        
      IF (P41C) P41D = .FALSE.        
      COL12= 0        
      P1N  = P1        
      IF (P1 .LT.  0) P1N = 0        
      IF (P1 .NE. -9) GO TO 70        
      REWIND INPUT        
      GO TO 1000        
C        
   70 DO 80 I = 1,15        
   80 FN(3,I) = BK        
      IF (P1.GE.-1 .OR. P1.EQ.-3 .OR. P1.EQ.-9) GO TO 200        
C        
      WRITE  (NOUT,90) UFM,P1        
   90 FORMAT (A23,', MODULE INPUTT5 - ILLEGAL VALUE FOR FIRST PARAMETER'
     1,      ' = ',I8, /5X,'ONLY -9, -3 AND GREATER THAN -1 ALLOWED')   
  100 ERR = -37        
  120 CALL MESAGE (ERR,OUTPUT,SUBNAM)        
      RETURN        
C        
  200 IF (P1 .EQ. 0) GO TO 500        
C        
C     CHECK TAPE ID        
C        
      REWIND INPUT        
      ERR = -1        
      IF (P40) READ (INPUT,    END=420) TAPEID,MAC,DT,I,K        
      IF (P41) READ (INPUT,210,END=420) TAPEID,MAC,DT,I,K        
  210 FORMAT (4A4,5I8)        
      IF (TAPEID(1).EQ.P3(1) .AND. TAPEID(2).EQ.P3(2)) GO TO 230        
      WRITE  (NOUT,220) TAPEID,P3,MAC,DT        
  220 FORMAT ('0*** WRONG TAPE MOUNTED - TAPEID =',2A4,', NOT ',2A4,    
     1        /5X,'MACHINE=',2A4,' DATE WRITTEN-',I4,1H/,I2,1H/,I2)     
      IF (P1 .EQ. -1) GO TO 100        
  230 IF (K  .EQ. P4) GO TO 250        
      WRITE  (NOUT,240) UWM,P4        
  240 FORMAT (A25,', MODULE INPUTT5 4TH PARAMETER SPECIFIED WRONG TAPE',
     1       ' FORMAT.   P4=',I5, /5X,        
     2       'INPUTT5 WILL RESET P4 AND TRY TO READ THE TAPE AGAIN.',/) 
      P4  = K        
      P40 =.NOT.P40        
      P41 =.NOT.P41        
  250 CALL PAGE2 (4)        
      WRITE  (NOUT,260) TAPEID,MAC,DT,I        
  260 FORMAT (/5X,'MODULE INPUTT5 IS NOW PROCESSING TAPE ',2A4,        
     1       ' WHICH WAS WRITTEN BY ',2A4,'MACHINE', /5X,        
     2       'ON',I4,1H/,I2,1H/,I2,4X,'SYSTEM BUFFSIZE=',I8)        
      IF (P40) WRITE (NOUT,270)        
      IF (P41) WRITE (NOUT,280)        
  270 FORMAT (5X,'TAPE IN BINARY RECORDS',/)        
  280 FORMAT (5X,'TAPE IN FORMATTED RECORDS',/)        
      LL = 0        
      IF (P1.GT.0 .OR. P1.EQ.-3) GO TO 300        
      IF (P1 .EQ. -1) GO TO 510        
      IMHERE = 290        
      WRITE  (NOUT,290) SFM,IMHERE,P1        
  290 FORMAT (A25,' @',I5,I10)        
      GO TO 100        
C        
C     TO SKIP P1 MATRIX DATA BLOCKS OR TABLES ON INPUT TAPE (P1 = +N)   
C     OR PRINT CONTENTS OF INPUT TAPE (P1 = -3)        
C        
  300 IF (P40 ) READ (INPUT,    ERR=390,END=420) NC,JB,JE        
      IF (P41S) READ (INPUT,520,ERR=390,END=420) NC,JB,JE,( X,J=JB,JE)  
      IF (P41C) READ (INPUT,525,ERR=390,END=420) NC,JB,JE,( X,J=JB,JE)  
      IF (P41D) READ (INPUT,530,ERR=390,END=420) NC,JB,JE,(DX,J=JB,JE)  
      IF (DEBUG .AND. (NC.LE.15 .OR. NC.GE.COL12))        
     1    WRITE (NOUT,540) NC,JB,JE,LL        
      IF (NC) 360,340,300        
C        
  310 IF (P40) READ (INPUT,    ERR=390,END=420) L        
      IF (P41) READ (INPUT,320,ERR=390,END=420) L,(TABEL,J=1,L)        
  320 FORMAT (I10,24A, /,(26A5))        
      IF (DEBUG) WRITE (NOUT,330) L,LL        
  330 FORMAT (30X,'L AND LL=',2I6)        
      IMHERE = 330        
      IF (L) 360,340,310        
  340 IF (P1.NE.-3 .AND. LL.GE.P1) GO TO 360        
      IMHERE = 340        
      LL = LL + 1        
      BACKSPACE INPUT        
      IF (P41) BACKSPACE INPUT        
      IF (LL .GT. 15) GO TO 370        
      IF (P40) READ (INPUT    ) I,I,I,DX,J,J,J,J,K,K,FN(1,LL),FN(2,LL)  
      IF (P41) READ (INPUT,560) I,I,I,DX,J,J,J,J,K,K,FN(1,LL),FN(2,LL)  
      IF (P1.NE.-3 .OR. LL.LE.P1) FN(3,LL) = SKIP        
      IF (K.GT.0 .AND. J.GE.1 .AND. J.LE.4) GO TO 350        
C        
C     FILE IS A TABLE        
C        
      IF (LL .GT. P1) FN(3,LL) = TBLE        
      IMHERE = 345        
      GO TO 310        
C        
C     FILE IS A MATRIX        
C        
  350 IF (LL .GT. P1) FN(3,LL) = MTRX        
      IF (P40) GO TO 300        
      P41S = .FALSE.        
      P41D = .FALSE.        
      P41C =  P4.EQ.2 .AND. NBPW.GE.60        
      IF (P41C) GO TO 300        
      IF (J.EQ.1 .OR. J.EQ.3) P41S = .TRUE.        
      P41D = .NOT.P41S        
      GO TO 300        
C        
  360 IF (P1 .EQ. -3) GO TO 900        
      IF (P41) BACKSPACE INPUT        
      BACKSPACE INPUT        
      GO TO 510        
C        
  370 WRITE  (NOUT,380) UIM        
  380 FORMAT (A29,', INPUTT5, WITH P1= -3, CAN ONLY PRINT UP TO 15 ',   
     1       ' FILE NAMES ON ONE INPUT TAPE.', /5X,'TAPE IS POSITIONED',
     2       ' AFTER THE 15TH FILE')        
      LL = LL - 1        
      GO TO 920        
C        
  390 WRITE  (NOUT,400) UFM,P3,LL,NC,IMHERE        
  400 FORMAT (A23,', TAPE ERROR DURING READ/INPUTT5  ',2A4, /5X,        
     1       'LL,NC =',2I5,'   IMHERE =',I5)        
      IMHERE = 405        
      IF (P41 .AND. MACH.EQ.2) WRITE (NOUT,410) IMHERE        
  410 FORMAT (/5X,'IBM USER - CHECK FILE ASSIGNMENT FOR DCB PARAMETER ',
     1       'OF 132 BYTES',I15)        
      GO TO  100        
  420 IF (P1 .EQ. -3) GO TO 440        
      WRITE  (NOUT,430) UFM,P3,IMHERE,LL,NC        
  430 FORMAT (A23,', EOF ENCOUNTERED ON INPUT TAPE ',2A4,5X,        
     1        'IMHERE,LL,NC =',3I5)        
      IF (P1 .NE. -3) NOGO = 1        
      GO TO  900        
  440 WRITE  (NOUT,450) UWM,P3        
  450 FORMAT (A25,', EOF ENCOUNTERED ON INPUT TAPE ',2A4,'. TAPE DOES ',
     1       'NOT CONTAIN AN ''OUTPUT5 E-O-F'' MARK')        
      IF (DEBUG) WRITE (NOUT,460) IMHERE,LL,NC        
  460 FORMAT (5X,'IMHERE,LL,NC =',3I5)        
      GO TO  900        
C        
C     P1 = 0,        
C     MUST SKIP TAPE HEADER RECORD IF CURRENT TAPE POSITION IS AT THE   
C     VERY BEGINNING        
C        
  500 LL = 0        
      IMHERE = 500        
      IF (P40) READ (INPUT,    ERR=770,END=420) TAPEID        
      IF (P41) READ (INPUT,210,ERR=770,END=420) TAPEID        
      IF (TAPEID(1).NE.P3(1) .OR. TAPEID(2).NE.P3(2)) BACKSPACE INPUT   
C        
C     COPY MATRIX TO TAPE        
C        
      IMHERE = 510        
  510 IF (P40S) READ(INPUT,    ERR=770,END=910) NC,JB,JE,(RZ(J),J=JB,JE)
      IF (P40D) READ(INPUT,    ERR=770,END=910) NC,JB,JE,(DZ(J),J=JB,JE)
      IF (P41S) READ(INPUT,520,ERR=770,END=910) NC,JB,JE,(RZ(J),J=JB,JE)
      IF (P41C) READ(INPUT,525,ERR=770,END=910) NC,JB,JE,(RZ(J),J=JB,JE)
      IF (P41D) READ(INPUT,530,ERR=770,END=910) NC,JB,JE,(DZ(J),J=JB,JE)
  520 FORMAT (3I8,/,(10E13.6))        
  525 FORMAT (3I8,/,(5E26.17))        
  530 FORMAT (3I8,/,(5D26.17))        
      IF (DEBUG .AND. (NC.LE.15 .OR. NC.GE.COL12))        
     1    WRITE (NOUT,540) NC,JB,JE,LL,IMHERE        
  540 FORMAT (30X,'NC,JB,JE,LL=',5I6,'=IMHERE')        
      IF (NC) 800,           550,         700        
C             EOF, MATRIX-HEADER, COLUMN-DATA        
C        
C     MATRIX OR TABLE HEADER        
C        
  550 IF (OPN) GO TO 810        
      LL = LL + 1        
      IF (LL .GT. 15) GO TO 370        
      BACKSPACE INPUT        
      IF (P41) BACKSPACE INPUT        
      J = -1        
      IF (P40) READ (INPUT,    ERR=570) K,J,J,DX,COL,ROW,FORM,TYPE,     
     1                                  MAX,DENS,FN(1,LL),FN(2,LL)      
      IF (P41) READ (INPUT,560,ERR=570) K,J,J,DX,COL,ROW,FORM,TYPE,     
     1                                  MAX,DENS,FN(1,LL),FN(2,LL)      
  560 FORMAT (3I8,/,D26.17,6I8,2A4)        
      COL12 = COL - 12        
      IF (COL12 .LT. 0) COL12 = 0        
      IF (.NOT.DEBUG) GO TO 590        
  570 WRITE  (NOUT,580) COL,ROW,FORM,TYPE,MAX,DENS,DX,FN(1,LL),FN(2,LL) 
  580 FORMAT (' COL,ROW,FORM,TYPE,MAX,DENS,DX,FILE=',6I6,D12.3,3X,2A4)  
      IF (J .EQ. -1) CALL MESAGE (-37,0,SUBNAM)        
C        
  590 IF (K.EQ.0 .AND. (DENS.EQ.0 .OR. TYPE.LE.0 .OR. TYPE.GT.4))       
     1    CALL TABLE V (*510,INPUT,LL,MCB,FN(1,LL),P4,BUF1,RZ)        
C        
      FN(3,LL) = MTRX        
      P40S = .FALSE.        
      P40D = .FALSE.        
      P41S = .FALSE.        
      P41D = .FALSE.        
      P41C =  P4.EQ.2 .AND. NBPW.GE.60        
      IF (P41C) GO TO 610        
      IF (P41 ) GO TO 600        
      IF (TYPE.EQ.1 .OR. TYPE.EQ.3) P40S = .TRUE.        
      P40D = .NOT.P40S        
      GO TO 610        
  600 IF (TYPE.EQ.1 .OR. TYPE.EQ.3) P41S = .TRUE.        
      P41D = .NOT.P41S        
  610 IF (DEBUG) WRITE (NOUT,620) P40,P40S,P40D,P41,P41S,P41D,P41C      
  620 FORMAT ('0  P40,P40S,P40D,P41,P41S,P41D,P41C = ',7L4)        
      TYPIN  = TYPE        
      TYPOUT = TYPE        
      JTYP   = TYPE        
      IF (TYPE .EQ. 3) JTYP = 2        
      II   = 1        
      JJ   = ROW        
      INCR = 1        
      NWDS = ROW*JTYP        
      IF (NWDS .GT. BUF1) CALL MESAGE (-8,0,SUBNAM)        
C        
C     OPEN GINO FILE FOR OUTPUT        
C        
      IMHERE = 640        
      IF (P1 .EQ. -3) GO TO 640        
      ROWX   = ROW        
      FORMX  = FORM        
      OUTPUT = 200 + LL - P1N        
      MCB(1) = OUTPUT        
      CALL RDTRL (MCB(1))        
      IF (MCB(1) .LE. 0) GO TO 750        
      ERR  = -1        
      CALL OPEN  (*120,OUTPUT,RZ(BUF1),1)        
      CALL FNAME (OUTPUT,NAME)        
      CALL WRITE (OUTPUT,NAME,2,1)        
      OPN  = .TRUE.        
      COL  = 0        
      ROW  = ROWX        
      FORM = FORMX        
      TYPE = TYPOUT        
      MAX  = 0        
      DENS = 0        
      NCK  = 0        
      GO TO 510        
C        
  640 WRITE (NOUT,290) SFM,IMHERE,P1        
      CALL MESAGE (-37,0,SUBNAM)        
C        
C     RECOVER INPUT MATRIX, AND WRITE IT OUT BY COLUMN        
C        
  700 IMHERE = 700        
      IF (P1 .EQ. -3) GO TO 510        
      NCK = NCK + 1        
      IF (NC .NE. NCK) GO TO 390        
      IF (JB .LE. 1) GO TO 720        
      JB  = (JB-1)*JTYP        
      DO 710 J = 1,JB        
  710 RZ(J) = 0.0        
  720 IF (JE .GE. NWDS) GO TO 740        
      JE  = (JE*JTYP) + 1        
      DO 730 J = JE,NWDS        
  730 RZ(J) = 0.0        
  740 CALL PACK (RZ,OUTPUT,MCB)        
      GO TO 510        
C        
C     OUTPUT FILE PURGED, SKIP FORWARD FOR NEXT MATRIX ON TAPE        
C        
  750 IF (P40 ) READ (INPUT    ,ERR=390,END=420) NC,JB,JE        
      IF (P41S) READ (INPUT,520,ERR=390,END=420) NC,JB,JE,( X,J=JB,JB)  
      IF (P41C) READ (INPUT,525,ERR=390,END=420) NC,JB,JE,( X,J=JB,JB)  
      IF (P41D) READ (INPUT,530,ERR=390,END=420) NC,JB,JE,(DX,J=JB,JB)  
      IF (NC .GT. 0) GO TO 750        
      CALL PAGE2 (2)        
      WRITE  (NOUT,760) UWM,FN(1,LL),FN(2,LL)        
  760 FORMAT (A25,', OUTPUT FILE PURGED.  ',2A4,' FROM INPUT TAPE NOT ',
     1       'COPIED')        
C     LL = LL + 1        
      GO TO 550        
C        
  770 IMHERE = -IMHERE        
      WRITE  (NOUT,400) UFM,P3,LL,NC,IMHERE        
      WRITE  (NOUT,780) P40,P41,P40S,P40D,P41S,P41D,P41C        
  780 FORMAT ('  P40,P41,P40S,P40D,P41S,P41D,P41C =',7L2)        
      IMHERE = 770        
      IF (P41 .AND. MACH.EQ.2) WRITE (NOUT,410) IMHERE        
      GO TO 750        
C        
C     END OF MATRIX ENCOUNTERED. CLOSE GINO DATA BLOCK WITH REWIND.     
C        
  800 IF (.NOT.OPN) GO TO 840        
  810 CALL CLOSE (OUTPUT,1)        
      OPN = .FALSE.        
      IF (FORM.GE.1 .AND. FORM.LE.6) GO TO 820        
      FORM = 1        
      IF (COL .NE. ROW) FORM = 2        
  820 CALL WRTTRL (MCB)        
      CALL FNAME (OUTPUT,NAME)        
      CALL PAGE2 (10)        
      WRITE  (NOUT,830) FN(1,LL),FN(2,LL),INPUT,NAME,(MCB(J),J=1,7)     
  830 FORMAT (/5X,'MATRIX DATA BLOCK ',2A4,' WAS SUCESSFULLY RECOVERED',
     1       ' FROM FORTRAN UNIT',I4,' TO ',2A4, /8X,'GINO UNIT =',I8,  
     2       /6X,'NO. OF COLS =',I8, /6X,'NO. OF ROWS =',I8,  /13X,     
     3       'FORM =',I8, /13X,'TYPE =',I8, /3X,'NON-ZERO WORDS =',I8,  
     4       /10X,'DENSITY =',I8)        
  840 IMHERE = 840        
      IF (LL .GE.  5+P1N) GO TO 860        
      IF (NC) 850,550,390        
  850 IF (P1 .EQ. -3) GO TO 1000        
      GO TO 900        
  860 BACKSPACE INPUT        
      IF (P41) BACKSPACE INPUT        
      GO TO 920        
C        
C     IF NC = -2, THIS IS AN ELEM/GRID ID RECORD WRITTEN BY DUMOD5      
C        
  900 IF (NC .EQ. -2) GO TO 510        
  910 NC = -3        
      IF (OPN) GO TO 800        
      IF (FN(3,LL) .EQ. BK) LL = LL - 1        
      IF (LL .LE. 0) GO TO 970        
C        
C     PRINT LIST OF DATA BLOCKS ON FORTRAN TAPE (P1=-3).        
C        
  920 CALL PAGE2 (LL+9)        
      WRITE  (NOUT,930)        
      IF (P1 .NE. -3) WRITE (NOUT,940) INPUT        
      IF (P1 .EQ. -3) WRITE (NOUT,950) INPUT        
      WRITE  (NOUT,960) MAC,BF,(J,FN(1,J),FN(2,J),FN(3,J),J=1,LL)       
  930 FORMAT (/5X,'SUMMARY FROM INPUTT5 MODLUE -')        
  940 FORMAT (/34X,'FILES RECOVERED FROM FORTRAN UNIT',I5)        
  950 FORMAT (/34X,'FILE CONTENTS ON FORTRAN UNIT',I5)        
  960 FORMAT (28X,'(WRITTEN BY ',2A4,' MACHINE ',A8,' RECORDS)', //37X, 
     1       'FILE',8X,'NAME',8X,'TYPE', /33X,9(4H----), /,        
     2       (37X,I3,7X,2A4,6X,A4))        
      IF (NOGO .EQ. 1) GO TO 100        
C        
      IF (P1  .NE. -3) GO TO 1000        
      REWIND INPUT        
      IF (P40) READ (INPUT)        
      IF (P41) READ (INPUT,210)        
      GO TO 1000        
C        
  970 IF (P1 .EQ. -3) WRITE (NOUT,980) UIM,INPUT        
  980 FORMAT (A29,' FROM INPUTT5 MODULE, INPUT TAPE (FORTRAN UNIT',I5,  
     1       ') CONTAINS NO DATA BLOCK')        
C        
 1000 IF (MACH .EQ. 3) CALL UNVCLS (P2)        
      IF (MACH .EQ. 4) CALL CDCCLS (P2)        
      RETURN        
      END        
