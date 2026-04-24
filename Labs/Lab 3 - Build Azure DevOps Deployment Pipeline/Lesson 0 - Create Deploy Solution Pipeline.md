
# Lesson 0 - Create Deploy Solution Pipeline

## Objective

In this lesson you will create an Azure DevOps YAML pipeline named `Deploy Solution` that deploys the artifacts produced by a selected `CI Build` run to each non-development environment in sequence, subject to approval at each stage.

By the end of this exercise you will have:

1. Created a new Azure DevOps pipeline named `Deploy Solution`.
2. Configured the pipeline to use the workshop YAML definition in `/Assets/Pipelines/deploy-solution.yml`.
3. Understood the purpose and behaviour of all four runtime parameters.
4. Understood how the pipeline links to a specific `CI Build` run through the pipeline resource reference.
5. Understood how the two deployment stages target `TEST` and `PROD` in sequence and how environment approvals gate progression between them.
6. Saved the pipeline ready to test in Lesson 1.

Screenshots in this lesson are based on current Azure DevOps portal imagery. Your organisation branding and minor navigation labels may differ slightly.

> **Important**
> This pipeline deploys artifacts that have already been packaged by `CI Build`. It does not export or pack solutions from source control. You must have a successful `CI Build` run available before running this pipeline.

## What You Are Building

This workshop uses a two-file YAML pattern for deployment:

- `/Assets/Pipelines/deploy-solution.yml` is the pipeline entry file used by Azure DevOps. It declares runtime parameters, references the `CI Build` pipeline resource, and defines the two deployment stages.
- `/Assets/Templates/deploy-solution-template.yml` contains the reusable step-by-step deployment logic. It is called once per stage with stage-specific variable group and environment bindings applied by the entry file.

The entry file intentionally has no automatic trigger (`trigger: none`). It must always be started manually so that the operator can select which `CI Build` run to deploy and supply any runtime options before the deployment begins.

## How the Deployment Flow Works

```
CI Build run  →  Deploy Solution (manual trigger)
                  │
                  ├─ Stage: Deploy to TEST  ─ awaits environment approval ─►  deploys to TEST
                  │
                  └─ Stage: Deploy to PROD  ─ awaits environment approval ─►  deploys to PROD
                        (only runs after Deploy to TEST succeeds)
```

Each stage uses a `deployment` job type bound to an Azure DevOps environment. Approval gates are configured on each environment in Azure DevOps independently of this YAML. When the pipeline reaches a deployment stage, it pauses and waits for any configured approvers to confirm before the deployment steps run.

## Before You Start

You need the following:

| Requirement | Why it is needed |
| --- | --- |
| Lab 0 complete | Service connections, variable groups, environments, and the repository must already exist. |
| Lab 1 and Lab 2 complete | A successful `CI Build` run must exist so there are published artifacts available to deploy. |
| `TEST` and `PROD` environments exist in Azure DevOps with approval gates configured | The deployment jobs target these environments by name. If they do not exist or have no approvers, deployment will proceed without any gate. |
| `Generic Variables`, `TEST Environment Variables`, and `PROD Environment Variables` variable groups exist and are accessible to pipelines | Referenced directly in the pipeline YAML. |
| Repository contains `/Pipelines/deploy-solution.yml` and `/Templates/deploy-solution-template.yml` | Required for pipeline and template resolution. |
| Project permissions to create/edit pipelines in Azure DevOps | Required to create the YAML pipeline definition. |

### Required Variable Groups

Ensure the following variable groups already exist and are accessible to pipelines:

1. `Generic Variables`
2. `TEST Environment Variables`
3. `PROD Environment Variables`

These names are referenced directly in YAML and must match exactly.

## Understanding the Runtime Parameters

When this pipeline is triggered manually, Azure DevOps presents a run form with the following parameters. The table below explains the purpose and valid values for each one.

