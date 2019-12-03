class ZCL_UTIL_PROGRESS definition
  public
  final
  create private .

public section.

  methods SHOW
    importing
      !IV_INDEX type INT4 .
  class-methods NEW_INDICATOR
    importing
      !IV_TOTAL type INT4
      !IV_EVERY type INT4 default 1
      !IV_TEXT type TEXT20 optional
    returning
      value(RO_PROGRESS) type ref to ZCL_UTIL_PROGRESS .
protected section.
private section.

  data MV_TOTAL type INT4 .
  data MV_EVERY type INT4 .
  data MV_TEXT type TEXT20 .
  data MV_SEP type TEXT5 .

  methods BUILD_TEXT
    importing
      !IV_INDEX type INT4
    returning
      value(RV_TEXT) type TEXT50 .
  methods CONSTRUCTOR
    importing
      !IV_TOTAL type INT4
      !IV_EVERY type INT4 default 1
      !IV_TEXT type TEXT20 optional .
ENDCLASS.



CLASS ZCL_UTIL_PROGRESS IMPLEMENTATION.


METHOD build_text.

    DATA: lv_num TYPE string,
          lv_tot TYPE string.

    CLEAR: rv_text.

    lv_num = iv_index.
    lv_tot = mv_total.
    CONDENSE: lv_num NO-GAPS,
              lv_tot NO-GAPS.

    IF mv_text IS NOT INITIAL.
      CONCATENATE mv_text ':'  INTO rv_text.

      CONCATENATE rv_text " Texto con :
                  lv_num  " Índice actual
                  mv_sep  " Separador contadores
                  lv_tot  " Total
        INTO rv_text SEPARATED BY space.

    ELSE.
      CONCATENATE lv_num  " Índice actual
                  mv_sep  " Separador contadores
                  lv_tot  " Total
      INTO rv_text SEPARATED BY space.

    ENDIF.

  ENDMETHOD.


METHOD constructor.

    mv_total = iv_total.
    mv_every = iv_every.
    mv_text  = iv_text.
    mv_sep   = text-sep.

  ENDMETHOD.


METHOD new_indicator.

    DATA: lv_every TYPE int4,
          lv_text  TYPE text20.

    " El total de elementos debe ser superior a cero
    IF iv_total IS INITIAL OR iv_total LT 0.
      RETURN.
    ENDIF.

    " El valor mostrar cada deber ser superior a cero
    IF iv_every IS INITIAL OR iv_every LE 0.
      " Reajustar para mostrar de uno en uno
      lv_every = 1.
    ELSE.
      " El valor mostrar cada no puede ser igual o superior al total
      IF iv_every GE iv_total.
        " Reajustar para mostrar de uno en uno
        lv_every = 1.
      ELSE.
        " Valor Mostrar Cada de entrada válido
        lv_every = iv_every.
      ENDIF.
    ENDIF.

    IF iv_text IS NOT INITIAL.
      lv_text = iv_text.
      " Si existe el simbolo dos puntos quitarlo
      FIND ':' IN lv_text.
      IF sy-subrc EQ 0.
        REPLACE space IN lv_text WITH '&'.
        REPLACE ':' IN lv_text WITH space.
        CONDENSE lv_text NO-GAPS.
        REPLACE '&' IN lv_text WITH space.
        CONDENSE lv_text NO-GAPS.
      ENDIF.
    ENDIF.

    " Crear instancia de retorno
    CREATE OBJECT ro_progress
      EXPORTING
        iv_total = iv_total
        iv_every = lv_every
        iv_text  = lv_text.

  ENDMETHOD.


METHOD show.

    DATA: lv_perc TYPE p,
          lv_text TYPE text50,
          lv_show TYPE int4.

    " Si el índice actual es superior al total, no visualizar progreso
    IF iv_index GT mv_total.
      RETURN.
    ENDIF.


    IF mv_every EQ 1. " Mostrar para todos los índices

      " Calcular porcentaje actual
      lv_perc = ( iv_index / mv_total ) * 100.

      " Construir texto con contador actual y total
      lv_text = build_text( iv_index ).

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = lv_perc
          text       = lv_text.

    ELSE. " Solo mostrar algunos índices

      " Obtener resto para comprobar si es múltiple
      lv_show = iv_index MOD mv_every.

      IF lv_show  EQ 0 OR      " Si el índice actual es múltiple del valor Mostrar Cada
         iv_index EQ 1 OR      " El primer índice siempre se muestra
         iv_index EQ mv_total. " El último índice siempre se muestra

        " Calcular porcentaje actual
        lv_perc = ( iv_index / mv_total ) * 100.

        " Construir texto con contador actual y total
        lv_text = build_text( iv_index ).

        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
          EXPORTING
            percentage = lv_perc
            text       = lv_text.

      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
