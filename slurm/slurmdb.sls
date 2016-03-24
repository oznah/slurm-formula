{% from "slurm/map.jinja" import slurm with context %}

include:
  - slurm.config

install_slurmdb:
  pkg.installed:
    - pkgs:
      - slurm-slurmdbd
      - slurm-sql

touch_slurmdbd_log:
  file.managed:
    - name: {{ slurm.slurmdbd.LogFile }}
    - source: ~
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

# setup database before starting slurmdbd
#
{% set mysql_rootpass = salt['pillar.get']('mysql:RootPass', '') %}

create_{{ slurm.slurmdbd.StorageLoc }}:
  mysql_database.present:
    - name: {{ slurm.slurmdbd.StorageLoc }}
    - connection_pass: {{ mysql_rootpass }}

create_slurm_mysqluser:
  mysql_user.present:
    - name: {{ slurm.slurmdbd.StorageUser }}
    - host: {{ slurm.slurmdbd.StorageHost }}
    - password: {{ slurm.slurmdbd.StoragePass }}
    - connection_pass: {{ mysql_rootpass }}
    
grants_{{ slurm.slurmdbd.StorageLoc }}_local:
  mysql_grants.present:
    - grant: all
    - database: {{ slurm.slurmdbd.StorageLoc }}.*
    - user: {{ slurm.slurmdbd.StorageUser }}
    - host: localhost
    - connection_pass: {{ mysql_rootpass }}

grants_{{ slurm.slurmdbd.StorageLoc }}:
  mysql_grants.present:
    - grant: all
    - database: {{ slurm.slurmdbd.StorageLoc }}.*
    - user: {{ slurm.slurmdbd.StorageUser }}
    - host: {{ salt['grains.get']('host', '') }}
    - connection_pass: {{ mysql_rootpass }}

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