| Parameter | Display Name | Type | Default | Purpose |
| --- | --- | --- | --- | --- |
| `SolutionName` | Solution Unique Name | `string` | _(none)_ | The API unique name of the Dataverse solution you want to deploy. This value is used throughout the template to locate the correct solution zip file in the artifact, find the matching deployment settings file, and identify the installed solution in the target environment. It must exactly match the solution unique name in Dataverse and the file names produced by the `CI Build` pipeline. |
| `SolutionImportMode` | Solution Import Mode | `string` | `Modern Upgrade` | Controls which of the three conditional import tasks in the template runs. `Modern Upgrade` stages the solution and applies the upgrade in a single asynchronous operation using the `StageAndUpgrade` flag. `Legacy Upgrade` imports the solution as a holding solution and then applies the upgrade as a separate step. `Update` performs a direct update import with no holding solution. If the solution is not yet installed in the target environment, the template automatically falls back to an `Update`-style import regardless of which mode is selected. |
| `OverwriteUnmanagedCustomisations` | Overwrite Unmanaged Customisations | `boolean` | `false` | Passed directly to the `PowerPlatformImportSolution@2` task. When `false`, any unmanaged customisations that exist on top of the managed solution layer in the target environment are preserved during import. When `true`, those customisations are overwritten. Set to `true` with caution in environments where citizen developers may have made changes directly. |
| `SkipLowerVersion` | Skip Lower Version | `boolean` | `true` | Passed directly to the `PowerPlatformImportSolution@2` task. When `true`, the import task will not attempt to import a solution version that is lower than or equal to the version already installed in the target environment. This prevents accidental downgrades. Set to `false` only if you intentionally need to reimport the same or an older version. |

## Understanding the Pipeline Stages

The table below explains the purpose of each major section of `/Pipelines/deploy-solution.yml`.

| YAML Section | Purpose |
| --- | --- |
| `trigger: none` | Disables automatic triggering. The pipeline can only be started manually so that the operator selects the source CI run and supplies deployment options. |
| `parameters` | Declares the four runtime parameters described above. Azure DevOps renders these as a form field when the pipeline is manually triggered. |
| `variables` | Links the `Generic Variables` variable group and exposes the `ImportMode` pipeline variable, which the deployment template uses in its conditional task logic. |
| `resources.pipelines` | Declares `CI-Build` as a pipeline resource. At run time the operator selects which `CI Build` run to consume. The published artifacts from that run (`Scripts`, `Settings`, `Solutions`) are downloaded automatically by each deployment stage before the template steps run. |
| `stage: deployToTEST` | The first deployment stage. Binds the `TEST Environment Variables` variable group, targets the `TEST` Azure DevOps environment, and calls the deployment template with the supplied parameters. |
| `stage: deployToPROD` | The second deployment stage. Depends on `deployToTEST` completing successfully. Binds the `PROD Environment Variables` variable group, targets the `PROD` environment, and calls the deployment template. |
| `environment: TEST` / `environment: PROD` | Ties each deployment job to an Azure DevOps environment. Any approval policies, required reviewers, or deployment history tracking configured on those environments apply at runtime. |
| `template: ../Templates/deploy-solution-template.yml` | Injects all deployment steps from the shared template into each stage, passing through `SolutionName`, `OverwriteUnmanagedCustomisations`, and `SkipLowerVersion`. |

## Understanding the Deployment Template Steps

The table below explains each task in `/Templates/deploy-solution-template.yml` so you understand what happens when a deployment stage runs.

