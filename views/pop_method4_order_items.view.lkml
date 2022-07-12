###  Period over Period Method 4: Compare multiple templated periods

# Like Method 3, but expanded to compare more than two periods

include: "pop_method3_order_items.view.lkml"
# This extended version allows you to choose multiple periods (this can also work in conjunction with the custom range version, or separately)
view: pop_method4_order_items {
  extends: [pop_method3_order_items]
  parameter: comparison_periods {
    view_label: "_PoP"
    label: "3. Number of Periods"
    description: "Choose the number of periods you would like to compare."
    type: unquoted
    allowed_value: {
      label: "2"
      value: "2"
    }
    allowed_value: {
      label: "3"
      value: "3"
    }
    allowed_value: {
      label: "4"
      value: "4"
    }
    default_value: "2"
  }

  dimension: period_3_start {
    view_label: "_PoP"
    description: "Calculates the start of 2 periods ago"
    type: date
    sql:
        {% if compare_to._parameter_value == "Period" %}
            DATEADD(DAY, -(2 * ${days_in_period}), DATE({% date_start current_date_range %}))
        {% else %}
            DATEADD({% parameter compare_to %}, -2, DATE({% date_start current_date_range %}))
        {% endif %};;
    hidden: yes

  }

  dimension: period_3_end {
    view_label: "_PoP"
    description: "Calculates the end of 2 periods ago"
    type: date
    sql:
        {% if compare_to._parameter_value == "Period" %}
            DATEADD(DAY, -1, ${period_2_start})
        {% else %}
            DATEADD({% parameter compare_to %}, -2, DATEADD(DAY, -1, DATE({% date_end current_date_range %})))
        {% endif %};;
    hidden: yes
  }

  dimension: period_4_start {
    view_label: "_PoP"
    description: "Calculates the start of 4 periods ago"
    type: date
    sql:
        {% if compare_to._parameter_value == "Period" %}
            DATEADD(DAY, -(3 * ${days_in_period}), DATE({% date_start current_date_range %}))
        {% else %}
            DATEADD({% parameter compare_to %}, -3, DATE({% date_start current_date_range %}))
        {% endif %};;
    hidden: yes
  }

  dimension: period_4_end {
    view_label: "_PoP"
    description: "Calculates the end of 4 periods ago"
    type: date
    sql:
            {% if compare_to._parameter_value == "Period" %}
            DATEADD(DAY, -1, ${period_2_start})
            {% else %}
            DATEADD({% parameter compare_to %}, -3, DATEADD(DAY, -1, DATE({% date_end current_date_range %})))
            {% endif %};;
    hidden: yes
  }

  dimension: period {
    view_label: "_PoP"
    label: "Period"
    description: "Pivot me! Returns the period the metric covers, i.e. either the 'This Period', 'Previous Period' or '3 Periods Ago'"
    type: string
    order_by_field: order_for_period
    sql:
            {% if current_date_range._is_filtered %}
                CASE
                WHEN {% condition current_date_range %} ${created_raw} {% endcondition %}
                THEN 'This {% parameter compare_to %}'
                WHEN ${created_date} between ${period_2_start} and ${period_2_end}
                THEN 'Last {% parameter compare_to %}'
                WHEN ${created_date} between ${period_3_start} and ${period_3_end}
                THEN '2 {% parameter compare_to %}s Ago'
                WHEN ${created_date} between ${period_4_start} and ${period_4_end}
                THEN '3 {% parameter compare_to %}s Ago'
                END
            {% else %}
                NULL
            {% endif %}
            ;;
  }

  dimension: order_for_period {
    hidden: yes
    view_label: "Comparison Fields"
    label: "Period"
    type: string
    sql:
            {% if current_date_range._is_filtered %}
                CASE
                WHEN {% condition current_date_range %} ${created_raw} {% endcondition %}
                THEN 1
                WHEN ${created_date} between ${period_2_start} and ${period_2_end}
                THEN 2
                WHEN ${created_date} between ${period_3_start} and ${period_3_end}
                THEN 3
                WHEN ${created_date} between ${period_4_start} and ${period_4_end}
                THEN 4
                END
            {% else %}
                NULL
            {% endif %}
            ;;
  }
  dimension: day_in_period {
    description: "Gives the number of days since the start of each periods. Use this to align the event dates onto the same axis, the axes will read 1,2,3, etc."
    type: number
    sql:
        {% if current_date_range._is_filtered %}
            CASE
            WHEN {% condition current_date_range %} ${created_raw} {% endcondition %}
            THEN DATEDIFF(DAY, DATE({% date_start current_date_range %}), ${created_date}) + 1

            WHEN ${created_date} between ${period_2_start} and ${period_2_end}
            THEN DATEDIFF(DAY, ${period_2_start}, ${created_date}) + 1

            WHEN ${created_date} between ${period_3_start} and ${period_3_end}
            THEN DATEDIFF(DAY, ${period_3_start}, ${created_date}) + 1

            WHEN ${created_date} between ${period_4_start} and ${period_4_end}
            THEN DATEDIFF(DAY, ${period_4_start}, ${created_date}) + 1
            END

        {% else %} NULL
        {% endif %}
        ;;
    hidden: yes
  }
}

# ---------- EXPLORE ---------- #

explore: pop_method4_order_items {
  label: "PoP Method 4: Compare multiple templated periods"
  extends: [pop_method3_order_items]
  sql_always_where:
            {% if pop_method4_order_items.current_date_range._is_filtered %} {% condition pop_method4_order_items.current_date_range %} ${created_raw} {% endcondition %}
            {% if pop_method4_order_items.previous_date_range._is_filtered or pop_method4_order_items.compare_to._in_query %}
            {% if pop_method4_order_items.comparison_periods._parameter_value == "2" %}
                or ${created_raw} between ${period_2_start} and ${period_2_end}
            {% elsif pop_method4_order_items.comparison_periods._parameter_value == "3" %}
                or ${created_raw} between ${period_2_start} and ${period_2_end}
                or ${created_raw} between ${period_3_start} and ${period_3_end}
            {% elsif pop_method4_order_items.comparison_periods._parameter_value == "4" %}
                or ${created_raw} between ${period_2_start} and ${period_2_end}
                or ${created_raw} between ${period_3_start} and ${period_3_end} or ${created_raw} between ${period_4_start} and ${period_4_end}
            {% else %} 1 = 1
            {% endif %}
            {% endif %}
            {% else %} 1 = 1
            {% endif %};;
}
