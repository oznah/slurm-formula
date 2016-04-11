{% from "slurm/map.jinja" import slurm with context %}
{% from "slurm/map.jinja" import pkgs with context %}

include:
  - slurm.config

install_slurmworker:
  pkg.installed:
    - pkgs:
    {% for key, value in pkgs.iteritems() %}
      {% if 'Slurm' in key %}
      {# install all slurm packages #}
      - {{ value }}
      {% else %}
      {% endif %}
    {% endfor %}

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
      - user: slurm
      - group: slurm

start_slurmd:
  service.running:
    - enable: True
    - name: slurmd
    - require:
      - user: slurm
      - group: slurm
