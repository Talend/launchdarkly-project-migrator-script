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
rm ./source/project/stitch/flag.json
rm ./source/project/stitch/segment*.json


# export Stitch segments and flags
echo "exporting stitch segments and flags locally..."
deno run --allow-env --allow-read --allow-net --allow-write source-segments-flags.ts -p stitch -k $LD_TALEND_READ_TOKEN


# import Stitch segments and flags
echo "importing stitch segments and flags into stitch-qlik project..."
deno run --allow-env --allow-read --allow-net --allow-write migrate-segments-flags.ts -p stitch -k $LD_QLIK_WRITE_TOKEN -d stitch-qlik 2>&1 | tee import_stitch_flags.log


if [ $? -ne 0 ]; then
  echo "An error occurred while running the deno command."
else
  echo "stitch flags and segments import is over, check the logs : import_stitch_flags.log"
fi

