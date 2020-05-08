Container-hosted testing for moxie-elf-gcc
============================================

This repo contains both the test container sources (Dockerfile, etc),
as well as the ansible playbook for executing test runs in an
OpenShift environment.

Other notes:

* credentials are stored in an OpenShift hosted hashicorp vault.
* results are mailed to gcc-testresults@gcc.gnu.org.
* results are also stored in a git repo for archiving and regression comparison purposes.


Anthony Green <green@moxielogic.com>


