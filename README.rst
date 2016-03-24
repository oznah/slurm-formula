Slurm
-----

The Simple Linux Utility for Resource Management (Slurm) is an open
source, fault-tolerant, and highly scalable cluster management and job
scheduling system for large and small Linux clusters. `More
info. <http://www.schedmd.com/slurmdocs/slurm.html>`__

Install and configure slurm controller/master, worker, and database.

See the full `Salt formulas installation and usage
instructions <https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`__

**Note:** Tested on RHEL 7 only.

Available States
~~~~~~~~~~~~~~~~

-  `slurm <#slurm>`__
-  `slurm.build <#slurm.build>`__
-  `slurm.config <#slurm.config>`__
-  `slurm.controller <#slurm.controller>`__
-  `slurm.slurmdb <#slurm.slurmdb>`__
-  `slurm.worker <#slurm.worker>`__

slurm
^^^^^

Meta-state that adds config and installs slurm worker packages.

slurm.build
^^^^^^^^^^^

Install packages needed to build slurm rpms.

slurm.config
^^^^^^^^^^^^

-  Create slurm user and group.
-  make ``/var/log/slurm`` folder
-  create master slurm.conf file ``/etc/slurm/slurm.conf``

slurm.controller
^^^^^^^^^^^^^^^^

Install slurmctld related packages, start service, create spool
directory, and add log file.

slurm.slurmdb
^^^^^^^^^^^^^

-  Install slurmdbd and slurmsql packages, start services, create
   slurmdbd.conf, and add log file.
-  Create slurm accounting db

\*\* Requires: \*\* mariadb-server already be installed & mysql root
password in pillar.

slurm.worker
^^^^^^^^^^^^

Install slrumd worker packages, start service, create spool directory,
and add log file.
