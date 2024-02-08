#!/bin/bash

# Vérifier si les tokens sont définis
if [[ -z "${LD_QLIK_WRITE_TOKEN}" ]]; then
  echo "LD_QLIK_WRITE_TOKEN is not defined. Please define it before running the script."
  exit 1
fi

# import Stitch flags
echo "importing stitch segments and flags..."
deno run --allow-env --allow-read --allow-net --allow-write migrate-flags.ts -p stitch -k $LD_QLIK_WRITE_TOKEN -d stitch 2>&1 | tee import_stitch_flags.log


if [ $? -ne 0 ]; then
  echo "An error occurred while running the deno command."
else
  echo "stitch flags and segments import is over, check the logs : import_stitch_flags.log"
fi

