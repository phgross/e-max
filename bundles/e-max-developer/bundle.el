(defun e-max-emdeveloper-find-e-max-config ()
  "Find-file in e-max repository, openeing a new perspective @e-max"
  (interactive)

  (e-max-persp "@e-max")
  (find-file (e-max-ido-open-find-directory-files e-max-repository)))

(defun e-max-emdeveloper-emacs-persp ()
  "Opens the e-max perspective."
  (interactive)
  (e-max-persp "@e-max"))

(global-set-key (kbd "C-c p") 'e-max-emdeveloper-find-e-max-config)
(global-set-key (kbd "C-p e") 'e-max-emdeveloper-emacs-persp)