| Template Step / Task | Purpose |
| --- | --- |
| `Install Power Platform Tools` (`PowerPlatformToolInstaller@2`) | Installs the Power Platform Build Tools and PAC CLI on the build agent. This must run before any other Power Platform task. |
| `Set Connection Variables for SP` (`PowerPlatformSetConnectionVariables@2`) | Resolves the application ID and client secret from the `SPNServiceConnection` service connection and exposes them as pipeline variables for use in later script and task steps. |
| `Check Solution Installation Status` (`pwsh` – `IsSolutionInstalled.ps1`) | Queries the target environment to determine whether the solution is already installed and, if so, what version. The result is stored as the `currentSolutionStatus` output variable which the conditional import tasks read to decide whether to treat the import as an upgrade or a fresh install. |
| `Transform Deployment Settings File` (`pwsh` – `TransformDeploymentSettingsFile.ps1`) | Takes the tokenised deployment settings JSON file from the CI artifact and replaces environment-specific tokens with the real values sourced from the target environment's variable group. The resulting file is used by the import tasks to configure connection references and environment variables in the target environment. |
| `Import Solution as Stage and Upgrade` (`PowerPlatformImportSolution@2`) | Runs when `ImportMode` is `Modern Upgrade` and the solution is already installed. Imports the managed solution using the `StageAndUpgrade` flag, which stages and upgrades in a single asynchronous operation. |
| `Import Solution as Holding Solution` (`PowerPlatformImportSolution@2`) | Runs when `ImportMode` is `Legacy Upgrade` and the solution is already installed. Imports the managed solution as a holding solution to enable a two-step upgrade. |
| `Import Solution as Update` (`PowerPlatformImportSolution@2`) | Runs when `ImportMode` is `Update`, or when the solution is not yet installed in the target environment regardless of the selected mode. Performs a direct import without using the upgrade pattern. |
| `Check Import Outcome` (`pwsh` – `IsSolutionInstalled.ps1`) | Re-queries the target environment after import to confirm that the upgrade holding solution is present, which is required before `Apply Upgrade` can run. |
| `Apply Upgrade` (`PowerPlatformApplySolutionUpgrade@2`) | Runs only when `ImportMode` is `Legacy Upgrade` and the holding solution was successfully imported. Triggers the upgrade application to replace the base solution with the newly staged version. |

---

## Step 1 - Open the Pipelines Area in Azure DevOps

1. Open your Azure DevOps project.

![Open Azure DevOps project](./Media/Lesson%200/Step%201/OpenAzureDevOpsProject.png)

*Screenshot: Opening the Azure DevOps project.*

2. Select `Pipelines` from the left navigation.

![Select Pipelines](./Media/Lesson%200/Step%201/SelectPipelines.png)

*Screenshot: Opening the Pipelines area.*

3. Select `Pipelines` again if Azure DevOps first shows another pipelines-related landing page.

![Open Pipelines list](./Media/Lesson%200/Step%201/OpenPipelinesList.png)

*Screenshot: Opening the pipelines list page.*

---

## Step 2 - Start Creating a New YAML Pipeline

1. Select `New pipeline`.

![Select New pipeline](./Media/Lesson%200/Step%202/SelectNewPipeline.png)

*Screenshot: Starting creation of a new pipeline.*

2. For `Where is your code?`, select `Azure Repos Git`.

![Select Azure Repos Git](./Media/Lesson%200/Step%202/SelectAzureReposGit.png)

*Screenshot: Choosing Azure Repos Git as the code source.*

3. Select your repository where you copied the `Scripts`, `Templates` and `Pipelines` folders to from the workshop repository.

![Select workshop repository](./Media/Lesson%200/Step%202/SelectWorkshopRepository.png)

*Screenshot: Selecting the repository that contains the workshop files.*

---

## Step 3 - Choose Existing YAML and Select the Deploy Pipeline File

1. In the pipeline configuration options, select `Existing Azure Pipelines YAML file`.

![Select Existing YAML option](./Media/Lesson%200/Step%203/SelectExistingYamlOption.png)

*Screenshot: Choosing to use an existing YAML file.*

2. Leave the default `main` or `master` branch selected, and browse to and select:

	`/Pipelines/deploy-solution.yml`

![Select deploy-solution.yml](./Media/Lesson%200/Step%203/SelectDeploySolutionYaml.png)

*Screenshot: Selecting the deploy-solution.yml pipeline file.*

3. Select `Continue`.

![Continue with selected YAML](./Media/Lesson%200/Step%203/ContinueWithSelectedYaml.png)

*Screenshot: Continuing after selecting the YAML file.*

> **Note**
> Unlike the CI pipeline, this pipeline calls a shared template file for its deployment steps. Azure DevOps resolves the template reference from `/Templates/deploy-solution-template.yml` in the same repository automatically.

---

## Step 4 - Review the Runtime Parameters and Understand Each One

1. In the YAML editor, review the `parameters` block near the top of the file and confirm it declares the four expected parameters.

![Review parameters block](./Media/Lesson%200/Step%204/ReviewParametersBlock.png)

*Screenshot: Reviewing the parameters block in the YAML editor.*

