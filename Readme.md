# Ansible Puppet Agent Role
Install and minimally configure puppet-agent.

## Use

1. Create your inventory file under inventory/
1. Make sure at least one of the two variables that configure resolving puppet master is defined.
    ```
    pa_master_addr
    pa_master_fqdn
    ```
1. Make sure your puppetserver is up, running, and accessible on port 8140
1. Run
    ```
    ansible-playbook -i inventory/yourinventory puppet-agent.playbook.yml
    ```

## Vagrant testing

1. Start up Vagrant
    ```
    vagrant up
    ```
Both variables `pa_master_ip` and `pa_master_fqdn` are defined in the Vagrant file.
The fqdn is set to `puppet` which is the hostname that will be written into `/etc/hosts` when the ip is specified.
This arrangement means that the agent will use the specified fqdn (puppet) and that the ip address for that can be resolved using the hosts file.
The specified fqdn is used. If changing it to something else, make sure dns or hosts will resolve the new fqdn.
