#!/bin/bash

# Vérifier si les tokens sont définis
if [[ -z "${LD_QLIK_WRITE_TOKEN}" ]]; then
  echo "LD_QLIK_WRITE_TOKEN is not defined. Please define it before running the script."
  exit 1
fi

# import talend-cloud project
echo "importing talend-cloud project and environments..."
deno run --allow-env --allow-read --allow-net --allow-write migrate-projects.ts -p talend-cloud -k $LD_QLIK_WRITE_TOKEN -d talend-cloud  | tee import_talend-cloud_project.log

echo "talend-cloud projects have been imported."
