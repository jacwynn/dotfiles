;; extends -- required so Neovim merges this into the base html/highlights.scm
;; query instead of silently replacing it outright (see docs/sfcc.md).

; SFCC/ISML tags (isif, isloop, isset, etc) aren't HTML -- the bundled html
; grammar just treats them as regular/unknown elements, tagged @tag same as
; <div>. Layered in after the base html_tags query (via after/queries, so it
; composes on top rather than replacing it) to recolor just the is*-prefixed
; ones as @keyword instead, since they're effectively SFCC's own template
; control-flow/directive tags, not markup.
;
; Embedded ISML script expressions (e.g. condition="${pdict.foo}") already
; get JS injection+highlighting for free, from html_tags/injections.scm's
; generic "${...}" rule (originally written for lit-html interpolation).
((tag_name) @keyword
  (#match? @keyword "^is[A-Za-z]+$"))
