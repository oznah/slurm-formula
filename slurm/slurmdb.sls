{% from "slurm/map.jinja" import slurm with context %}

include:
  - slurm.config
  - munge

# install slurm database pkgs
install_slurmdb:
  pkg.installed:
    - pkgs:
      - {{ slurm.pkgSlurmDbd }}
      - {{ slurm.pkgSlurmSQL }}
      - {{ slurm.pkgSlurm }}

# salt requires a few things to be able to config the database
# MySQL-python and mariadb (NOTE: mysql server not setup here)
install_slurmdb_prereq:
  pkg.installed:
    - pkgs:
      - {{ slurm.pkgMySQLpython }}
      - {{ slurm.pkgMySQL }}

# salt database connection params
push_dbconfig:
  file.managed:
    - name: /etc/salt/minion.d/database.conf
    - source: salt://slurm/files/database.conf
    - template: jinja
    - mode: 0644

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
{% set mysql_rootpass = salt['pillar.get']('mysql:RootPass', '') %}

create_{{ slurm.slurmdbd.StorageLoc }}:
  mysql_database.present:
    - name: {{ slurm.slurmdbd.StorageLoc }}

create_slurm_mysqluser:
  mysql_user.present:
    - name: {{ slurm.slurmdbd.StorageUser }}
    - host: {{ slurm.slurmdbd.StorageHost }}
    - password: {{ slurm.slurmdbd.StoragePass }}
    
grants_{{ slurm.slurmdbd.StorageLoc }}_local:
  mysql_grants.present:
    - grant: all
    - database: {{ slurm.slurmdbd.StorageLoc }}.*
    - user: {{ slurm.slurmdbd.StorageUser }}
    - host: localhost

grants_{{ slurm.slurmdbd.StorageLoc }}:
  mysql_grants.present:
    - grant: all
    - database: {{ slurm.slurmdbd.StorageLoc }}.*
    - user: {{ slurm.slurmdbd.StorageUser }}
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
    - name: /usr/bin/sacctmgr -i add cluster {{ slurm.logging_accounting.ClusterName }} && echo {{ slurm.logging_accounting.ClusterName }} >> /etc/slurm/.clusters
    - unless: grep -i {{ slurm.logging_accounting.ClusterName }} /etc/slurm/.clusters
