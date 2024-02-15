#!/bin/bash

# Vérifier si les tokens sont définis
if [[ -z "${LD_QLIK_WRITE_TOKEN}" ]]; then
  echo "LD_QLIK_WRITE_TOKEN is not defined. Please define it before running the script."
  exit 1
fi

# import talend-cloud project
echo "importing talend-cloud project and environments in to talend-cloud-qlik project..."
deno run --allow-env --allow-read --allow-net --allow-write migrate-projects.ts -p talend-cloud -k $LD_QLIK_WRITE_TOKEN -d talend-cloud-qlik 2>&1 | tee import_talend-cloud_project.log

if [ $? -ne 0 ]; then
  echo "An error occurred while running the deno command."
else
  echo "talend-cloud projects import is over, check the logs : import_talend-cloud_project.log."
fi
