[![Build Status](https://travis-ci.org/CSC-IT-Center-for-Science/ansible-role-disk-scheduler.svg?branch=master)](https://travis-ci.org/CSC-IT-Center-for-Science/ansible-role-disk-scheduler)

ansible-role-disk-scheduler
=========

Configures IO scheduler on all the disks (common option: noop, deadline or cfq)

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

Inspiration taken from https://gist.github.com/keithchambers/80b60559ad83cebf1672