```yaml
parameters:
  - name: SolutionName
    displayName: "Solution Unique Name"
    type: string

  - name: SolutionImportMode
    displayName: "Solution Import Mode"
    type: string
    default: Modern Upgrade
    values:
    - Modern Upgrade
    - Legacy Upgrade
    - Update

  - name: OverwriteUnmanagedCustomisations
    displayName: "Overwrite Unmanaged Customisations"
    type: boolean
    default: false

  - name: SkipLowerVersion
    displayName: "Skip Lower Version"
    type: boolean
    default: true
```

2. Understand the `SolutionName` parameter.

	`SolutionName` has no default value. Azure DevOps will require you to type a value every time the pipeline is triggered. This is intentional — the pipeline must always be targeted at a specific solution and there is no safe default.

	The value you provide must exactly match the Dataverse solution unique name and must match the file names in the `CI Build` artifact (for example `AccountManager_managed.zip` and `AccountManager.json`). If the names do not match, the import task will fail when it cannot locate the expected artifact files.

![Understand SolutionName parameter](./Media/Lesson%200/Step%204/UnderstandSolutionNameParameter.png)

*Screenshot: Reviewing the SolutionName parameter, which has no default and must be provided at every run.*

3. Understand the `SolutionImportMode` parameter.

	`SolutionImportMode` controls which of the three conditional `PowerPlatformImportSolution@2` tasks in the template executes during each deployment stage. The three values map to distinct import behaviours:

	| Value | Behaviour |
	| --- | --- |
	| `Modern Upgrade` | Stages and upgrades the solution in a single asynchronous operation. This is the recommended mode for managed solutions that are already installed. |
	| `Legacy Upgrade` | Imports the solution as a holding solution first, then applies the upgrade as a separate subsequent task. Use this if you require a window of time to perform migration of data or interleave these deployments steps for multiple solutions within dependencies between each. |
	| `Update` | Performs a direct solution update import. Use this when the upgrade pattern is not required or when importing a solution for the first time into an environment where the unmanaged version is present. |

	> **Note**
	> Regardless of which mode you select, the template always falls back to an `Update`-style import when the solution is not yet installed in the target environment. The `IsSolutionInstalled.ps1` check at the start of the template controls this behaviour via the `currentSolutionStatus` output variable.

![Understand SolutionImportMode parameter](./Media/Lesson%200/Step%204/UnderstandSolutionImportModeParameter.png)

*Screenshot: Reviewing the SolutionImportMode parameter and its three allowed values.*

4. Understand the `OverwriteUnmanagedCustomisations` parameter.

	`OverwriteUnmanagedCustomisations` defaults to `false`. This means that if anyone in the target environment has made unmanaged customisations on top of the managed solution layer, those customisations will be preserved during import.

	Set this to `true` only if you want the imported solution to remove or overwrite any unmanaged layers that exist in the target environment. This is commonly needed in a clean deployment scenario but should be used carefully in environments shared with other teams.

![Understand OverwriteUnmanagedCustomisations parameter](./Media/Lesson%200/Step%204/UnderstandOverwriteUnmanagedCustomisationsParameter.png)

*Screenshot: Reviewing the OverwriteUnmanagedCustomisations boolean parameter.*

5. Understand the `SkipLowerVersion` parameter.

	`SkipLowerVersion` defaults to `true`. This prevents the import task from deploying a solution whose version number is lower than the version already installed in the target environment.

	This is a safety default that prevents accidental downgrades when, for example, a pipeline run is triggered with an older `CI Build` artifact. Set this to `false` only when you deliberately need to reimport the same version or an earlier version — for example, during a rollback.

![Understand SkipLowerVersion parameter](./Media/Lesson%200/Step%204/UnderstandSkipLowerVersionParameter.png)

*Screenshot: Reviewing the SkipLowerVersion boolean parameter.*

---

## Step 5 - Review the Pipeline Resource and Understand How CI Artifacts Are Consumed

1. In the YAML editor, review the `resources` block.

![Review resources block](./Media/Lesson%200/Step%205/ReviewResourcesBlock.png)

*Screenshot: Reviewing the pipeline resources block.*

