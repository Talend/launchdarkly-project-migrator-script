#!/bin/bash

# Vérifier si les tokens sont définis
if [[ -z "${LD_QLIK_WRITE_TOKEN}" ]]; then
  echo "LD_QLIK_WRITE_TOKEN is not defined. Please define it before running the script."
  exit 1
fi

# import Stitch project
echo "importing stitch project and environments into stitch-qlik project..."
deno run --allow-env --allow-read --allow-net --allow-write migrate-projects.ts -p stitch -k $LD_QLIK_WRITE_TOKEN -d stitch-qlik 2>&1 | tee import_stitch_project.log

if [ $? -ne 0 ]; then
  echo "An error occurred while running the deno command."
else
  echo "stitch  projects is over, check the logs : import_stitch_project.log."
fi


