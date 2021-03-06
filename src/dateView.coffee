class DateView extends View
  name: 'date'

  currentMonth: null

  opts:
    el: null
    disableBefore: null
    disableAfter: null

  value: moment().format 'YYYY-MM-DD'

  _inputTpl: '<input type="text" class="view-input date-input" data-type="date" data-min="1"/>'

  dateReg: /\d{4}-\d{1,2}-\d{1,2}/

  _render: ->
    @currentMonth = @moment.format 'YYYY-MM'
    super()

  _renderPanel: ->
    week = ''
    for i in [1, 2, 3, 4, 5, 6 ,0]
      week += "<td>#{moment.weekdaysMin(i)}</td>"
    return """
      <div class="panel panel-date">
        <div class="calendar-menu">
          #{ @_renderDayMenu() }
        </div>
        <table class="calendar"">
          <tr class="datepicker-dow">
            #{week}
          </tr>
          #{ @_renderDaySelectors() }
        </table>
      </div>
    """

  _renderDayMenu: ->
    return """
      <a class="menu-item" data-action="prev"><i class="icon-chevron-left"><span>&lt;</span></i></a>
      <a class="menu-item" data-action="next"><i class="icon-chevron-right"><span>&gt;</span></i></a>
    """


  _renderDaySelectors: ->
    today = moment().startOf("day")
    tmpDate = moment(@currentMonth, 'YYYY-MM')

    @input.attr
      'data-max': tmpDate.endOf('month').date()

    # Calculate the first and last date in month being rendered.
    # Also calculate the weekday to start rendering on
    firstDate = tmpDate.clone().startOf("month")
    lastDate = tmpDate.clone().endOf("month")

    # Calculate the last day in previous month
    prevLastDate = tmpDate.clone().add(-1, "months").endOf("month")

    # Render the cells as <TD>
    days = ""
    y = 0
    i = 0

    while y < 6
      row = ""
      x = 0

      while x < 7
        p = ((prevLastDate.date() - prevLastDate.day()) + i + 1)
        n = p - prevLastDate.date()
        c = (if (x is 6) then "sun" else ((if (x is 5) then "sat" else "day")))
        date = tmpDate.clone().date(n)

        # If value is outside of bounds its likelym previous and next months
        if n >= 1 and n <= lastDate.date()
          # Test to see if it's today
          c += ' today' if (today.isSame(date, 'day') is true)

          # Test against selected date
          c += (if (date.diff(@selectedDate) is 0) then " selected" else " ")  if @selectedDate
        else if n > lastDate.date() and x is 0
          break
        else
          c = ((if (x is 6) then "sun" else ((if (x is 5) then "sat" else "day")))) + " others"
          n = (if (n <= 0) then p else ((p - lastDate.date()) - prevLastDate.date()))

        if moment.isMoment(@opts.disableBefore)
          until_ = moment(@opts.disableBefore, "YYYY-MM-DD")
          c += (if (date.diff(until_) < 0) then " disabled" else "")

        if moment.isMoment(@opts.disableAfter)
          until_ = moment(@opts.disableAfter, "YYYY-MM-DD")
          c += (if (date.diff(until_) > 0) then " disabled" else "")

        # Create the cell
        row += """
            <td class='datepicker-day'>
              <a href="javascript:;" class="#{c} panel-item" data-value="#{date.format('YYYY-MM-DD')}">
                #{n}
              </a>
            </td>
            """
        x++
        i++

      # Create the row
      if row
        days += """
            <tr class="days">#{row}</tr>
            """
      y++
    return days


  _onInputHandler: ->
    max = moment(@currentMonth, 'YYYY-MM').endOf('month').date()
    @input.val(@input.val().substr(1)) while Number(@input.val()) > max

    @input.val(@input.val().substr(1)) if @input.val().length is 3 #remove leading zero

    value = @input.val()

    if value.length is 1
      if Number(value) > 3
        @select(value, false, true)
      else if Number(value) isnt 0
        @timer = setTimeout =>
          @select(value, false, true)
          @timer = null
        , 800
    else if value.length is 2 and Number(value) <= max and Number(value) isnt 0
      @select(value, false, true)

  _onKeydownHandler: (e) ->
    clearTimeout @timer if @timer
    super(e)

  _handleAction: (action) ->
    tmpDate = moment(@currentMonth, 'YYYY-MM')
    direction = if action is 'prev' then -1 else 1

    tmpDate.add(direction, 'month')
    @currentMonth = tmpDate.format 'YYYY-MM'
    @triggerHandler 'select',
      source: 'date'
      moment: tmpDate
      finished: false

    @_reRenderPanel()
    @panel.addClass('active')

  _onClickHandler: (e) ->
    e.preventDefault()
    value = $(e.currentTarget).data 'value'
    tmpMoment = moment(value)
    @moment.set 'month', tmpMoment.format('M') - 1
    @moment.set 'year', tmpMoment.format('YYYY')
    value = tmpMoment.format('D')
    @select(value, true, true)

  _refreshInput: ->
    date = @moment.date()
    @input.val String('00' + date).slice(-2)

  _getValue: ->
    @moment.format 'YYYY-MM-DD'

  _onDateChangeHandler: (e) ->
    super(e)
    newMonth = @moment.format('YYYY-MM')
    
    return if newMonth is @currentMonth
    @currentMonth = newMonth
    @_reRenderPanel()

  select: (value, refreshInput, finished) ->
    clearTimeout @timer if @timer
    super(value, refreshInput, finished)

View.addView(DateView)
