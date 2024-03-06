#!/bin/bash


# Vérifier si les tokens sont définis
if [[ -z "${LD_TALEND_READ_TOKEN}" ]]; then
  echo "LD_TALEND_READ_TOKEN is not defined. Please define it before running the script."
  exit 1
fi

if [[ -z "${LD_QLIK_WRITE_TOKEN}" ]]; then
  echo "LD_QLIK_WRITE_TOKEN is not defined. Please define it before running the script."
  exit 1
fi

#removing old segments and flags
rm ./source/project/talend-cloud/flag.json
rm ./source/project/talend-cloud/segment*.json

# exporting Talend segments and flags
echo "Exporting talend-cloud segments and flags locally..."
deno run --allow-env --allow-read --allow-net --allow-write source-segments-flags.ts -p talend-cloud -k $LD_TALEND_READ_TOKEN


# import talend-cloud flags
echo "importing talend-cloud segments and flags into talend-cloud-qlik project..."
deno run --allow-env --allow-read --allow-net --allow-write migrate-segments-flags.ts -p talend-cloud -k $LD_QLIK_WRITE_TOKEN -d talend-cloud-qlik 2>&1 | tee import_talend-cloud_flags.log


if [ $? -ne 0 ]; then
  echo "An error occurred while running the deno command."
else
  echo "talend-cloud flags and segments import is over, check the logs : import_stitch_flags.log"
fi

