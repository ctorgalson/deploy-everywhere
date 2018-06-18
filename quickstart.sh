#!/bin/bash

set -e

BASE=$PWD

# Dev server can be provisioned _and_ deployed by `vagrant provision` etc.
cd "$BASE/devops"
echo ""
echo "Booting, provisioning and deploying 'dev-01.deploy.local'..."
echo ""
vagrant up --provision dev

# Prod server relies on `ansible-playbook` for provisioning and deployment.
echo ""
echo "Booting, provisioning and deploying 'prod-01.deploy.local'..."
echo ""
vagrant up --provision prod
ansible-playbook deployment.yml --limit=deploy_prod

# Start up gulp watch task in site directory.
cd "$BASE"
echo ""
echo "Starting `gulp watch` task..."
echo ""
npx gulp watch --cwd ./site/docroot
