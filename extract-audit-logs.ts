import yargs from "https://cdn.deno.land/yargs/versions/yargs-v16.2.1-deno/raw/deno.ts";
import {
  ensureDir,
  ensureDirSync,
} from "https://deno.land/std@0.149.0/fs/mod.ts";
import { consoleLogger, ldAPIRequest, writeSourceData } from "./utils.ts";

interface Arguments {
  projKey: string;
  apikey: string;
  domain: string;
}

let inputArgs: Arguments = yargs(Deno.args)
  .alias("p", "projKey")
  .alias("k", "apikey")
  .alias("u", "domain")
  .default("u", "app.launchdarkly.com").argv;

// Project Data //
const auditResp = await getAuditLogs(inputArgs.apikey, inputArgs.domain);
if (auditResp == null) {
  console.log("Failed getting audit logs");
  Deno.exit(1);
}
const auditData = auditResp;
const projPath = `./source/project/${inputArgs.projKey}`;
ensureDirSync(projPath); 

await writeSourceData(projPath, "audit", auditData);

//This method will call an launchdarkly api to get the audit logs 
// this will leverage the https://app.launchdarkly.com/api/v2/auditlog
// using the before and limit parameter just like in this example
// https://app.launchdarkly.com/api/v2/auditlog?before=1710988978157&limit=10
// the before parameter is the timestamp of the last audit log in the previous response and shall initially be set to the current time
// the method will iterate over the audit log back in time using the last audit log in the previous response
// the method will handle the rate limit and will wait for the rate limit to be reset before making the next request
// the rate limit is set in the 429 response header as x-ratelimit-reset
// the method will write the audit logs in a json object and returned as a response
async function getAuditLogs(apikey: string, domain: string) {
  let before = Date.now() - 1 * 365 * 24 * 60 * 60 * 1000;
  const limit = 10;
  const auditLogs = [];
  const twoYearsAgo = Date.now() - 2 * 365 * 24 * 60 * 60 * 1000; // Timestamp for 1 years ago

  while (true) {
    const response = await fetch(`https://${domain}/api/v2/auditlog?before=${before}&limit=${limit}`, {
      headers: {
        'Authorization': apikey
      }
    });

    if (response.status === 429) {
      const rateLimitReset = parseInt(response.headers.get('x-ratelimit-reset') || '0');
      const waitTime = rateLimitReset - Date.now();

      if (waitTime > 0) {
        await new Promise(resolve => setTimeout(resolve, waitTime));
      }

      continue;
    }

    if (!response.ok) {
      console.log(`Erreur lors de la récupération des logs d'audit : ${response.statusText}`);
      break;
    }

    const data = await response.json();

    auditLogs.push(...data.items);

    if (data.items.length > 0) {
      const lastDate = new Date(data.items[data.items.length - 1].date);
      console.log("Dernière date : ", lastDate);

      if (lastDate.getTime() < twoYearsAgo) {
        break;
      }

      before = data.items[data.items.length - 1].date;
    }
  }

  return auditLogs;
}