```yaml
resources:
  pipelines:
    - pipeline: 'CI-Build'
      source: 'CI Build'
```

2. Understand what this block does.

	The `resources.pipelines` block tells Azure DevOps that this pipeline depends on artifacts published by another pipeline. The `source` value must match the exact display name of your `CI Build` pipeline in Azure DevOps.

	When the `Deploy Solution` pipeline is triggered manually, the run form includes an additional `Resources` section where the operator selects which specific `CI Build` run to use as the source. The `Scripts`, `Settings`, and `Solutions` artifacts from that selected run are downloaded automatically to `$(Pipeline.Workspace)/CI-Build/` before any template steps execute.

	> **Important**
	> The `source` value in the `resources` block must exactly match the display name of your `CI Build` pipeline in Azure DevOps. If you named it differently in Lab 2, update this value before saving the pipeline.

![Understand pipeline resource and artifact source](./Media/Lesson%200/Step%205/UnderstandPipelineResourceAndArtifactSource.png)

*Screenshot: Understanding how the pipeline resource block links to the CI Build pipeline.*

3. Verify that the `source` value in the YAML matches the name of your `CI Build` pipeline in Azure DevOps. If you used a different name in Lab 2, update the `source` value now.

![Verify CI Build source name](./Media/Lesson%200/Step%205/VerifyCiBuildSourceName.png)

*Screenshot: Verifying the source pipeline name matches the CI Build pipeline name in Azure DevOps.*

---

## Step 6 - Review the Deployment Stages and Understand Environment Approvals

1. In the YAML editor, locate the two stages: `deployToTEST` and `deployToPROD`.

![Locate deployment stages](./Media/Lesson%200/Step%206/LocateDeploymentStages.png)

*Screenshot: Locating the deployToTEST and deployToPROD stages in the YAML.*

2. Observe that `deployToPROD` includes a `dependsOn: deployToTEST` declaration. This means the PROD stage will not start until the TEST stage has completed successfully. If TEST fails or is rejected at the approval gate, PROD will not run.

![Observe dependsOn declaration](./Media/Lesson%200/Step%206/ObserveDependsOnDeclaration.png)

*Screenshot: The dependsOn declaration ensuring sequential stage execution.*

3. Observe that each stage uses a `deployment` job type rather than a standard `job` type.

	```yaml
	jobs:
	- deployment: deployToTEST
	  ...
	  environment: 'TEST'
	  strategy:
	   runOnce:
	     deploy:
	      steps:
	      - template: ../Templates/deploy-solution-template.yml
	```

	The `deployment` job type is significant because it:

	- Ties the job to a named Azure DevOps environment.
	- Causes Azure DevOps to check for any approval policies configured on that environment before executing the deployment steps.
	- Records a deployment history entry against the environment so you can audit what was deployed and when.

![Observe deployment job type](./Media/Lesson%200/Step%206/ObserveDeploymentJobType.png)

*Screenshot: Observing the deployment job type and environment binding.*

4. Understand how environment approvals work at runtime.

	Each of the `TEST` and `PROD` environments in Azure DevOps can be configured with approval gates independently. When the pipeline reaches a deployment stage:

	1. Azure DevOps checks whether the target environment has any approval policies.
	2. If approvals are configured, the pipeline pauses and notifies the configured approvers.
	3. Approvers review the pending deployment in the Azure DevOps pipeline run view and either approve or reject it.
	4. Only after approval does the deployment job proceed to execute the template steps.

	This means a single pipeline run can be approved for TEST deployment, then paused again awaiting separate approval for PROD — giving teams full control over promotion between environments.

![Understand environment approval flow](./Media/Lesson%200/Step%206/UnderstandEnvironmentApprovalFlow.png)

*Screenshot: Illustration of the approval gate flow between TEST and PROD deployment stages.*

5. Observe that each stage binds a different variable group. `deployToTEST` uses `TEST Environment Variables` and `deployToPROD` uses `PROD Environment Variables`. These groups supply the environment-specific values (such as service connection names, environment URLs, and connection reference tokens) that the deployment template uses when transforming the settings file and connecting to Dataverse.

![Observe environment variable group bindings](./Media/Lesson%200/Step%206/ObserveEnvironmentVariableGroupBindings.png)

