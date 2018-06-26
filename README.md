# Deploy Everywhere Ansible Demo site

This repository uses [Ansible] and [Vagrant] to demonstrate how a single build and deployment process can be used to provision and deploy the local, QA, and Production versions of a site.

## Requirements

The minimum set of requirements to run the VMs and playbooks in this repository are:

- [Ansible]
- [Vagrant]
- [VirtualBox]
- [vagrant-hostsupdater]
- [vagrant-vbguest]

Not tested on Windows.

## [quickstart.sh]

If you're the impatient type, and if you already have the various requirements on your system, here's how to get started:

1. `git clone git@github.com:ctorgalson/deploy-everywhere.git`
2. `cd deploy-everywhere && ./quickstart.sh`

This will:

1. Create a new vault password file for Ansible, `.deploy-vault`,
2. Create a new Vagrant vm, `dev`,
3. Sync the contents of `site/docroot` in the repo to the VM,
4. Create a second Vagrant vm, `prod`,
5. Provision `dev` using Ansible,
6. Provision `prod` using Ansible,
7. Run the command `gulp watch` in `site/docroot`.

From scratch, this takes about seven minutes on my venerable 2014 Mac Mini.

You may begin working immediately :)

## Step-by-step Workflow

(To follow _all_ of these steps, you'll need to [fork the repository] first).

1. Clone the repository:

    `git clone git@github.com:ctorgalson/deploy-everywhere.git`

2. Enable `pre-push` githook (optional; see more about what this does [below](#requirements)):

    `cd deploy-everywhere && ln -s .githooks/pre-push .git/hooks/pre-push`

2. Change to the repo directory and create Ansible vault password file:

    `cd deploy-everywhere && echo 'deploy-everywhere' > .deploy-vault`

3. Boot servers (and auto-provision and deploy `dev`):

    `cd devops && vagrant up`

4. Run provisioning and initial deployment to `prod`:

    `ansible-playbook deployment.yml --limit=deploy_prod`

5. Get some work done:
    1. Checkout a new branch:

        `git checkout -b newbranch`

    2. Change to the site directory and start the `gulp watch` task:

        `cd ../site && npx gulp watch`

    3. Make changes in `site/`,
    4. Commit changes:

        `git commit -am 'Committing changes to demo repo.'`

    5. Run deployment test and push changes to remote repo:

        `git push origin newbranch`

6. Deploy changes to `prod`:

    `ansible-playbook deployment.yml --limit=deploy_prod --tags=deploy`

## The servers

The repository includes a [Vagrantfile] that configures two virtual
machines:

- A development server, `dev-01.deploy.local`, and
- A production server, `prod-01.deploy.local`.

### `dev-01` (192.168.101.202)

This server is the local development server. Files from the repository's `site/` directory are automatically synchronized to the virtual machine.

### `prod-01` (172.31.79.50)

This server is provided to illustrate a realistic workflow, including environment variables that differ from those on the local development server. A real project would use a _real_ remote server.

### Running provisioning and deployment on the servers

The repository's `Vagrantfile` defines both servers, but since `prod` is meant to simulate a _remote_ server, we don't use Vagrant to provision it or deploy the application to it. The `dev` server, on the other hand, is our local development server, so we can use either Vagrant commands or Ansible commands to interact with it.

#### Using the `ansible-playbook` command on `dev` or `prod`

We can run the provision play and/or the deployment play on one or both servers:

```
# Run provision and deployment plays on both hosts.
ansible-playbook deployment.yml
```

We can also use the `ansible-playbook` command's `--limit` or `--tags` switches.

##### Limit operations to specific hosts

See [hosts.yml] to see the host and groups names available.

```
# Run provision and deployment plays on `dev`.
ansible-playbook deployment.yml --limit=deploy_dev
```

```
# Run provision and deployment plays on `prod`.
ansible-playbook deployment.yml --limit=deploy_prod
```

##### Limit operations to specific plays

See [deployment.yml] to see the available plays and tags.

```
# Run provision play only both hosts.
ansible-playbook deployment.yml --tags=provision
```

```
# Run deploy play only on both hosts.
ansible-playbook deployment.yml --tags=deploy
```

#### Using Vagrant commands on `dev`

It's also possible to use Vagrant commands to run `ansible-playbook` commands against the `dev` host by setting enviroment variables and then running `vagrant up` or `vagrant provision`. The `Vagrantfile` makes use of two environment variables:

1. `$VAT`: values as for `ansible-playbook`'s `--tags` option.
2. `$VAV`: values as for `ansible-playbook`'s `--verbose` option.

The only operation Vagrant commands can run on both servers is to boot them:

```
# Boot `dev` and `prod`, and run Ansible provisioner on `dev`.
vagrant up
```

```
# Boot `dev` only, and run Ansible provisioner.
vagrant up dev
```

```
# Boot `prod` only.
vagrant up prod
```

##### Limit operations to specific plays

```
# Run only `provision` play on `dev` when vagrant runs for the first time.
VAT=provision vagrant up dev
```

```
# Run only `deploy` play when booting `dev`.
VAT=deploy vagrant up --provision dev
```

```
# Run only `deploy` play on already-booted `dev` host.
VAT=deploy vagrant provision
```

## Githooks

This repository includes a directory, [.githooks] that contains a `pre-push` Git hook. [Git hooks] are generally scripts that correspond to a particular git command (`git push` in this instance), run when that command is issued, and cause the command to fail or continue.

The `pre-push` hook in this repo will only allow the `push` operation to succeed if the current codebase can be successfully deployed to the `dev` server.

[Vagrant]: https://www.vagrantup.com/
[Ansible]: https://www.ansible.com/
[VirtualBox]: https://www.virtualbox.org/
[vagrant-hostsupdater]: https://github.com/cogitatio/vagrant-hostsupdater
[vagrant-vbguest]: https://github.com/dotless-de/vagrant-vbguest
[quickstart.sh]: https://github.com/ctorgalson/deploy-everywhere/blob/master/quickstart.sh
[Vagrantfile]: https://github.com/ctorgalson/deploy-everywhere/blob/master/devops/Vagrantfile
[hosts.yml]: https://github.com/ctorgalson/deploy-everywhere/blob/master/devops/hosts.yml
[deployment.yml]: https://github.com/ctorgalson/deploy-everywhere/blob/master/devops/deployment.yml
[.githooks]: https://github.com/ctorgalson/deploy-everywhere/blob/master/.githooks
[Git hooks]: https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks
