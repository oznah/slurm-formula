# login node installs packages and adds slurm user but doesnt start any services
#
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
