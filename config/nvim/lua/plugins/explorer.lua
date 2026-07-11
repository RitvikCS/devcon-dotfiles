-- Snacks explorer: focus the file LIST on open instead of the search input.
-- The file-op keys (a=add, d=delete, r=rename, c=copy, m=move) are defined on
-- the list window only — with focus in the input box, `a` is just vim's
-- "append" and drops you back into the search field.
-- Focus switching either way: Alt+w cycles input <-> list; `i` from the list
-- jumps to the input to filter.
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          focus = "list",
        },
      },
    },
  },
}
