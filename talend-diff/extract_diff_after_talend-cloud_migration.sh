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

rm qlik*.* talend*.*

# get Talend and Qlik flags
curl -H "Authorization: $LD_TALEND_READ_TOKEN" https://app.launchdarkly.com/api/v2/flags/talend-cloud > talend-cloud_flags.json
#change the token with the destination token
curl -H "Authorization: $LD_QLIK_READ_TOKEN" https://app.launchdarkly.com/api/v2/flags/talend-cloud > qlik_talend-cloud_flags.json

# beautify jsons
jq '.' qlik_talend-cloud_flags.json > qlik_talend-cloud_flags_formatted.json ;
jq '.' talend-cloud_flags.json > talend-cloud_flags_formatted.json

# replace the new Qlik project with the one in Talend
sed 's/migrate-talend-cloud/talend-cloud/g' qlik_talend-cloud_flags_formatted.json > qlik_talend-cloud_flags_updated.json

# Extract the items and delete all specifed attributs whatever the neted level
jq 'walk(if type == "object" then del(.includeInSnippet, ._debugEventsUntilDate, .version, ._id, .creationDate, .maintainerId, ._links, ._maintainer, ._siteId, ._version, .lastModified, .salt, .sel, ._summary) else . end) | .items[]' talend-cloud_flags_formatted.json > talend-cloud_clean.json ;
jq 'walk(if type == "object" then del(.includeInSnippet, ._debugEventsUntilDate, .version, ._id, .creationDate, .maintainerId, ._links, ._maintainer, ._siteId, ._version, .lastModified, .salt, .sel, ._summary) else . end) | .items[]' qlik_talend-cloud_flags_updated.json > qlik_talend-cloud_clean.json

echo -e "\nhere is the diff"
diff talend-cloud_clean.json qlik_talend-cloud_clean.json
echo -e "\nextracted flags completed and cleaned, you can now compare the two files"
echo "talend-cloud_clean.json and qlik_talend-cloud_clean.json"

