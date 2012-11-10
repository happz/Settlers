#
# Namespaces
#
window.settlers = window.settlers or {}
window.settlers.events = window.settlers.events or {}
window.settlers.templates = window.settlers.templates or {}

window.settlers.templates.talk = {}
window.settlers.templates.talk.posts = '
  {{#posts}}
    {{stamp_formatted}} - {{author.name}}: {{text}}<br />
  {{/posts}}
'

#
# Classes
#
class window.settlers.PullNotify
  constructor:	() ->
    pull_notify = @
    __call_update = () ->
      pull_notify.update()

    $('.menu-widget').everyTime '60s', __call_update

  update:		() ->
    new window.hlib.Ajax
      url:			'/pull_notify'
      keep_focus:		true
      handlers:
        h200:			(response, ajax) ->
          # Reset all widgets
          window.hlib.setTitle 'Osadnici'
          window.settlers.hide_menu_alert 'menu_chat'
          window.settlers.hide_menu_alert 'menu_home'
          $('#trumpet_board').hide()

          to_title = 0

          if response.events.chat != false
            to_title += response.events.chat
            $('#menu_chat .menu-alert').html response.events.chat
            window.settlers.show_menu_alert 'menu_chat'

          if response.events.on_turn != false
            to_title += response.events.on_turn
            $('#menu_home .menu-alert').html response.events.on_turn
            window.settlers.show_menu_alert 'menu_home'

          if to_title > 0
            window.hlib.setTitle window.settlers.title + ' (' + to_title + ')'

          if response.events.trumpet != false
            $('#trumpet_board div').html response.events.trumpet
            $('#trumpet_board').show()

          window.hlib.INFO._hide()

class window.settlers.Talk
  constructor: (eid) ->
    @eid = eid
    @visible = false

    t = @

    $(@eid).dialog
      closeOnEscape:	true
      closeText:        ''
      autoOpen:         false
      height:           400
      width:		350
      title:		'Chat'
      modal:            false
      position:		['center', 'middle']
      open:		() ->
        $('#talk_dialog_close').click () ->
          t.hide()
          return false
        return true

    $(@eid + ' div.right input[type="button"]').click () ->
      t.hide()

  update: () ->
    t = @

    new window.hlib.Ajax
      url:		'/talk/posts'
      handlers:
        h200:		(response, ajax) ->
          window.hlib.INFO._hide()

          __per_post = (p) ->
            d = new Date (p.stamp * 1000)
            p.stamp_formatted = d.strftime '%d/%m %H:%M'

          __per_post p for p in response.posts
          $(t.eid + '_posts').html (window.hlib.render window.settlers.templates.talk.posts, response)

  show: () ->
    t = @

    __call_update = () ->
      t.update()

    t.update()
    $(@eid).dialog 'open'

    @visible = true

    $(@eid).everyTime '60s', __call_update

  hide: () ->
    if not @visible
      return

    $(@eid).stopTime()

    $(@eid).dialog 'close'

    @visible = false

#
# Methods
#
window.settlers.render_board_piece = (attrs) ->
  return '<span ' + ((attr_name + '="' + attr_value + '"' for own attr_name, attr_value of attrs).join ' ') + '></span>'

window.settlers.show_menu_alert = (item, cnt) ->
  eid = '#' + item + ' .menu-alert'

  if cnt
    $(eid).html cnt

  $(eid).show()

window.settlers.hide_menu_alert = (item) ->
  eid = '#' + item + ' .menu-alert'

  $(eid).hide()

window.settlers.autocomplete_options = () ->
  __autocomplete_callback = (req, res) ->
    new window.hlib.Ajax
      url:		'/users_by_name'
      show_spinner:	false
      data:
        term:		req.term
      handlers:
        h200:		(response, ajax) ->
          window.hlib.INFO._hide()
          res response.users
        error:		(response, ajax) ->
          window.hlib.INFO._hide()
          res []

  options =
    minLength:          3
    source:             __autocomplete_callback

  return options

window.settlers.setup_chat_form = (opts) ->
  new window.hlib.Form
    fid:			'chat_post'
    clear_fields:		['text']
    handlers:
      s200:   (response, form) ->
        form.info.success 'Posted'
        opts.handlers.h200()

window.settlers.setup_chat = (opts) ->
  pager = new window.hlib.Pager
    id_prefix:		opts.id_prefix
    url:		opts.url
    data:		opts.data
    template:		window.settlers.templates.chat_post
    eid:		opts.eid
    start:		0
    length:		20

  pager.refresh()

  return pager

window.settlers.startup = () ->
  window.hlib.setup_common
    info_dialog:
      eid:                    '.info-dialog'

  window.settlers.PULL_NOTIFY = new window.settlers.PullNotify
  window.settlers.TALK = new window.settlers.Talk '#talk_dialog'

  window.settlers.setup_settlers()
  window.settlers.setup_page()

  if window.settlers.user
    window.settlers.PULL_NOTIFY.update()

#
# Bind startup event
#
$(window).bind 'hlib_startup', window.settlers.startup
