<%!
  import hlib
%>

<%inherit file="page.mako" />

<%namespace file="hlib_ui.mako" import="*" />
<%namespace file="lib.mako" import="*" />

${ui_page_header('Settlers')}

${ui_row_start(span = 6)}
  ${ui_form_start(action = '/login/login', id = 'login', legend = 'Game login')}
    ${ui_input(type = 'text', label = 'Login name', form_name = 'username')}
    ${ui_input(type = 'password', label = 'Password', form_name = 'password')}
    ${ui_submit(value = 'Log in')}
  ${ui_form_end()}
${ui_row_end()}
