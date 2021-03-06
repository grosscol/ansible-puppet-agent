# Ansible Puppet Agent Role
Install and minimally configure puppet-agent.

## Use

1. Create your inventory file under inventory/
1. Make sure at least one of the two variables that configure resolving puppet master is defined.
    * `pa_master_addr`
    * `pa_master_fqdn`
1. Make sure your puppetserver is up, running, and accessible on port 8140
1. Run
    ```
    ansible-playbook -i inventory/yourinventory agent.playbook.yml
    ```

## Vagrant testing

1. Start up Vagrant
    ```sh
    
    vagrant up
    ```
Both variables `pa_master_ip` and `pa_master_fqdn` are defined in the Vagrant file.
The fqdn is set to `puppet` which is the hostname that will be written into `/etc/hosts` when the ip is specified.
This arrangement means that the agent will use the specified fqdn (puppet) and that the ip address for that can be resolved using the hosts file.
The specified fqdn is used. If changing it to something else, make sure dns or hosts will resolve the new fqdn.

### hiera, puppetdb, and r10k demo in vagrant
Starting with a fresh set of vms that have been provisioned.

1. SSH into the puppetserver host.
    ```sh
    vagrant ssh puppet
    ```
2. Swith user to root. 
    ```sh 
    sudo su -
    ```
3. Run the puppet agent on the puppet server node.  Notice the configuration version being applied is numeric timestamp (posix time).
    ```sh
    
    puppet agent --test -v
    ```
3. Examine custom data stuffed into puppetdb. The following examples are custom data where the source is in hiera (`/etc/puppetlabs/code/environments/production/hieradata/`), the tags get applied via a custom class umich::taghosts, and that gets collected into puppetdb to be ~conveniently~ querried.
  * The taghost tags for the puppet host
      ```sh
      
      curl -X POST http://localhost:8080/pdb/query/v4/resources \
      -H 'Content-Type:application/json' \
      -d '{"query": [ "extract", ["certname", "parameters"], [ "and", [ "=", "title", "Umich::Taghosts"], [ "~", "certname", "^puppet" ] ] ] }' \
      | jq '.'
      ```
    the result should look something like the following
      ```json
      
			[
				{
					"certname": "puppet.umdl.umich.edu",
					"parameters": {
						"tags": [
							"minimal"
						]
					}
				}
			]
      ```
  * The unique tags of the resources that also contain the tag "umich::taghosts"
      ```sh
      
      curl -X POST http://localhost:8080/pdb/query/v4/resources \
      -H 'Content-Type:application/json' \
      -d '{"query":["extract", ["tags"], ["=","tag","umich::taghosts"] ]}' | jq 'map(.tags)|add|unique'
      ```
4. Make a copy of the existing puppet environment so you can compare the differences after deploying with r10k.
    ```sh
    
    cp -r /etc/puppetlabs/code/environments/production /opt/repos/archived-puppet-production
    ```
4. Run r10k to update the puppet environment. This will replace the existing code and hiera config with that from the control repo. Compare the new production environment to the archived directory to see what changes were made.
    ```sh
    
    r10k deploy environment production -v
    ```
5. Run librarian-puppet to resolve dependencies of puppet modules in the Puppetfile and install them.
    ```sh
    
    cd /etc/puppetlabs/code/environments/production
    librarian-puppet install --verbose
    ```
6. Manually run puppet agent.  Notice that the configuration version is now the SHA of a commit.
    ```sh
    
    puppet agent --test -v
    ```
6. Check the sha1 of the head of the production branch of the repository r10k pulled from.  This should match the configuration version puppet reported applying in the previous step.
    ```sh
    
    git --git-dir /opt/repos/control-repo/.git rev-list --max-count=1 production
    ```
7. Re-run puppet db query for tags for puppet host.
    ```sh
    
    curl -X POST http://localhost:8080/pdb/query/v4/resources \
    -H 'Content-Type:application/json' \
    -d '{"query": [ "extract", ["certname", "parameters"], [ "and", [ "=", "title", "Umich::Taghosts"], [ "~", "certname", "^puppet" ] ] ] }' \
    | jq '.'
    ```
    The result should now look something like the following
    ```json
    
		[
			{
				"certname": "puppet.umdl.umich.edu",
				"parameters": {
					"tags": [
						"debian",
						"jessie",
						"dev",
						"physical",
						"hydra",
						"macc",
						"linux"
					]
				}
			}
		]
    ```

