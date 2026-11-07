# Emacs development workflow

These are the project and code-navigation keys configured in `init.el`.

## Projects and buffers

| Key | Action |
|---|---|
| `C-c p p` | Open the project command menu |
| `C-c p f` | Find a file in the current project |
| `C-c p g` | Search project text with ripgrep |
| `C-c p b` | Switch between buffers in the current project |
| `C-c b` | Switch between any open buffers |
| `C-c p i` | Jump to a symbol in the current file |

Emacs learns projects when you visit files inside them. If a repository is
not listed yet, open one of its files first or use `M-x project-remember-project`.

## Definitions, references, and diagnostics

| Key | Action |
|---|---|
| `M-.` | Go to the exact definition of the symbol at point |
| `M-,` | Return to the previous location |
| `C-c x d` | Go to definition |
| `C-c x r` | Find references to the symbol |
| `C-c x a` | Show applicable code actions |
| `C-c x n` | Go to the next diagnostic |
| `C-c x p` | Go to the previous diagnostic |
| `C-c x l` | List diagnostics in the current buffer |

These Eglot features require a language server for the current language.
Without one, `M-.` may report that no Xref backend is available. Code actions
are server-provided fixes or refactorings, such as “organize imports” or
“rename symbol”; they are not the same as searching text.

## Ruby REPL

In a Ruby buffer:

| Key | Action |
|---|---|
| `C-c C-d` | Send the current line to IRB |
| `C-c C-a` | Send the active region to IRB |
| `C-c C-r` | Send the whole buffer to IRB |

The Eglot warning about `solargraph` or `ruby-lsp` means the Ruby language
server is not installed. The configuration now waits silently until one is
available. IRB evaluation does not require Eglot.

## Search versus references

`C-c p g` uses ripgrep and finds literal text anywhere in the project. It is
fast and works without language tooling, but it cannot know whether two names
refer to the same symbol. `C-c x r` asks the language server for semantic
references, so it can exclude unrelated text, but it requires a working
language server and project configuration.
