push_cgroupconf:
  file.managed:
    - name:  /etc/slurm/cgroup.conf
    - source: salt://slurm/files/cgroup.conf.jinja
    - user:  slurm
    - group:  slurm
    - template: jinja
