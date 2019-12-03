*&---------------------------------------------------------------------*
*& Report ZDEMO_PROGRESS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdemo_progress.

DATA: lo_indicator TYPE REF TO zcl_util_progress,
      gv_actual    TYPE int4.


**********************************************************************
*  -> Pantalla de Selección
**********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE TEXT-t00.

PARAMETERS: p_total TYPE int4 DEFAULT 23,
            p_every TYPE int4 DEFAULT 5.

SELECTION-SCREEN SKIP.

PARAMETERS: p_text TYPE text20 DEFAULT 'Elemento'.

SELECTION-SCREEN END OF BLOCK b0.



START-OF-SELECTION.

  " En un ejemplo real, se suele utilizar una tabla interna.
  " Utilizar la sentencia LINES( <itab> ) para obtener el total
  " de elementos -> P_TOTAL = LINES( <ITAB variable> ).

  " Crear indicador de progreso
  lo_indicator = zcl_util_progress=>new_indicator(
                   iv_total = p_total   " Total elementos
                   iv_every = p_every   " Mostrar cada
                   iv_text  = p_text ). " Texto progreso

  IF lo_indicator IS INITIAL.
    " Error - El valor Total debe ser superior a cero
    MESSAGE s398(00) WITH TEXT-e00 DISPLAY LIKE 'E'.
  ENDIF.

  gv_actual = 1.
  " En ejemplo real esto sería un LOOP a una tabla interna
  DO p_total TIMES.

    " En un ejemplo real, el índice se obtendría de la variable SY-TABIX
    " IMPORTANTE SIEMPRE nada más entrar al LOOP -> GV_ACTUAL = SY-TABIX.

    " Visualizar indicador de progreso
    lo_indicator->show( gv_actual ).

    " Simular proceso que tarda medio segundo
    WAIT UP TO '0.5' SECONDS.

    " Aumentar contador índice actual
    gv_actual = gv_actual + 1.
  ENDDO.
