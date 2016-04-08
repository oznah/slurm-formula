{% from "slurm/map.jinja" import slurm with context %}
{% from "slurm/map.jinja" import pkgs with context %}

include:
  - slurm.config

install_slurmmaster:
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

mkdir_slurmctld_spool:
  file.directory:
    - name: {{ slurm.StateSaveLocation }}
    - user: slurm
    - group: slurm
    - mode: 0755
    - makedirs: True

mkdir_slurmctld_log:
  file.managed:
    - name: {{ slurm.SlurmctldLogFile }}
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

reload_slurmctld:
  cmd.wait:
    - name: scontrol reconfigure
    - require:
      - file: /etc/slurm/slurm.conf
    - watch:
      - file: /etc/slurm/slurm.conf


