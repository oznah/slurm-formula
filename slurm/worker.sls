{% from "slurm/map.jinja" import slurm with context %}
{% from "slurm/map.jinja" import pkgs with context %}

include:
  - slurm.config
  - munge

install_slurmworker:
  pkg.installed:
    - pkgs:
      - {{ pkgs.Slurm }}
      - {{ pkgs.SlurmDevel }}
      - {{ pkgs.SlurmMunge }}
      - {{ pkgs.SlurmPerlapi }}
      - {{ pkgs.SlurmPlugins }}
      - {{ pkgs.SlurmSjobexit }}
      - {{ pkgs.SlurmSjstat }}
      - {{ pkgs.SlurmTorque }}

mkdir_slurmd_spool:
  file.directory:
    - name: {{ slurm.SlurmdSpoolDir }}
    - user: slurm
    - group: slurm
    - mode: 0755
    - makedirs: True
    - require:
      - user: slurm
      - group: slurm

touch_slurmd_log:
  file.managed:
    - name: {{ slurm.SlurmdLogFile }}
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
