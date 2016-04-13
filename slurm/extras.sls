# Extra utilities that are not required but may be help in a production environment
#
# slurm-utils (jobinfo & gnodes)
# https://github.com/birc-aeh/slurm-utils.git
#
push_jobinfo:
  file.managed:
    - name: /usr/local/bin/jobinfo
    - source: salt://slurm/files/jobinfo
    - user: slurm
    - group: slurm
    - mode: 755

push_gnodes:
  file.managed:
    - name: /usr/local/bin/gnodes
    - source: salt://slurm/files/gnodes
    - user: slurm
    - group: slurm
    - mode: 755

# bash completion for slurm
# https://github.com/damienfrancois/slurm-helper.git
#
push_slurm-completion:
  file.managed:
    - name: /etc/bash_completion.d/slurm_completion.sh
    - source: salt://slurm/files/slurm_completion.sh
    - user: root
    - group: root
    - mode: 0644
