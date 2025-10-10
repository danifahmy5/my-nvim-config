-- ~/.config/nvim/snippets/blade.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- @if ... @endif
  s("@if", {
    t("@if ("), i(1, "condition"), t({ ")", "" }),
    t({ "", "" }), i(0),
    t({ "", "@endif" }),
  }),

  -- @foreach ... @endforeach
  s("@foreach", {
    t("@foreach ("), i(1, "$items as $item"), t({ ")", "" }),
    t({ "", "" }), i(0),
    t({ "", "@endforeach" }),
  }),

  -- @for ... @endfor
  s("@for", {
    t("@for ("), i(1, "$i = 0; $i < "), i(2, "count"), t("; $i++)"),
    t({ "", "" }), i(0),
    t({ "", "@endfor" }),
  }),

  -- @while ... @endwhile
  s("@while", {
    t("@while ("), i(1, "condition"), t({ ")", "" }),
    t({ "", "" }), i(0),
    t({ "", "@endwhile" }),
  }),

  -- @section ... @endsection
  s("@section", {
    t("@section('"), i(1, "name"), t({ "')", "" }),
    t({ "", "" }), i(0),
    t({ "", "@endsection" }),
  }),

  -- @isset ... @endisset
  s("@isset", {
    t("@isset("), i(1, "$var"), t({ ")", "" }),
    t({ "", "" }), i(0),
    t({ "", "@endisset" }),
  }),

  -- @unless ... @endunless
  s("@unless", {
    t("@unless("), i(1, "condition"), t({ ")", "" }),
    t({ "", "" }), i(0),
    t({ "", "@endunless" }),
  }),
}
