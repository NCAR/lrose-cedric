      SUBROUTINE SWAPEMC (ITEM1, ITEM2)
C
C   BY: MARTA ORYSHCHYN
C
C     SWAPS THE LOCATIONS OF ANY TWO ITEMS
C   PASSED INTO THE ROUTINE.
C
      CHARACTER*(*) ITEM1, ITEM2
      CHARACTER*8 ITEMPH
      ITEMPH = ITEM1
      ITEM1 = ITEM2
      ITEM2 = ITEMPH
C
      RETURN
      END
