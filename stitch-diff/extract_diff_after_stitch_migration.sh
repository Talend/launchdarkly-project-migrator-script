#!/bin/bash

# Vérifier si les tokens sont définis
if [[ -z "${LD_TALEND_READ_TOKEN}" ]]; then
  echo "LD_TALEND_READ_TOKEN is not defined. Please define it before running the script."
  exit 1
fi

if [[ -z "${LD_QLIK_READ_TOKEN}" ]]; then
  echo "LD_QLIK_READ_TOKEN is not defined. Please define it before running the script."
  exit 1
fi

rm qlik*.* stitch*.*

# get Talend and Qlik flags
curl -H "Authorization: $LD_TALEND_READ_TOKEN" https://app.launchdarkly.com/api/v2/flags/stitch > stitch_flags.json
#change the token with the destination token
curl -H "Authorization: $LD_QLIK_READ_TOKEN" https://app.launchdarkly.com/api/v2/flags/stitch-qlik > qlik_stitch_flags.json

# beautify jsons
jq '.' qlik_stitch_flags.json > qlik_stitch_flags_formatted.json ;
jq '.' stitch_flags.json > stitch_flags_formatted.json

# replace the new Qlik project with the one in Talend
sed 's/stitch-qlik/stitch/g' qlik_stitch_flags_formatted.json > qlik_stitch_flags_updated.json

# Extract the items and delete all specifed attributs whatever the neted level
jq 'walk(if type == "object" then del(.includeInSnippet, ._debugEventsUntilDate, .version, ._id, .creationDate, .maintainerId, ._links, ._maintainer, ._siteId, ._version, .lastModified, .salt, .sel, ._summary) else . end) | .items[]' stitch_flags_formatted.json > stitch_clean.json ;
jq 'walk(if type == "object" then del(.includeInSnippet, ._debugEventsUntilDate, .version, ._id, .creationDate, .maintainerId, ._links, ._maintainer, ._siteId, ._version, .lastModified, .salt, .sel, ._summary) else . end) | .items[]' qlik_stitch_flags_updated.json > qlik_stitch_clean.json

echo -e "\nhere is the diff"
diff stitch_clean.json qlik_stitch_clean.json
echo -e "\nextracted flags completed and cleaned, you can now compare the two files"

echo "stitch_clean.json and qlik_stitch_clean.json"


