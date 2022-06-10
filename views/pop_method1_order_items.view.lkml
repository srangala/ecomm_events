include: "order_items.view.lkml"

view: pop_method1_order_items {
  extends: [order_items]
#(Method 1a) you may also wish to create MTD and YTD filters in LookML

  dimension: wtd_only {
    group_label: "To-Date Filters"
    label: "WTD"
    view_label: "_PoP"
    type: yesno
    sql:  (EXTRACT(DOW FROM ${created_raw}) < EXTRACT(DOW FROM GETDATE())
                OR
            (EXTRACT(DOW FROM ${created_raw}) = EXTRACT(DOW FROM GETDATE()) AND
            EXTRACT(HOUR FROM ${created_raw}) < EXTRACT(HOUR FROM GETDATE()))
                OR
            (EXTRACT(DOW FROM ${created_raw}) = EXTRACT(DOW FROM GETDATE()) AND
            EXTRACT(HOUR FROM ${created_raw}) <= EXTRACT(HOUR FROM GETDATE()) AND
            EXTRACT(MINUTE FROM ${created_raw}) < EXTRACT(MINUTE FROM GETDATE())))  ;;
  }

  dimension: mtd_only {
    group_label: "To-Date Filters"
    label: "MTD"
    view_label: "_PoP"
    type: yesno
    sql:  (EXTRACT(DAY FROM ${created_raw}) < EXTRACT(DAY FROM GETDATE())
                OR
            (EXTRACT(DAY FROM ${created_raw}) = EXTRACT(DAY FROM GETDATE()) AND
            EXTRACT(HOUR FROM ${created_raw}) < EXTRACT(HOUR FROM GETDATE()))
                OR
            (EXTRACT(DAY FROM ${created_raw}) = EXTRACT(DAY FROM GETDATE()) AND
            EXTRACT(HOUR FROM ${created_raw}) <= EXTRACT(HOUR FROM GETDATE()) AND
            EXTRACT(MINUTE FROM ${created_raw}) < EXTRACT(MINUTE FROM GETDATE())))  ;;
  }

  dimension: ytd_only {
    group_label: "To-Date Filters"
    label: "YTD"
    view_label: "_PoP"
    type: yesno
    sql:  (EXTRACT(DOY FROM ${created_raw}) < EXTRACT(DOY FROM GETDATE())
                OR
            (EXTRACT(DOY FROM ${created_raw}) = EXTRACT(DOY FROM GETDATE()) AND
            EXTRACT(HOUR FROM ${created_raw}) < EXTRACT(HOUR FROM GETDATE()))
                OR
            (EXTRACT(DOY FROM ${created_raw}) = EXTRACT(DOY FROM GETDATE()) AND
            EXTRACT(HOUR FROM ${created_raw}) <= EXTRACT(HOUR FROM GETDATE()) AND
            EXTRACT(MINUTE FROM ${created_raw}) < EXTRACT(MINUTE FROM GETDATE())))  ;;
  }
  #-----------------------------------------------------


}


# ---------- EXPLORE ----------- #

explore: pop_method1_order_items {
  label: "PoP Method 1: Use Looker's native date dimension groups"
}
