#!/bin/bash

# Vérifier si les tokens sont définis
if [[ -z "${LD_TALEND_READ_TOKEN}" ]]; then
  echo "LD_TALEND_READ_TOKEN is not defined. Please define it before running the script."
  exit 1
fi

echo "deleting local project..."
rm -rf ./source/project
# export Stitch project
echo "Exporting stitch project..."
deno run --allow-env --allow-read --allow-net --allow-write source.ts -p stitch -k $LD_TALEND_READ_TOKEN
echo "Exporting talend-cloud project..."
deno run --allow-env --allow-read --allow-net --allow-write source.ts -p talend-cloud -k $LD_TALEND_READ_TOKEN

echo "Both stitch and talend-cloud projects have been exported."
