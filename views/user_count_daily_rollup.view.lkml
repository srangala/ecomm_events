# The name of this view in Looker is "User Count Daily Rollup"
view: user_count_daily_rollup {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: public.user_count_daily_rollup ;;
  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Column" in Explore.

  dimension: column {
    type: string
    sql: ${TABLE}."?column?" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
