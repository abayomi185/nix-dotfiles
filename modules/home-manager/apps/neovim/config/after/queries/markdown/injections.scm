; extends

((html_block) @injection.content
  (#lua-match? @injection.content "^%s*<[A-Z]")
  (#set! injection.language "typescriptreact"))
