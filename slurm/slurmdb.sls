{% from "slurm/map.jinja" import slurm with context %}
{% from "slurm/map.jinja" import pkgs with context %}
{% from "slurm/map.jinja" import slurmdbd with context %}

include:
  - slurm.config

# install slurm database pkgs
install_slurmdb:
  pkg.installed:
    - pkgs:
    {% for key, value in pkgs.iteritems() %}
      {% if 'Slurm' in key %}
      {# install all slurm packages #}
      - {{ value }}
      {% else %}
      {% endif %}
    {% endfor %}

# salt requires a few things to be able to config the database
# MySQL-python and mariadb (NOTE: mysql server not setup here)
install_slurmdb_prereq:
  pkg.installed:
    - pkgs:
      - {{ pkgs.MySQLpython }}
      - {{ pkgs.MySQL }}

# salt database connection params
# this is needed so the salt minion can connect to mysql
# since this is a minion config it should be defined in a different sls
# https://docs.saltstack.com/en/latest/ref/states/all/salt.states.mysql_user.html
#
# push_dbconfig:
#   file.managed:
#     - name: /etc/salt/minion.d/database.conf
#     - source: salt://slurm/files/database.conf
#     - template: jinja
#     - mode: 0644

touch_slurmdbd_log:
  file.managed:
    - name: {{ slurmdbd.LogFile }}
    - source: ~
    - replace: False
    - user: slurm
    - group: slurm
    - require:
      - file: /var/log/slurm
      - user: slurm
      - group: slurm

push_slurmdbdconf:
  file.managed:
    - name: /etc/slurm/slurmdbd.conf
    - source: salt://slurm/files/slurmdbd.conf.jinja
    - user: root
    - group: root
    - mode: 0644
    - template: jinja

push_slurmdb_logrotate:
  file.managed:
    - name: /etc/logrotate.d/slurmdbd
    - source: salt://slurm/files/slurmdbd.logrotate
    - user: root
    - group: root
    - mode: 0644

# setup database before starting slurmdbd
{% set mysql_rootpass = salt['pillar.get']('mysql:RootPass', '') %}

create_{{ slurmdbd.StorageLoc }}:
  mysql_database.present:
    - name: {{ slurmdbd.StorageLoc }}

create_slurm_mysqluser:
  mysql_user.present:
    - name: {{ slurmdbd.StorageUser }}
    - host: {{ slurmdbd.StorageHost }}
    - password: {{ slurmdbd.StoragePass }}
    
grants_{{ slurmdbd.StorageLoc }}_local:
  mysql_grants.present:
    - grant: all
    - database: {{ slurmdbd.StorageLoc }}.*
    - user: {{ slurmdbd.StorageUser }}
    - host: localhost

grants_{{ slurmdbd.StorageLoc }}:
  mysql_grants.present:
    - grant: all
    - database: {{ slurmdbd.StorageLoc }}.*
    - user: {{ slurmdbd.StorageUser }}
    - host: {{ salt['grains.get']('host', '') }}

start_slurmdbd:
  service.running:
    - enable: True
    - name: slurmdbd
    - require:
      - file: /etc/slurm/slurmdbd.conf
      - user: slurm
      - group: slurm
    - watch:
      - file: /etc/slurm/slurmdbd.conf

sacctadd_cluster:
  cmd.run:
    - name: /usr/bin/sacctmgr -i add cluster {{ slurm.ClusterName }} && echo {{ slurm.ClusterName }} >> /etc/slurm/.clusters
    - unless: grep -i {{ slurm.ClusterName }} /etc/slurm/.clusters
