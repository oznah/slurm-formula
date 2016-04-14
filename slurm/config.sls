install_slurm:
  pkg.installed:
    - name: slurm

groupadd_slurm:
  group.present:
    - name: slurm
    - gid: 47

useradd_slurm:
  user.present:
    - name: slurm
    - uid: 47
    - gid: 47

mkdir_slurmlog:
  file.directory:
    - name: /var/log/slurm
    - user: slurm
    - group: slurm
    - mode: 0750
    - makedirs: True

push_slurmconf:
  file.managed:
    - name: /etc/slurm/slurm.conf
    - source: salt://slurm/files/slurm.conf.jinja
    - user: root
    - group: root
    - mode: 0644
    - template: jinja

push_cgroupconf:
  file.managed:
    - name:  /etc/slurm/cgroup.conf
    - source: salt://slurm/files/cgroup.conf.jinja
    - user:  slurm
    - group:  slurm
    - template: jinja
