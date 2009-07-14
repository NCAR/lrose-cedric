      SUBROUTINE IGETCP(IWRD,IAZ,IX,IY)
C
C        UNPACKS INITIAL POSITIONING INFORMATION FROM A CARTESIAN LOCATION
C                THIS INFORMATION WAS STORED IN THE LOWER 32-BITS OF IWRD.
C
C      DATA MASK08,MASK16/ O'377', O'177777'/

C      IX =ICEDAND(IWRD,MASK08)
C      IY =ICEDAND(ICEDSHFT(IWRD,-8),MASK08)
C      IAZ=ICEDAND(ICEDSHFT(IWRD,-16),MASK16)

      CALL GBYTES(IWRD,IAZ,32,16,0,1)
      CALL GBYTES(IWRD,IY,48,8,0,1)
      CALL GBYTES(IWRD,IX,56,8,0,1)

      RETURN
      END
