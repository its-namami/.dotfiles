# Emacs development workflow

These are the project and code-navigation keys configured in `init.el`.

## General

| Key | Action |
|---|---|
| `C-c b` | Switch between any open buffers |
| `C-c o` | Open the current file in the default browser |
| `C-c t` | Open vterm |
| `M-o` | Switch to the other window |
| `M-g f` | Jump to a line with Avy |
| `C-;` | Jump to a character with Avy |

## Projects and buffers

| Key | Action |
|---|---|
| `C-c p p` | Discover and choose a repository under `~/repos` |
| `C-c p f` | Find a file in the current project |
| `C-c p g` | Search project text with ripgrep |
| `C-c p b` | Switch between buffers in the current project |
| `C-c p i` | Jump to a symbol in the current file |

Emacs learns projects when you visit files inside them. If a repository is
not listed yet, open one of its files first or use
`M-x project-remember-project`.

## Definitions, references, diagnostics, and formatting

| Key | Action |
|---|---|
| `M-.` | Go to the exact definition of the symbol at point |
| `M-,` | Return to the previous location |
| `C-c x d` | Go to definition |
| `C-c x r` | Find references to the symbol |
| `C-c x a` | Show applicable code actions |
| `C-c x h` | Show documentation at point |
| `C-c x n` | Go to the next diagnostic |
| `C-c x p` | Go to the previous diagnostic |
| `C-c x l` | List diagnostics in the current buffer |
| `C-c f b` | Format the entire buffer through Eglot |
| `C-c f r` | Format the active region through Eglot |

These Eglot features require a language server for the current language.
Code actions and formatting are optional server capabilities.

## Ruby REPL and style checks

| Key | Action |
|---|---|
| `C-c C-d` | Send the current Ruby line to IRB |
| `C-c C-a` | Send the active region to IRB |
| `C-c C-r` | Send the whole Ruby buffer to IRB |
| `C-c r c` | Check the current Ruby file with RuboCop |
| `C-c r a` | Autocorrect safe RuboCop offenses |

RuboCop checks are on demand. IRB evaluation does not require Eglot.

## Markdown

| Key | Action |
|---|---|
| `C-c m p` | Preview Markdown with `markdown-mode` |
| `C-c m l` | Toggle live Markdown preview |
| `C-c m e` | Export and preview Markdown as HTML |
| `C-c m g` | Open a GitHub-style Grip preview |

`C-c m g` requires Grip, installed with
`python3 -m pip install --user grip`. It opens the preview in the default
browser and preserves local images and relative links.

## HTML and CSS

| Key | Action |
|---|---|
| `C-c e` | Expand an Emmet abbreviation |

Emmet is enabled in HTML, CSS, and SCSS buffers.

## JavaScript exercises

| Key | Action |
|---|---|
| `C-c j t` | Run the Jest spec matching the current JavaScript exercise |

The command finds the nearest `package.json`, derives the matching `.spec.js`
filename, and runs it with `npm test`.

## Search versus references

`C-c p g` uses ripgrep and finds literal text anywhere in the project. It is
fast and works without language tooling, but it cannot know whether two names
refer to the same symbol. `C-c x r` asks the language server for semantic
references, so it can exclude unrelated text, but it requires a working
language server and project configuration.
