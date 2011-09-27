(setq e-max-repository (expand-file-name "E-MAX-DIR/"))

;; load the bundle configuration
(load (expand-file-name "~/.emacs.d/bundles.el"))

;; see https://github.com/senny/theme-roller.el for a list of available themes
(setq e-max-theme 'color-theme-lazy)

(load (concat e-max-repository "e-max"))
