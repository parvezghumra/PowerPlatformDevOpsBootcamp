# Lesson 3 - Create Variable Groups in Azure DevOps

## Objective

In this lesson you will create Azure DevOps Variable Groups in your project's Pipeline Library. Variable Groups allow you to store environment-specific configuration values outside your repository so that pipelines can consume them at runtime without embedding sensitive or environment-specific data in code.

By the end of this exercise you will have:

1. A `Generic Variables` variable group holding values that are common across all environments.
2. A `DEV Environment Variables` variable group for your Development Power Platform environment.
3. A `TEST Environment Variables` variable group for your Test Power Platform environment.
4. A `PROD Environment Variables` variable group for your Production Power Platform environment.
5. Pipeline permissions granted on each variable group.

Screenshots in this lesson are based on current Azure DevOps portal imagery. Your organisation branding and minor navigation labels may differ slightly.

> **Important**
> The variable group names used in this lesson must be entered exactly as shown. The pipeline YAML files reference them by name. Any spelling difference, including capitalisation, will cause a pipeline failure.

## What You Are Building

The pipelines in this workshop follow a two-phase pattern for handling environment-specific values — such as Dataverse Environment Variables and Power Automate Connection References — that differ between Power Platform environments.

**Phase 1 — Tokenisation (Commit Solution pipeline):**
When solution changes are committed from Development, the `TokeniseDeploymentSettingsFile.ps1` script replaces live values in the Deployment Settings file with static placeholder tokens. This makes the file environment-agnostic so it can be safely stored in the repository. The token mappings come from the `Generic Variables` variable group.

**Phase 2 — Transformation (Deploy Solution pipeline):**
Before each deployment, the `TransformDeploymentSettingsFile.ps1` script replaces the static tokens with real values for the target environment. These real values come from the environment-specific variable groups.

The four variable groups created in this lesson feed directly into this pattern.

## Before You Start

You need the following:

| Requirement | Why it is needed |
| --- | --- |
| An Azure DevOps organisation and project | Variable groups are created at project scope. |
| Project Administrator or Build Administrator role | Required to create and manage Library variable groups. |
| Service connection names from Lesson 1 | Used as the value of the `SPNServiceConnection` variable in each environment group. |
| Power Platform environment IDs for Test and Production | Required by the deployment transform script to look up connections. |
| The Dataverse Environment URLs from Lesson 0 | Cross-reference only — the service connection carries the URL at runtime. |
| Any known Dataverse Environment Variable schema names and Connection Reference connector IDs | Required to populate the JSON token variables. |

### How to Find a Power Platform Environment ID

