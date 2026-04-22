# Lesson 0 - Create CI Pipeline

## Objective

In this lesson you will create an Azure DevOps YAML pipeline named `CI Build` that automatically produces deployable artifacts when changes are pushed to the monitored branch and folders in your repository.

By the end of this exercise you will have:

1. Created a new Azure DevOps pipeline named `CI Build`.
2. Configured the pipeline to use the workshop YAML definition in `/Assets/Pipelines/ci-build.yml`.
3. Understood how the branch and path triggers control when the pipeline runs automatically.
4. Understood how the pipeline builds and publishes `Scripts`, `Settings`, and `Solutions` artifacts.
5. Saved the pipeline ready to validate in Lesson 1.

Screenshots in this lesson are based on current Azure DevOps portal imagery. Your organisation branding and minor navigation labels may differ slightly.

> **Important**
> This pipeline packages source-controlled assets into build artifacts. It does not deploy them to Dataverse. Deployment is covered later in the workshop.

## What You Are Building

This workshop uses a single YAML pipeline entry file for the CI build:

- `/Assets/Pipelines/ci-build.yml` defines the automatic trigger rules and all build jobs.

The pipeline is designed to react to repository changes that affect deployable content. In the workshop sample it watches the `main` branch and specific folders that are expected to change when Dataverse solution updates are committed back to source control.

This is why the pipeline will often run automatically after a successful `Commit Solution Changes` pipeline execution, provided that pipeline pushes changes into a monitored branch and one or more monitored folders.

## How the Trigger Works

The `trigger` block in `/Assets/Pipelines/ci-build.yml` currently contains the following logic:

| Trigger Setting | Workshop Sample Value | What it means |
| --- | --- | --- |
| `batch` | `true` | If multiple qualifying commits are pushed while a run is already in progress, Azure DevOps batches them into the next run instead of starting many parallel runs. |
| `branches.include` | `main` | The automatic trigger only fires for commits pushed to the `main` branch. |
| `paths.include` | `Scripts/*`, `Settings/*`, `Solutions/*` | The automatic trigger only fires when at least one changed file is inside one of these folders. |

In practical terms, this means the CI pipeline will not run for every commit in the repository. It only runs when both conditions are true:

1. The commit is pushed to a monitored branch.
2. The commit changes files in a monitored folder.

> **Note**
> If your organisation uses a branch other than `main` for this workshop flow, update the branch include list in `ci-build.yml` before relying on automatic execution.

## Before You Start

You need the following:

| Requirement | Why it is needed |
| --- | --- |
| Lab 0 complete | The repository and YAML files must already exist in Azure Repos. |
| Lab 1 complete | The `Commit Solution Changes` pipeline usually creates the `Solutions` and `Settings` folders that this CI pipeline monitors. |
| Project permissions to create/edit pipelines in Azure DevOps | Required to create the YAML pipeline definition. |
| Repository contains `/Assets/Pipelines/ci-build.yml` | Required for Azure DevOps to load the pipeline definition. |
| The solution name in `ci-build.yml` matches your Dataverse solution unique name | Required so the pack task produces the correct managed and unmanaged solution zip files. |

> **Important**
> The workshop sample uses `AccountManager` in `ci-build.yml` as a placeholder. If your solution uses a different unique name, update the YAML before testing the pipeline.

## Understanding the Pipeline Jobs

The table below explains what each major part of `/Assets/Pipelines/ci-build.yml` does.

| YAML Section / Task | Purpose |
| --- | --- |
| `trigger` | Controls when the pipeline starts automatically based on branch and path filters. |
| `stage: buildArtifacts` | Groups all artifact creation work into a single build stage. |
| `job: buildScripts` | Copies repository files from `Scripts` into the artifact staging directory and publishes them as a `Scripts` build artifact. |
| `CopyFiles@2` in `buildScripts` | Collects all PowerShell and supporting files from the repository `Scripts` folder. |
| `PublishBuildArtifacts@1` in `buildScripts` | Publishes the copied scripts so downstream pipelines can download them. |
| `job: buildSettings` | Copies deployment settings files into the artifact staging directory and publishes them as a `Settings` build artifact. |
| `CopyFiles@2` in `buildSettings` | Collects all files under the repository `Settings` folder. |
| `PublishBuildArtifacts@1` in `buildSettings` | Publishes the copied settings as a separate downloadable artifact. |
| `job: buildSolutions` | Installs Power Platform tooling, packs the unpacked Dataverse solution, and publishes solution zip artifacts. |
| `PowerPlatformToolInstaller@2` | Installs the Power Platform Build Tools required for packing solutions. |
| `PowerPlatformPackSolution@2` | Packs the source-controlled solution from `Solutions/<SolutionName>` into deployable solution zip files. |
| `PublishBuildArtifacts@1` in `buildSolutions` | Publishes the packed Dataverse solution files as the `Solutions` build artifact. |

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

