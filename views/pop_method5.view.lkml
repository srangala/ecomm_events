include: "pop_method3_order_items.view.lkml"
view: pop_method5 {
  extends: [pop_method3_order_items]

  # custom date range
  filter: previous_date_range {
    type: date
    view_label: "_PoP"
    label: "2a. Previous Date Range (Custom):"
    description: "Select a custom previous period you would like to compare to. Must be used with Current Date Range filter."
  }

  parameter: compare_to {label: "2b. Compare To:"}
  dimension_group: date_in_period {hidden:yes}

  dimension: period_2_start {
    view_label: "_PoP"
    description: "Calculates the start of the previous period"
    type: date
    sql:
            {% if compare_to._in_query %}
                {% if compare_to._parameter_value == "Period" %}
                DATEADD(DAY, -${days_in_period}, DATE({% date_start current_date_range %}))
                {% else %}
                DATEADD({% parameter compare_to %}, -1, DATE({% date_start current_date_range %}))
                {% endif %}
            {% else %}
                {% date_start previous_date_range %}
            {% endif %};;
    hidden:  yes
  }

  dimension: period_2_end {
    hidden:  yes
    view_label: "_PoP"
    description: "Calculates the end of the previous period"
    type: date
    sql:
            {% if compare_to._in_query %}
                {% if compare_to._parameter_value == "Period" %}
                DATEADD(DAY, -1, DATE({% date_start current_date_range %}))
                {% else %}
                DATEADD({% parameter compare_to %}, -1, DATEADD(DAY, -1, DATE({% date_end current_date_range %})))
                {% endif %}
            {% else %}
                {% date_end previous_date_range %}
            {% endif %};;
  }
}

# ---------- EXPLORE ---------- #

explore: pop_method5 {
  label: "PoP Method 5: Compare current period with another arbitrary period"
  always_filter: {
    filters: [current_date_range: "1 month", previous_date_range: "2 months ago for 2 days"]
  }
}
