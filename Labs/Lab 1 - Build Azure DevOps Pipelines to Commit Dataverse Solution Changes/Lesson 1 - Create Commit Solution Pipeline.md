# Lesson 1 - Create Commit Solution Pipeline

## Objective

In this lesson you will create an Azure DevOps YAML pipeline named `Commit Solution Changes` that exports an unmanaged Dataverse solution from Development, unpacks it into source control format, tokenises deployment settings, and commits the updated files back to your Git repository.

By the end of this exercise you will have:

1. Created a new Azure DevOps pipeline named `Commit Solution Changes`.
2. Configured the pipeline to use the workshop YAML definition.
3. Understood what each step in `/Assets/Templates/commit-solution-template.yml` does.
4. Saved the pipeline ready to run in Lesson 2.

Screenshots in this lesson are based on current Azure DevOps portal imagery. Your organisation branding and minor navigation labels may differ slightly.

> **Important**
> This pipeline is designed to run against your **Development** environment only. It should not be used to deploy solutions to Test or Production.

## What You Are Building

This workshop uses a two-file YAML pattern:

- `/Assets/Pipelines/commit-solution-changes.yml` is the pipeline entry file used by Azure DevOps.
- `/Assets/Templates/commit-solution-template.yml` contains the reusable step-by-step job logic.

The entry file passes `SolutionName` and `CommitMessage` parameters into the template, and the template performs the full export, unpack, tokenisation, and Git commit process.

## Before You Start

You need the following:

| Requirement | Why it is needed |
| --- | --- |
| Lab 0 complete (especially Service Connections, Variable Groups, and repository initialisation) | The pipeline depends on these resources at runtime. |
| The `AccountManager` solution imported into Development (Lesson 0) | This is the solution you will export and commit. |
| Project permissions to create/edit pipelines in Azure DevOps | Required to create the YAML pipeline definition. |
| Repository contains `Assets/Pipelines/commit-solution-changes.yml` and `Assets/Templates/commit-solution-template.yml` | Required for pipeline and template resolution. |

### Required Variable Groups

Ensure these variable groups already exist and are accessible to pipelines:

1. `Generic Variables`
2. `DEV Environment Variables`

These names are referenced directly in YAML and must match exactly.

## Understanding the Template Steps

The table below explains each task in `/Assets/Templates/commit-solution-template.yml` so attendees understand what happens when the pipeline runs.

| Template Step / Task | Purpose |
| --- | --- |
| `checkout: self` | Checks out the repository so scripts and YAML files are available on the build agent. |
| `Set Git Config` (`CmdLine@2`) | Enables long-path support, sets Git user identity from build metadata, and checks out the current branch with authenticated access. |
| `Install Power Platform Tools` (`PowerPlatformToolInstaller@2`) | Installs the Power Platform Build Tools and PAC CLI capabilities required by later tasks. |
| `Set Connection Variables for SP` (`PowerPlatformSetConnectionVariables@2`) | Resolves service principal details from `SPNServiceConnection` and exposes them as variables for scripts/tasks. |
| `Sync Solution Version for Main` (`pwsh`) | Runs `Scripts/SyncSolutionVersion.ps1` to calculate and set a new solution version. |
| `Set Solution Version` (`PowerPlatformSetSolutionVersion@2`) | Writes the calculated version number back into the Dataverse solution. |
| `Publish All Customisations` (`PowerPlatformPublishCustomizations@2`) | Publishes pending customisations before export so metadata is current. |
| `Export Unmanaged Solution` (`PowerPlatformExportSolution@2`) | Exports the unmanaged solution zip used for source-control unpacking. |
| `Export Managed Solution` (`PowerPlatformExportSolution@2`) | Exports the managed solution zip for downstream release/deployment use. |
| `Unpack Solution` (`PowerPlatformUnpackSolution@2`) | Unpacks solution contents into `Solutions/<SolutionName>` in source-control-friendly structure. |
| `Generate Deployment Settings File` (`pwsh`) | Runs PAC CLI to generate `Settings/<SolutionName>.json` with connection references and environment variable placeholders. |
| `Tokenise Deployment Settings File` (`pwsh`) | Runs `Scripts/TokeniseDeploymentSettingsFile.ps1` to replace live values with static tokens for safe multi-environment use. |
| `Commit Solution Changes` (`CmdLine@2`) | Stages changes, commits with the provided message, and pushes to the current branch. |

---

## Step 1 - Open the Pipelines Area in Azure DevOps

1. Open your Azure DevOps project.

![Open Azure DevOps project](./Media/Lesson%201/Step%201/OpenAzureDevOpsProject.png)

*Screenshot: Opening the Azure DevOps project.*

2. Select `Pipelines` from the left navigation.

![Select Pipelines](./Media/Lesson%201/Step%201/SelectPipelines.png)

*Screenshot: Opening the Pipelines area.*

3. Select `Pipelines` again (if prompted between `Pipelines` and `Environments`).

![Open Pipelines list](./Media/Lesson%201/Step%201/OpenPipelinesList.png)

*Screenshot: Opening the pipelines list page.*

---

## Step 2 - Start Creating a New YAML Pipeline

1. Select `New pipeline`.

![Select New pipeline](./Media/Lesson%201/Step%202/SelectNewPipeline.png)

*Screenshot: Starting creation of a new pipeline.*

