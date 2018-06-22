#!/bin/bash

set -e

BASE=$PWD

# Dev server can be provisioned _and_ deployed by `vagrant provision`.
cd "$BASE/devops"
echo "deploy everywhere" > .deploy-vault
echo ""
echo "Booting, provisioning and deploying 'dev-01.deploy.local'..."
echo ""
vagrant up dev

# Prod server relies on `ansible-playbook` for provisioning and deployment.
echo ""
echo "Booting, provisioning and deploying 'prod-01.deploy.local'..."
echo ""
vagrant up prod
ansible-playbook deployment.yml --limit=deploy_prod

echo "Deployment completed in $(ps -e -o etime $$ | sed -n '2p' | xargs)."

# Start up gulp watch task in site directory.
cd "$BASE"
echo ""
echo "Starting `gulp watch` task..."
echo ""
npx gulp watch --cwd ./site/docroot
