      FUNCTION BNDVAL(R,RMIN,RMAX,RDEF,ISET)
C
C        TESTS VALUE OF R TO FORCE IT TO BE WITHIN SPECIFIED
C        BOUNDS. RETURNS DEFAULT VALUE UPON REQUEST.
C
C           R- INPUT VALUE TO CHECK
C        RMIN- MINIMUM ACCEPTABLE VALUE FOR R
C        RMAX- MAXIMUM ACCEPTABLE VALUE FOR R
C        RDEF- DEFAULT VALUE FOR R (OPTIONAL)
C        ISET- IF = 0, RESET R TO DEFAULT IF OUT OF BOUNDS
C
      S=AMAX1(RMIN,R)
      S=AMIN1(RMAX,S)
      IF(R.NE.S.AND.ISET.EQ.0) S=RDEF
      BNDVAL=S
      RETURN
      END
