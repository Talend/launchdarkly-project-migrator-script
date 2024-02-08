#!/bin/bash

# Vérifier si les tokens sont définis
if [[ -z "${LD_QLIK_WRITE_TOKEN}" ]]; then
  echo "LD_QLIK_WRITE_TOKEN is not defined. Please define it before running the script."
  exit 1
fi

# import talend-cloud flags
echo "importing talend-cloud segments and flags..."
deno run --allow-env --allow-read --allow-net --allow-write migrate-flags.ts -p talend-cloud -k $LD_QLIK_WRITE_TOKEN -d talend-cloud 2>&1 | tee import_talend-cloud_flags.log


if [ $? -ne 0 ]; then
  echo "An error occurred while running the deno command."
else
  echo "talend-cloud flags and segments import is over, check the logs : import_stitch_flags.log"
fi