*Screenshot: Observing that each stage binds its own environment-specific variable group.*

---

## Step 7 - Save the Pipeline as Deploy Solution

1. Select the dropdown next to `Run` and choose `Save`.

![Select Save pipeline](./Media/Lesson%200/Step%207/SelectSavePipeline.png)

*Screenshot: Saving the pipeline definition.*

2. Click the elipses (...) button towards the top-right	and choose the `Rename/move` option in the context menu. Set the pipeline name to:

	`Deploy Solution`

![Set pipeline name](./Media/Lesson%200/Step%207/SetPipelineName.png)

*Screenshot: Naming the pipeline Deploy Solution.*

3. Confirm save.

![Confirm pipeline save](./Media/Lesson%200/Step%207/ConfirmPipelineSave.png)

*Screenshot: Confirming the pipeline save action.*

> **Important**
> Save the pipeline from the branch that contains the workshop YAML files. If the wrong branch is selected during creation, Azure DevOps may not resolve the template path correctly.

---

## Step 8 - Configure the Deploy Solution pipeline to automatically link work items and link Variable Groups

1. Open the `Deploy Solution` pipline and choose the `Edit` button

2. Click the elipses (...) button towards the top-right and select the `Settings` option in the context menu

3. In the `Pipeline Settings` panel, check the box for `Automatically link work items included in this run`, select the `*` option in the branch selection field and click `Save`

4. Click the elipses (...) button towards the top-right and select the `Triggers` option in the context menu

5. Click the `Variables` tab and click the `Variable groups` section

6. Click on the `Link variable group` button, and one-by-one link each of the following three Variable Groups to the pipeline, choosing the `Link` button after each selection:
	- `Generic Variables`
	- `TEST Environment Variables`
	- `PROD Environment Varaibles`

7. Click the drop-down button next to the `Save & Queue` button, click the `Save` option in the context menu and the `Save` button in the `Save build pipeline` dialog box.

---

## Step 9 - Grant Deploy Solution pipeline access to Variable Groups

1. Use the left hand navigation to navigate to `Library` under the `Pipeline` section

2. Select the `Generic Variables` Variable Group, click the `Pipeline Permissions` tab

3. Click the `+` button and select the `Deploy Solution` pipeline in the context menu. Close the `Generic Variables` dialog box

4. Return to the Variable Groups listing on the `Library` page under the `Pipelines` section

5. Select the `TEST Environment Variables` Variable Group, click the `Pipeline Permissions` tabe

6. Click the `+` button and select the `Deploy Solution` pipeline in the context menu. Close the `TEST Environment Variables` dialog box

7. Return to the Variable Groups listing on the `Library` page under the `Pipelines` section

8. Select the `PROD Environment Variables` Variable Group, click the `Pipeline Permissions` tabe

9. Click the `+` button and select the `Deploy Solution` pipeline in the context menu. Close the `PROD Environment Variables` dialog box

---

## Step 10 - Grant Deploy Solution pipeline access to Service Connections

1. Under `Project Settings` in the left hand navigation, select `Service Connection` under the `Pipelines` area

2. Select the Service Connection corresponding to the Test environment

3. Click on the elipses (...) button towards the top-right and select the `Security` button in the context menu

4. Under the `Pipelines Permissions` section, click the `+` button and select the `Deploy Solution` pipeline

5. Return to the listing of Service Connections and select the Service Connection corresponding to the Prod environment

6. Click on the elipses (...) button towards the top-right and select the `Security` button in the context menu

7. Under the `Pipelines Permissions` section, click the `+` button and select the `Deploy Solution` pipeline

---

### Step 11 - Grant Deploy Solution pipeline access to Environments

1. Select `Environments` under the `Pipelines` section in the left hand navigation

2. Select the environment corresponding to the Test environment

3. Click the elipses (...) button towards the top-right and select the `Security` option from the context menu

4. Under the `Pipeline Permissions` section, click the `+` button and select the `Deploy Solution` pipeline

5. Return to the environment listing and select the environment corresponding to the Prod environment

6. Click the elipses (...) button towards the top-right and select the `Security` option from the context menu