3. Select your workshop repository.

![Select workshop repository](./Media/Lesson%200/Step%202/SelectWorkshopRepository.png)

*Screenshot: Selecting the repository that contains the workshop files.*

---

## Step 3 - Choose Existing YAML and Select the CI Pipeline File

1. In the pipeline configuration options, select `Existing Azure Pipelines YAML file`.

![Select Existing YAML option](./Media/Lesson%200/Step%203/SelectExistingYamlOption.png)

*Screenshot: Choosing to use an existing YAML file.*

2. Browse to and select:

	`/Assets/Pipelines/ci-build.yml`

![Select ci-build.yml](./Media/Lesson%200/Step%203/SelectCiBuildYaml.png)

*Screenshot: Selecting the ci-build.yml pipeline file.*

3. Select `Continue`.

![Continue with selected YAML](./Media/Lesson%200/Step%203/ContinueWithSelectedYaml.png)

*Screenshot: Continuing after selecting the YAML file.*

> **Note**
> Unlike the Commit Solution pipeline, this CI pipeline does not call a separate template file. The jobs and tasks are defined directly in `/Assets/Pipelines/ci-build.yml`.

---

## Step 4 - Review the YAML and Understand the Automatic Trigger

1. In the YAML editor, review the `trigger` block near the top of the file.

![Review trigger block](./Media/Lesson%200/Step%204/ReviewTriggerBlock.png)

*Screenshot: Reviewing the branch and path trigger block in the YAML editor.*

2. Confirm that the workshop sample includes:

```yaml
trigger:
  batch: true
  branches:
    include:
      - main
  paths:
    include:
      - Scripts/*
      - Settings/*
      - Solutions/*
```

This configuration means Azure DevOps will automatically queue the pipeline only when qualifying changes are pushed to `main` and those changes are inside one of the listed folders.

3. Review the three jobs in the stage and confirm you can identify their purpose:

	- `Build Scripts`
	- `Build Settings`
	- `Build Solutions`

![Review stage jobs](./Media/Lesson%200/Step%204/ReviewStageJobs.png)

*Screenshot: Reviewing the three jobs defined in the buildArtifacts stage.*

4. In the `Build Solutions` job, locate the `PowerPlatformPackSolution@2` task and confirm the solution source path points to your unpacked solution folder.

![Review solution pack task](./Media/Lesson%200/Step%204/ReviewSolutionPackTask.png)

*Screenshot: Reviewing the solution pack task and source path.*

5. If your solution unique name is not `AccountManager`, update the `SolutionSourceFolder` and `SolutionOutputFile` values in the YAML before saving the pipeline.

![Update solution name placeholder if required](./Media/Lesson%200/Step%204/UpdateSolutionNamePlaceholderIfRequired.png)

*Screenshot: Updating the AccountManager placeholder to the correct solution unique name if required.*

> **Why this matters**
> The CI pipeline packs whatever folder is specified in `Solutions/<SolutionName>`. If the name does not match your actual unpacked solution folder, the solution build job will fail.

6. If your repository contains more than one unpacked Dataverse solution, add a separate `PowerPlatformPackSolution@2` task for each additional solution inside the `buildSolutions` job.

	The workshop sample contains a single pack task for `AccountManager`. A repository with two solutions, for example `AccountManager` and `FieldService`, would need the following inside the `buildSolutions` job steps:

	```yaml
	- task: PowerPlatformPackSolution@2
	  name: packAccountManagerSolution
	  displayName: Pack AccountManager Solution
	  inputs:
	    SolutionType: Both
	    SolutionSourceFolder: $(Build.SourcesDirectory)/Solutions/AccountManager
	    SolutionOutputFile: $(Build.ArtifactStagingDirectory)/Build/Solutions/AccountManager.zip

	- task: PowerPlatformPackSolution@2
	  name: packFieldServiceSolution
	  displayName: Pack FieldService Solution
	  inputs:
	    SolutionType: Both
	    SolutionSourceFolder: $(Build.SourcesDirectory)/Solutions/FieldService
	    SolutionOutputFile: $(Build.ArtifactStagingDirectory)/Build/Solutions/FieldService.zip

	- task: PublishBuildArtifacts@1
	  name: publishSolutionsBuildArtifacts
	  displayName: Publish Solutions Build Artifact
	  inputs:
	    PathtoPublish: '$(Build.ArtifactStagingDirectory)/Build/Solutions'
	    ArtifactName: 'Solutions'
	    publishLocation: 'Container'
	```

	A single `PublishBuildArtifacts@1` task at the end is sufficient because it publishes the entire `Build/Solutions` staging folder, which by then contains a zip for each packed solution.

	Add or update pack tasks now if your repository already contains multiple unpacked solutions.

