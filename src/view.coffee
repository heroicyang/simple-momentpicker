class View extends SimpleModule

  opts:
    parent: null
    inputContainer: null
    panelContainer: null

  #view's name & moment's type
  name: ''

  #template
  _inputTpl: '<input class="input"/>'
  _panelTpl: '<div class="panel"></div>'

  # add constructor of view
  @addView: (view) ->
    unless @views
      @views = []
    @views[view::name] = view


  _init: ->
    @parent = $(@opts.parent)
    @inputContainer = $(@opts.inputContainer)
    @panelContainer = $(@opts.panelContainer)

    @moment = @opts.defaultValue || moment()

    @_render()
    @_bindInput()
    @_bindPanel()
    @_bindView()

  _render: ->
    @input = $(@_renderInput())
    @panel = $(@_renderPanel())

    @inputContainer.append @input
    @panelContainer.append @panel

    @_refreshSelected()
    @_refreshInput()

  _bindInput: ->
    @input.on 'focus', =>
      @panel.addClass 'active'
      @trigger 'showpanel',
        source: @name

    @input.on 'keydown', (e) =>
      @_onKeydownHandler(e)

    @input.on 'input', (e) =>
      @_onInputHandler(e)

    @input.on 'click', (e) =>
      @input.focus().select()

      false

  _onKeydownHandler: (e) ->
    key = e.which
    value = @input.val()
    type = @input.data 'type'
    min = @input.data 'min'
    max = @input.data 'max'
    if key is 9 #tab
      if e.shiftKey
        @trigger 'showpanel',
          source: @name
          prev: true
      else
        @select(value, false, true)
    else if key is 13 #enter
      @select(value, false, false)
      @trigger 'close',
        selected: true
    else if key is 38 or key is 40
      direction = if key is 38 then 1 else -1
      value = Number(value) + direction
      value = max if value < min
      value = min if value > max
      @select(value, true, false)
    else if [48..57].indexOf(key) isnt -1
      return
    else if [8, 46, 37, 39].indexOf(key) isnt -1
      return
    else if key is 27 #esc
      @trigger 'close'

    e.preventDefault()

  _onInputHandler: ->

  _bindPanel: ->
    @panel.on 'click', 'a.panel-item', (e) =>
      @_onClickHandler(e)

    @panel.on 'click', 'a.menu-item', (e) =>
      e.preventDefault()
      action = $(e.currentTarget).data 'action'
      @_handleAction(action)

  _onClickHandler: (e) ->
    e.preventDefault()
    value = $(e.currentTarget).data 'value'
    @select(value, true, true)

  _handleAction: ->

  _bindView: ->
    @on 'datechange', (e, event) =>
      @_onDateChangeHandler(event)

  _onDateChangeHandler: (e)->
    @moment = e.moment

    @_refreshInput()
    @_refreshSelected()

  _renderInput: ->
    @_inputTpl

  _renderPanel: ->
    @_panelTpl

  _reRenderPanel: (opt) ->
    active = true if @panel.is '.active'

    @panel.replaceWith $(@_renderPanel(opt))
    @panel = @panelContainer.find ".panel-#{@name}"

    @panel.addClass 'active'  if active
    @_refreshSelected()
    @_bindPanel()

  _refreshSelected: ->
    @panel.find('a.selected').removeClass 'selected'
    @panel.find("a[data-value='#{@_getValue()}']").addClass 'selected'

  _refreshInput: ->
    @input.val(@_getValue())

  _getValue: ->
    @moment.get @name

  select: (value, refreshInput, finished) ->
    @moment.set @name, value
    @triggerHandler 'select',
      source: @name
      moment: @moment
      finished: finished
    @triggerHandler 'datechange',
      moment: @moment

  setActive: (active = true) ->
    if active
      @input.focus().select()
    else
      @panel.removeClass 'active'

  clear: ->
    @moment = moment()
    @input.val('')

