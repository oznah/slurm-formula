{% from "slurm/map.jinja" import slurm with context %}

include:
  - slurm.config
  - munge

install_slurmworker:
  pkg.installed:
    - pkgs:
      - {{ slurm.pkgSlurm }}
      - {{ slurm.pkgSlurmDevel }}
      - {{ slurm.pkgSlurmMunge }}
      - {{ slurm.pkgSlurmPlugins }}
      - {{ slurm.pkgSlurmSjobexit }}
      - {{ slurm.pkgSlurmSjstat }}

mkdir_slurmd_spool:
  file.directory:
    - name: {{ slurm.global.SlurmdSpoolDir }}
    - user: slurm
    - group: slurm
    - mode: 0755
    - makedirs: True
    - require:
      - user: slurm
      - group: slurm

touch_slurmd_log:
  file.managed:
    - name: {{ slurm.logging_accounting.SlurmdLogFile }}
    - source: ~
    - user: slurm
    - group: slurm
    - require:
      - file: /var/log/slurm
      - user: slurm
      - group: slurm

start_slurmd:
  service.running:
    - enable: True
    - name: slurmd
    - require:
      - file: /etc/slurm/slurm.conf
      - user: slurm
      - group: slurm
    - watch:
      - file: /etc/slurm/slurm.conf
