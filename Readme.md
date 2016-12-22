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


