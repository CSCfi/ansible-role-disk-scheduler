ansible-role-disk-scheduler
=========

Configures IO scheduler on the disks (noop, deadline, cfq, etc)

Requirements
------------

Linux

Role Variables
--------------

see defaults/main.yml

disk_scheduler: "deadline"

Dependencies
------------


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: ansible-role-disk-scheduler }

License
-------

MIT

Author Information
------------------