![Add additional pack tasks for multiple solutions](./Media/Lesson%200/Step%204/AddAdditionalPackTasksForMultipleSolutions.png)

*Screenshot: Adding a PowerPlatformPackSolution task for each additional unpacked solution in the repository.*

> **Note**
> Every solution you want to include in the deployable artifact must have its own `PowerPlatformPackSolution@2` task. Any unpacked solution folder that does not have a corresponding task will be silently omitted from the artifact.

---

## Step 5 - Save the Pipeline as CI Build

1. Select the dropdown next to `Run` and choose `Save`.

![Select Save pipeline](./Media/Lesson%200/Step%205/SelectSavePipeline.png)

*Screenshot: Saving the pipeline definition.*

2. When prompted, set the pipeline name to:

	`CI Build`

![Set pipeline name](./Media/Lesson%200/Step%205/SetPipelineName.png)

*Screenshot: Naming the pipeline CI Build.*

3. Confirm save.

![Confirm pipeline save](./Media/Lesson%200/Step%205/ConfirmPipelineSave.png)

*Screenshot: Confirming the pipeline save action.*

> **Important**
> Save the pipeline from the branch that contains the workshop YAML files. If the wrong branch is selected during creation, Azure DevOps may not find the expected file path.

---

## Step 6 - Validate the Pipeline Configuration and Trigger Intent

1. Open the saved `CI Build` pipeline from the pipelines list.

![Open saved CI Build pipeline](./Media/Lesson%200/Step%206/OpenSavedCiBuildPipeline.png)

*Screenshot: Opening the saved CI Build pipeline from the pipelines list.*

2. Select `Edit` and confirm the YAML path still points to `/Assets/Pipelines/ci-build.yml`.

![Validate YAML path](./Media/Lesson%200/Step%206/ValidateYamlPath.png)

*Screenshot: Validating the YAML path for the CI pipeline definition.*

3. Review the YAML one more time and confirm the automatic trigger logic matches the workshop intent:

	- Branch filter includes `main`
	- Path filters include `Scripts/*`, `Settings/*`, and `Solutions/*`
	- The pipeline will not trigger automatically for unrelated repository changes

![Confirm trigger intent](./Media/Lesson%200/Step%206/ConfirmTriggerIntent.png)

*Screenshot: Confirming the pipeline is configured for selective automatic triggering.*

4. Understand the expected workshop flow:

	- A Dataverse change is committed back to Git by `Commit Solution Changes`
	- That commit updates `Solutions` and/or `Settings`
	- If the commit lands on `main`, `CI Build` starts automatically
	- `CI Build` publishes deployable artifacts for later release stages

![Understand end to end flow](./Media/Lesson%200/Step%206/UnderstandEndToEndFlow.png)

*Screenshot: Reviewing the intended end-to-end flow between commit and CI pipelines.*

5. Do not test the pipeline yet unless instructed. Execution and artifact validation are covered in Lesson 1.

---

## Final Checklist

Before moving to Lesson 1, confirm the following:

1. A pipeline named `CI Build` exists in Azure DevOps.
2. The pipeline references `/Assets/Pipelines/ci-build.yml`.
3. You understand that the pipeline currently auto-triggers only for qualifying changes pushed to `main`.
4. You understand the purpose of the three build jobs: `Scripts`, `Settings`, and `Solutions`.
5. The solution name in the YAML matches your actual unpacked Dataverse solution folder.

## Notes for the Workshop

- This pipeline is intentionally selective. It ignores repository changes outside the monitored folders to avoid unnecessary artifact runs.
- The `Commit Solution Changes` pipeline often creates the exact type of `Settings` and `Solutions` changes that will trigger this pipeline automatically.
- If your organisation uses feature branches rather than direct commits to `main`, update the `branches.include` block so the CI trigger reflects your real branching strategy.
- The `Scripts` artifact supports later deployment tasks, the `Settings` artifact carries tokenised deployment configuration, and the `Solutions` artifact contains the packaged Dataverse solution zip files used in deployment.
- If the `Solutions` or `Settings` folders do not exist yet, complete the Commit Solution lesson and run first so source-controlled outputs are generated before testing the CI build.