7. Under the `Pipeline Permissions` section, click the `+` button and select the `Deploy Solution` pipeline

---

## Step 12 - Validate the Pipeline Configuration

1. Open the saved `Deploy Solution` pipeline from the pipelines list.

![Open saved Deploy Solution pipeline](./Media/Lesson%200/Step%208/OpenSavedDeploySolutionPipeline.png)

*Screenshot: Opening the saved Deploy Solution pipeline from the pipelines list.*

2. Select `Edit` and confirm the YAML path still points to `/Assets/Pipelines/deploy-solution.yml`.

![Validate YAML path](./Media/Lesson%200/Step%208/ValidateYamlPath.png)

*Screenshot: Validating the YAML path for the deploy pipeline definition.*

3. Confirm the `source` value in the `resources` block matches the display name of your `CI Build` pipeline exactly.

![Confirm CI Build source name is correct](./Media/Lesson%200/Step%208/ConfirmCiBuildSourceNameIsCorrect.png)

*Screenshot: Confirming the CI Build source name resolves correctly.*

4. Confirm that the pipeline has no automatic trigger by checking that `trigger: none` appears near the top of the YAML. This pipeline should never run automatically.

![Confirm no automatic trigger](./Media/Lesson%200/Step%208/ConfirmNoAutomaticTrigger.png)

*Screenshot: Confirming the pipeline has trigger none and will only run manually.*

5. Understand the complete end-to-end workshop deployment flow:

	- `Commit Solution Changes` exports and commits the solution back to Git.
	- `CI Build` detects the commit and packages artifacts.
	- `Deploy Solution` is triggered manually by an operator who selects the CI run and provides the solution name and import options.
	- `Deploy Solution` deploys to `TEST` after approval, then to `PROD` after a second approval.

![Understand end to end deployment flow](./Media/Lesson%200/Step%208/UnderstandEndToEndDeploymentFlow.png)

*Screenshot: Reviewing the complete end-to-end flow from commit through to production deployment.*

6. Do not trigger the pipeline yet unless instructed. Running the pipeline and observing the approval gates and deployment outcomes are covered in Lesson 1.

---

## Final Checklist

Before moving to Lesson 1, confirm the following:

1. A pipeline named `Deploy Solution` exists in Azure DevOps.
2. The pipeline references `/Assets/Pipelines/deploy-solution.yml`.
3. The `source` value in the `resources` block matches your `CI Build` pipeline display name.
4. You understand the purpose of all four runtime parameters: `SolutionName`, `SolutionImportMode`, `OverwriteUnmanagedCustomisations`, and `SkipLowerVersion`.
5. You understand that `deployToPROD` depends on `deployToTEST` completing successfully.
6. You understand that approval gates on the `TEST` and `PROD` Azure DevOps environments control when each deployment stage proceeds.
7. You understand that each deployment stage uses a different variable group to supply environment-specific configuration.
8. You understand the pipeline specific permissions granted to Service Connections, Environments and Variable Groups

## Notes for the Workshop

- The `trigger: none` setting is deliberate. Deployment to non-development environments should always be a conscious decision made by a person, not an automatic response to a commit.
- The `SolutionImportMode` default of `Modern Upgrade` is appropriate for most scenarios. Only change it if you encounter compatibility issues with a specific environment version or if you need the two-step Legacy Upgrade behaviour data migration or solution layering sensitive dependeny resolution purpose.
- If either the `TEST` or `PROD` environment does not have approval gates configured, the deployment job will proceed immediately without pausing. Configure approval policies on both environments in Azure DevOps under `Pipelines > Environments` before running the pipeline in Lesson 1.
- The `Generic Variables` group is consumed at the pipeline level and typically contains values shared across all environments, such as static tokens for Connection References and Environment Variables.
- The `TEST Environment Variables` and `PROD Environment Variables` groups are scoped to their respective deployment stages. They must contain the environment-specific values expected by the deployment template, including `SPNServiceConnection`, `EnvironmentVariableValues`, `ConnectionReferenceTokens`, and `EnvironmentID`.
- If your repository contains more than one Dataverse solution, you run `Deploy Solution` once per solution, supplying the correct `SolutionName` value each time. All solutions share the same pipeline definition.

