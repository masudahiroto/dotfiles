(doom!
 :completion
 vertico

 :ui
 doom
 doom-dashboard
 modeline
 ophints
 (popup +defaults)
 vc-gutter

 :editor
 evil
 file-templates
 fold
 snippets

 :emacs
 dired
 electric
 undo
 vc

 :term
 vterm

 :checkers
 syntax

 :tools
 editorconfig
 (eval +overlay)
 lookup
 lsp
 magit
 tree-sitter

 :lang
 emacs-lisp
 json
 markdown
 (javascript +lsp +tree-sitter)
 org
 sh
 yaml

 :config
 (default +bindings +smartparens))