The environment ID is the GUID that appears in the Power Platform Admin Center URL when you open an environment. Navigate to [https://admin.powerplatform.microsoft.com](https://admin.powerplatform.microsoft.com), open the target environment, and copy the GUID from the browser address bar. It looks similar to:

```
https://admin.powerplatform.microsoft.com/environments/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/hub
```

The section `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` is the environment ID.

> **Note**
> The Development environment ID is not needed for the `DEV Environment Variables` group because the Commit Solution pipeline does not run the transformation script. The service connection URL is resolved automatically at runtime from the service connection configured in Lesson 1.

## Values to Record

| Value | Example | Where you get it |
| --- | --- | --- |
| Test environment ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` | Power Platform Admin Center URL |
| Production environment ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` | Power Platform Admin Center URL |

## Understanding the JSON Variable Formats

Three of the variables in these groups hold JSON arrays. The tables below explain their structure and purpose.

### `EnvironmentVariableTokens` (Generic Variables group)

Used by the Commit Solution pipeline to tokenise Deployment Settings files. Add one entry per Dataverse Environment Variable in your solution.

```json
[
  {
    "SchemaName": "prefix_MyEnvironmentVariable",
    "StaticToken": "#{prefix_MyEnvironmentVariable}#"
  }
]
```

| Property | Description |
| --- | --- |
| `SchemaName` | The schema name of the Dataverse Environment Variable as it appears in the solution. |
| `StaticToken` | A unique placeholder that will be written into the settings file in place of the live value. Use a consistent format such as `#{SchemaName}#`. |

### `ConnectionReferenceTokens` (Generic Variables group)

Used by both the Commit Solution pipeline (to tokenise) and the Deploy Solution pipeline (to look up which connection to use in the target environment). Add one entry per Power Automate Connection Reference in your solution.

```json
[
  {
    "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_sharepointonline",
    "StaticToken": "#{shared_sharepointonline}#"
  }
]
```

| Property | Description |
| --- | --- |
| `ConnectorId` | The full connector ID path for the connector type. This can be found in the PAC CLI-generated Deployment Settings file. |
| `StaticToken` | A unique placeholder written into the settings file. Must match the token used in `EnvironmentVariableTokens` if the same token format is used. |

### `EnvironmentVariableValues` (environment-specific groups — TEST and PROD only)

Used by the Deploy Solution pipeline to replace tokens with real values for that environment. Add one entry per Dataverse Environment Variable.

```json
[
  {
    "StaticToken": "#{prefix_MyEnvironmentVariable}#",
    "Value": "https://actual-value-for-this-environment.example.com"
  }
]
```

| Property | Description |
| --- | --- |
| `StaticToken` | Must exactly match the `StaticToken` value used in `EnvironmentVariableTokens`. |
| `Value` | The real environment-specific value to use at deployment time. |

> **Note**
> If your solution has no Dataverse Environment Variables or Connection References at this point in the workshop, you can use empty JSON arrays (`[]`) as placeholder values and update them later.

---

## Step 1 - Navigate to the Pipeline Library

1. Open your Azure DevOps project.

![Open Azure DevOps project](./Media/Lesson%203/Step%201/OpenAzureDevOpsProject.png)

*Screenshot: Opening the Azure DevOps project.*

2. Select `Pipelines` from the left navigation.

![Select Pipelines](./Media/Lesson%203/Step%201/SelectPipelines.png)

*Screenshot: Selecting Pipelines from the left navigation.*

3. Select `Library`.

![Select Library](./Media/Lesson%203/Step%201/SelectLibrary.png)

*Screenshot: Selecting Library under Pipelines.*

---

## Step 2 - Create the Generic Variables Group

This group holds values shared across all environments and is referenced by both the Commit Solution and Deploy Solution pipelines.

1. Select `+ Variable group`.

![Select Add Variable Group](./Media/Lesson%203/Step%202/SelectAddVariableGroup.png)

*Screenshot: Selecting + Variable group.*

2. Enter the variable group name exactly as shown:

   | Setting | Value |
   | --- | --- |
   | Variable group name | `Generic Variables` |
   | Description | Optional, for example `Workshop-wide variables shared across all pipelines` |

![Enter Generic Variables group name](./Media/Lesson%203/Step%202/EnterGenericVariablesGroupName.png)

*Screenshot: Entering the Generic Variables group name.*

3. Add the first variable — `EnvironmentVariableTokens`. Select `+ Add` and complete the fields:

   | Field | Value |
   | --- | --- |
   | Name | `EnvironmentVariableTokens` |
   | Value | A JSON array following the format described in the [Understanding the JSON Variable Formats](#understanding-the-json-variable-formats) section above. If you have no environment variables yet, enter `[]`. |

![Add EnvironmentVariableTokens variable](./Media/Lesson%203/Step%202/AddEnvironmentVariableTokens.png)

*Screenshot: Adding the EnvironmentVariableTokens variable.*

4. Add the second variable — `ConnectionReferenceTokens`. Select `+ Add` again:

   | Field | Value |
   | --- | --- |
   | Name | `ConnectionReferenceTokens` |
   | Value | A JSON array following the format described in the [Understanding the JSON Variable Formats](#understanding-the-json-variable-formats) section above. If you have no connection references yet, enter `[]`. |

![Add ConnectionReferenceTokens variable](./Media/Lesson%203/Step%202/AddConnectionReferenceTokens.png)

*Screenshot: Adding the ConnectionReferenceTokens variable.*

5. Select `Save`.

![Save Generic Variables group](./Media/Lesson%203/Step%202/SaveGenericVariablesGroup.png)

*Screenshot: Saving the Generic Variables group.*

### Grant Pipeline Access to Generic Variables

6. With the `Generic Variables` group open, select the `Pipeline permissions` tab (or look for the security icon / three-dot menu depending on your Azure DevOps version).

![Open Pipeline Permissions for Generic Variables](./Media/Lesson%203/Step%202/OpenPipelinePermissionsForGenericVariables.png)

*Screenshot: Opening Pipeline permissions for Generic Variables.*

7. Select the `Open access` toggle, or select `+` and add each pipeline definition that should be able to use this group.

   > **Note**
   > For this workshop, `Open access` is the simplest option as it allows all project pipelines to use the group without requiring per-pipeline authorization. Restrict access in production scenarios.

![Grant Open Access to Generic Variables](./Media/Lesson%203/Step%202/GrantOpenAccessToGenericVariables.png)

*Screenshot: Granting Open access to the Generic Variables group.*

---

## Step 3 - Create the DEV Environment Variables Group

This group holds values specific to your Development Power Platform environment. It is referenced by the Commit Solution pipeline.

1. Return to the Library page and select `+ Variable group`.

![Select Add Variable Group for DEV](./Media/Lesson%203/Step%203/SelectAddVariableGroupForDEV.png)

*Screenshot: Selecting + Variable group for DEV.*

2. Enter the variable group name exactly as shown:

   | Setting | Value |
   | --- | --- |
   | Variable group name | `DEV Environment Variables` |
   | Description | Optional, for example `Variables for the Development Power Platform environment` |

![Enter DEV Environment Variables group name](./Media/Lesson%203/Step%203/EnterDEVEnvironmentVariablesGroupName.png)

*Screenshot: Entering the DEV Environment Variables group name.*

3. Add the `SPNServiceConnection` variable. Select `+ Add`:

   | Field | Value |
   | --- | --- |
   | Name | `SPNServiceConnection` |
   | Value | The exact name of the **Development** service connection you created in Lesson 1, for example `pp-devops-dev` |

![Add SPNServiceConnection to DEV](./Media/Lesson%203/Step%203/AddSPNServiceConnectionToDEV.png)

*Screenshot: Adding SPNServiceConnection to the DEV group.*

   > **Note**
   > Refer to your **Lesson 1 - Values to Record** table for the exact service connection name. It must match the name in Azure DevOps Service Connections exactly, including capitalisation.

4. Select `Save`.

![Save DEV Environment Variables group](./Media/Lesson%203/Step%203/SaveDEVEnvironmentVariablesGroup.png)

*Screenshot: Saving the DEV Environment Variables group.*

### Grant Pipeline Access to DEV Environment Variables

5. Select the `Pipeline permissions` tab and grant access in the same way as Step 2.

![Grant Pipeline Access to DEV](./Media/Lesson%203/Step%203/GrantPipelineAccessToDEV.png)

*Screenshot: Granting pipeline access to the DEV Environment Variables group.*

---

## Step 4 - Create the TEST Environment Variables Group

This group holds values specific to your Test Power Platform environment. It is referenced by the Deploy Solution pipeline when deploying to Test.

1. Return to the Library page and select `+ Variable group`.

![Select Add Variable Group for TEST](./Media/Lesson%203/Step%204/SelectAddVariableGroupForTEST.png)

*Screenshot: Selecting + Variable group for TEST.*

2. Enter the variable group name exactly as shown:

   | Setting | Value |
   | --- | --- |
   | Variable group name | `TEST Environment Variables` |
   | Description | Optional, for example `Variables for the Test Power Platform environment` |

![Enter TEST Environment Variables group name](./Media/Lesson%203/Step%204/EnterTESTEnvironmentVariablesGroupName.png)

*Screenshot: Entering the TEST Environment Variables group name.*

3. Add the `SPNServiceConnection` variable:

   | Field | Value |
   | --- | --- |
   | Name | `SPNServiceConnection` |
   | Value | The exact name of the **Test** service connection from Lesson 1, for example `pp-devops-test` |

![Add SPNServiceConnection to TEST](./Media/Lesson%203/Step%204/AddSPNServiceConnectionToTEST.png)

*Screenshot: Adding SPNServiceConnection to the TEST group.*

4. Add the `EnvironmentID` variable:

   | Field | Value |
   | --- | --- |
   | Name | `EnvironmentID` |
   | Value | The GUID environment ID of your Test Power Platform environment. See [How to Find a Power Platform Environment ID](#how-to-find-a-power-platform-environment-id) above. |

![Add EnvironmentID to TEST](./Media/Lesson%203/Step%204/AddEnvironmentIDToTEST.png)

*Screenshot: Adding EnvironmentID to the TEST group.*

5. Add the `EnvironmentVariableValues` variable:

   | Field | Value |
   | --- | --- |
   | Name | `EnvironmentVariableValues` |
   | Value | A JSON array with the real values for each Dataverse Environment Variable in the Test environment. See the JSON format described in [Understanding the JSON Variable Formats](#understanding-the-json-variable-formats) above. If you have no environment variables yet, enter `[]`. |

![Add EnvironmentVariableValues to TEST](./Media/Lesson%203/Step%204/AddEnvironmentVariableValuesToTEST.png)

*Screenshot: Adding EnvironmentVariableValues to the TEST group.*

6. Select `Save`.

![Save TEST Environment Variables group](./Media/Lesson%203/Step%204/SaveTESTEnvironmentVariablesGroup.png)

*Screenshot: Saving the TEST Environment Variables group.*

### Grant Pipeline Access to TEST Environment Variables

7. Select the `Pipeline permissions` tab and grant access in the same way as Step 2.

![Grant Pipeline Access to TEST](./Media/Lesson%203/Step%204/GrantPipelineAccessToTEST.png)

*Screenshot: Granting pipeline access to the TEST Environment Variables group.*

---

## Step 5 - Create the PROD Environment Variables Group

This group holds values specific to your Production Power Platform environment. It is referenced by the Deploy Solution pipeline when deploying to Production.

1. Return to the Library page and select `+ Variable group`.

![Select Add Variable Group for PROD](./Media/Lesson%203/Step%205/SelectAddVariableGroupForPROD.png)

*Screenshot: Selecting + Variable group for PROD.*

2. Enter the variable group name exactly as shown:

   | Setting | Value |
   | --- | --- |
   | Variable group name | `PROD Environment Variables` |
   | Description | Optional, for example `Variables for the Production Power Platform environment` |

![Enter PROD Environment Variables group name](./Media/Lesson%203/Step%205/EnterPRODEnvironmentVariablesGroupName.png)

*Screenshot: Entering the PROD Environment Variables group name.*

3. Add the `SPNServiceConnection` variable:

   | Field | Value |
   | --- | --- |
   | Name | `SPNServiceConnection` |
   | Value | The exact name of the **Production** service connection from Lesson 1, for example `pp-devops-prod` |

![Add SPNServiceConnection to PROD](./Media/Lesson%203/Step%205/AddSPNServiceConnectionToPROD.png)

*Screenshot: Adding SPNServiceConnection to the PROD group.*

4. Add the `EnvironmentID` variable:

   | Field | Value |
   | --- | --- |
   | Name | `EnvironmentID` |
   | Value | The GUID environment ID of your Production Power Platform environment. |

![Add EnvironmentID to PROD](./Media/Lesson%203/Step%205/AddEnvironmentIDToPROD.png)

*Screenshot: Adding EnvironmentID to the PROD group.*

5. Add the `EnvironmentVariableValues` variable:

   | Field | Value |
   | --- | --- |
   | Name | `EnvironmentVariableValues` |
   | Value | A JSON array with the real values for each Dataverse Environment Variable in the Production environment. If you have no environment variables yet, enter `[]`. |

![Add EnvironmentVariableValues to PROD](./Media/Lesson%203/Step%205/AddEnvironmentVariableValuesToPROD.png)

*Screenshot: Adding EnvironmentVariableValues to the PROD group.*

6. Select `Save`.

![Save PROD Environment Variables group](./Media/Lesson%203/Step%205/SavePRODEnvironmentVariablesGroup.png)

*Screenshot: Saving the PROD Environment Variables group.*

### Grant Pipeline Access to PROD Environment Variables

7. Select the `Pipeline permissions` tab and grant access in the same way as Step 2.

![Grant Pipeline Access to PROD](./Media/Lesson%203/Step%205/GrantPipelineAccessToPROD.png)

*Screenshot: Granting pipeline access to the PROD Environment Variables group.*

---

## Step 6 - Verify All Variable Groups

1. Return to the `Library` page in Azure DevOps.
2. Confirm that all four variable groups are visible:

   | Variable Group Name | Variables it should contain |
   | --- | --- |
   | `Generic Variables` | `EnvironmentVariableTokens`, `ConnectionReferenceTokens` |
   | `DEV Environment Variables` | `SPNServiceConnection` |
   | `TEST Environment Variables` | `SPNServiceConnection`, `EnvironmentID`, `EnvironmentVariableValues` |
   | `PROD Environment Variables` | `SPNServiceConnection`, `EnvironmentID`, `EnvironmentVariableValues` |

![Verify all variable groups in Library](./Media/Lesson%203/Step%206/VerifyAllVariableGroupsInLibrary.png)

*Screenshot: All four variable groups visible in the Library.*

3. Open each group and confirm the variable names match exactly as listed above.

![Verify Generic Variables group contents](./Media/Lesson%203/Step%206/VerifyGenericVariablesGroupContents.png)

*Screenshot: Verifying the contents of the Generic Variables group.*

![Verify DEV Environment Variables group contents](./Media/Lesson%203/Step%206/VerifyDEVEnvironmentVariablesGroupContents.png)

*Screenshot: Verifying the contents of the DEV Environment Variables group.*

![Verify TEST Environment Variables group contents](./Media/Lesson%203/Step%206/VerifyTESTEnvironmentVariablesGroupContents.png)

*Screenshot: Verifying the contents of the TEST Environment Variables group.*

![Verify PROD Environment Variables group contents](./Media/Lesson%203/Step%206/VerifyPRODEnvironmentVariablesGroupContents.png)

*Screenshot: Verifying the contents of the PROD Environment Variables group.*

---

## Notes for the Workshop

- Variable group names must match the pipeline YAML exactly. The pipeline files reference `Generic Variables`, `DEV Environment Variables`, `TEST Environment Variables`, and `PROD Environment Variables` by those exact names.
- `EnvironmentVariableTokens` and `ConnectionReferenceTokens` are intentionally the same across all environments — the token values are environment-agnostic placeholders. Only `EnvironmentVariableValues` differs per environment.
- The `ConnectionReferenceTokens` variable is used by both the tokenise step (to write static placeholders into the settings file during commit) and the transform step (to look up which real connection in the target environment corresponds to each token). This is why it lives in `Generic Variables` rather than in environment-specific groups.
- If a pipeline run fails with a message about not finding a variable group, check that the pipeline has been granted permission to use the group. The first run of a pipeline against a variable group may show an authorization prompt in the pipeline run view — select `Permit` to allow it.
- Connector IDs for the `ConnectionReferenceTokens` variable can be found in the Deployment Settings file that the PAC CLI generates during the Commit Solution pipeline run. Run the pipeline once and inspect the generated settings file in the repository to discover the connector IDs for your solution.
- Mark `EnvironmentVariableValues` secrets if the values are sensitive. Note that secret variables cannot be read back after they are saved — keep a separate record of their values.
