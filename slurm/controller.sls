{% from "slurm/map.jinja" import slurm with context %}

include:
  - slurm.config

install_slurmmaster:
  pkg.installed:
    - pkgs:
      - slurm
      - slurm-devel
      - slurm-munge
      - slurm-plugins
      - slurm-sjobexit
      - slurm-sjstat

mkdir_slurmctld_spool:
  file.directory:
    - name: {{ slurm.global.StateSaveLocation }}
    - user: slurm
    - group: slurm
    - mode: 0755
    - makedirs: True

mkdir_slurmctld_log:
  file.managed:
    - name: {{ slurm.logging_accounting.SlurmctldLogFile }}
    - source: ~
    - user: slurm
    - group: slurm
    - require:
      - file: /var/log/slurm

start_slurmctld:
  service.running:
    - enable: True
    - name: slurmctld
    - watch:
      - file: /etc/slurm/slurm.conf
