{% from "slurm/map.jinja" import slurm with context %}
{% from "slurm/map.jinja" import pkgs with context %}

include:
  - slurm.config

install_slurmcontroller:
  pkg.installed:
    - pkgs:
    {% for key, value in pkgs.iteritems() %}
      {% if 'Slurm' in key %}
      {# install all slurm packages #}
      - {{ value }}
      {% else %}
      {% endif %}
    {% endfor %}

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
    - source: '~'
    - user: slurm
    - group: slurm
    - require:
      - file: /var/log/slurm

push_slurm_logrotate:
  file.managed:
    - name: /etc/logrotate.d/slurmctld
    - source: salt://slurm/files/slurmctld.logrotate
    - replace: True
    - user: root
    - group: root
    - mode: 0644

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
