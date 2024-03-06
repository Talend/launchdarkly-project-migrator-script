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
const projResp = await fetch(
  ldAPIRequest(
    inputArgs.apikey,
    inputArgs.domain,
    `projects/${inputArgs.projKey}?expand=environments`,
  ),
);
if (projResp == null) {
  console.log("Failed getting project");
  Deno.exit(1);
}
const projData = await projResp.json();
const projPath = `./source/project/${inputArgs.projKey}`;
ensureDirSync(projPath); 

await writeSourceData(projPath, "project", projData);