2. For `Where is your code?`, select `Azure Repos Git`.

![Select Azure Repos Git](./Media/Lesson%201/Step%202/SelectAzureReposGit.png)

*Screenshot: Choosing Azure Repos Git as the code source.*

3. Select your workshop repository.

![Select workshop repository](./Media/Lesson%201/Step%202/SelectWorkshopRepository.png)

*Screenshot: Selecting the repository that contains the workshop files.*

---

## Step 3 - Choose Existing YAML and Select the Pipeline File

1. In the pipeline configuration options, select `Existing Azure Pipelines YAML file`.

![Select Existing YAML option](./Media/Lesson%201/Step%203/SelectExistingYamlOption.png)

*Screenshot: Choosing to use an existing YAML file.*

2. Browse to and select:

	`/Assets/Pipelines/commit-solution-changes.yml`

![Select commit-solution-changes.yml](./Media/Lesson%201/Step%203/SelectCommitSolutionChangesYaml.png)

*Screenshot: Selecting the commit-solution-changes.yml entry file.*

3. Select `Continue`.

![Continue with selected YAML](./Media/Lesson%201/Step%203/ContinueWithSelectedYaml.png)

*Screenshot: Continuing after selecting the YAML file.*

> **Note**
> Although you select `/Assets/Pipelines/commit-solution-changes.yml`, that file imports `/Assets/Templates/commit-solution-template.yml`, which contains the detailed pipeline steps.

---

## Step 4 - Review the YAML and Understand Template Usage

1. In the YAML editor, review the stage and job definition.

![Review pipeline YAML](./Media/Lesson%201/Step%204/ReviewPipelineYaml.png)

*Screenshot: Reviewing the pipeline YAML definition in the editor.*

2. Locate the template reference under `steps`:

```yaml
- template: ../Templates/commit-solution-template.yml
  parameters:
	 SolutionName: ${{ parameters.SolutionName }}
	 CommitMessage: ${{ parameters.CommitMessage }}
```

This line is what links the pipeline to the template that performs the export/unpack/commit workflow.

3. Select `Show assistant` or open the template file in your repository to familiarise yourself with each task listed in [Understanding the Template Steps](#understanding-the-template-steps).

![Open template reference details](./Media/Lesson%201/Step%204/OpenTemplateReferenceDetails.png)

*Screenshot: Confirming the pipeline references the commit-solution-template.yml file.*

---

## Step 5 - Save the Pipeline as Commit Solution Changes

1. Select the dropdown next to `Run` and choose `Save` (or `Save and run`, then cancel run if you are only saving at this stage).

![Select Save pipeline](./Media/Lesson%201/Step%205/SelectSavePipeline.png)

*Screenshot: Saving the pipeline definition.*

2. When prompted, set the pipeline name to:

	`Commit Solution Changes`

![Set pipeline name](./Media/Lesson%201/Step%205/SetPipelineName.png)

*Screenshot: Naming the pipeline Commit Solution Changes.*

3. Confirm save.

![Confirm pipeline save](./Media/Lesson%201/Step%205/ConfirmPipelineSave.png)

*Screenshot: Confirming the pipeline save action.*

> **Important**
> Ensure the pipeline is saved from the correct branch that contains the workshop YAML files.

---

## Step 6 - Validate Pipeline Configuration

1. Open the saved `Commit Solution Changes` pipeline from the pipelines list.

![Open saved Commit Solution Changes pipeline](./Media/Lesson%201/Step%206/OpenSavedCommitSolutionChangesPipeline.png)

*Screenshot: Opening the saved pipeline from the pipelines list.*

2. Select `Edit` and confirm the YAML path still points to `/Assets/Pipelines/commit-solution-changes.yml`.

![Validate YAML path](./Media/Lesson%201/Step%206/ValidateYamlPath.png)

*Screenshot: Validating the YAML path for the pipeline definition.*

3. Confirm the pipeline shows runtime parameters for:

	- `SolutionName`
	- `CommitMessage`

![Confirm runtime parameters](./Media/Lesson%201/Step%206/ConfirmRuntimeParameters.png)

*Screenshot: Confirming the pipeline runtime parameters are available.*

4. Do not run the pipeline yet unless instructed. Execution and validation are covered in Lesson 2.

![Pipeline ready for next lesson](./Media/Lesson%201/Step%206/PipelineReadyForNextLesson.png)

*Screenshot: Pipeline is saved and ready to run in the next lesson.*

---

## Final Checklist

Before moving to Lesson 2, confirm the following:

1. A pipeline named `Commit Solution Changes` exists in Azure DevOps.
2. The pipeline references `/Assets/Pipelines/commit-solution-changes.yml`.
3. The YAML entry file references `/Assets/Templates/commit-solution-template.yml`.
4. You understand the purpose of each template step.
5. Required variable groups (`Generic Variables`, `DEV Environment Variables`) are available and authorised.

## Notes for the Workshop

- The Commit Solution pipeline is intended to be manually run when you want to capture Dataverse solution changes into source control.
- The first successful run typically creates or updates `Solutions/<SolutionName>` and `Settings/<SolutionName>.json` in the repository.
- If the pipeline cannot push changes, check branch permissions and ensure the build service identity has Contribute rights.
- If Power Platform tasks fail early, verify `SPNServiceConnection` in `DEV Environment Variables` matches the exact Azure DevOps service connection name.

