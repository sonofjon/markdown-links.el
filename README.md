# markdown-links

Insert Markdown links from various sources.

## Contents

- [Description](#description)
- [Installation](#installation)
- [Usage](#usage)
- [Requirements](#requirements)

## Description

This tiny Emacs package provides five interactive commands:

  - `markdown-links-insert-from-files`
    Prompt for a file and link to it.

  - `markdown-links-insert-from-buffers`
    Prompt for an open buffer and link to its file.

  - `markdown-links-insert-from-project`
    Link to _all_ files in the current `project.el` project.

  - `markdown-links-insert-from-git`
    Link to _all_ files tracked by Git in the current repository.

  - `markdown-links-insert-from-dired`
    In Dired, link to marked files (with optional recursion into
    directories), and then insert them in a chosen buffer.

All commands insert inline links at point (or at point in a target buffer).

## Installation

```elisp
(use-package markdown-links
  ;; Load from a local copy
  :load-path "/path/to/markdown-links.el"
  ;; ... or clone from the GitHub
  ;; :vc (:url "https://github.com/sonofjon/markdown-links.el"
  ;;          :rev :newest)
  :commands (markdown-links-insert-from-files
             markdown-links-insert-from-buffers
             markdown-links-insert-from-project
             markdown-links-insert-from-git
             markdown-links-insert-from-dired)
  :bind (:map markdown-mode-map
         ("C-c C-a f" . markdown-links-insert-from-files)
         ("C-c C-a b" . markdown-links-insert-from-buffers)
         ("C-c C-a p" . markdown-links-insert-from-project)
         ("C-c C-a g" . markdown-links-insert-from-git)
         :map dired-mode-map
         ("C-c C-a d" . markdown-links-insert-from-dired)))
```

## Usage

### In a Markdown buffer

Run any of these commands to insert links at point in your current Markdown
buffer:

- `M-x markdown-links-insert-from-files`
- `M-x markdown-links-insert-from-buffers`
- `M-x markdown-links-insert-from-project`
- `M-x markdown-links-insert-from-git`

### In a Dired buffer

Run this command from within Dired to pick marked files (or recurse into
directories) and insert links at point in a target buffer:

- `M-x markdown-links-insert-from-dired`

## Requirements

- Emacs 30.1+
- [markdown-mode](https://melpa.org/#/markdown-mode) ≥ 2.7
- A working Git command in `PATH` for `markdown-links-insert-from-git`.
