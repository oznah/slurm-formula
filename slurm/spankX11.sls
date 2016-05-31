install_spankX11:
  pkg.installed:
    - name: slurm-spank-x11

push_plugstack-conf:
  file.managed:
    - name: /etc/slurm/plugstack.conf
    - source: salt://slurm/files/plugstack.conf
    - user: root
    - group: root
    - mode: 0644
