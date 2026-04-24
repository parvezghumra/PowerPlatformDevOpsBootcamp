# Lesson 1 - Test Deploy Solution Pipeline

## Objective

In this lesson you will run and validate the `Deploy Solution` pipeline across the main deployment scenarios supported by the runtime parameters, including first-time deployment behaviour, update deployments, modern and legacy upgrade paths, and version-control safeguards.

By the end of this exercise you will have:

1. Performed a first-time deployment to a target environment and confirmed fallback behaviour to update import mode.
2. Performed an `Update` deployment where no components were deleted between versions.
3. Performed a `Modern Upgrade` deployment using stage-and-upgrade in one transaction.
4. Performed a `Legacy Upgrade` deployment using holding solution import followed by apply upgrade.
5. Tested `Skip Lower Version` and understood when to keep it enabled or intentionally disable it.
6. Tested `Overwrite Unmanaged Customisations` and understood safe usage scenarios.
7. Deployed an older `CI Build` artifact intentionally and observed expected outcomes.

Screenshots in this lesson are based on current Azure DevOps portal imagery. Your organisation branding and minor navigation labels may differ slightly.

> **Important**
> Complete this lesson in `TEST` first. Avoid testing downgrade or overwrite scenarios in `PROD`.

## What You Are Testing

In Lesson 0 you created `Deploy Solution` using `/Pipelines/deploy-solution.yml` and `/Templates/deploy-solution-template.yml`.

This lesson validates runtime behaviour across real deployment conditions:

1. New install path (`currentSolutionStatus = NotInstalled`) where pipeline forces update-style import regardless of selected mode.
2. Existing install path with no deleted components where direct `Update` is sufficient.
3. Existing install path where `Modern Upgrade` uses `StageAndUpgrade`.
4. Existing install path where `Legacy Upgrade` imports as holding then applies upgrade.
5. Version-protection logic controlled by `SkipLowerVersion` when selecting older CI builds.
6. Layer-overwrite behaviour controlled by `OverwriteUnmanagedCustomisations`.

## Before You Start

You need the following:

| Requirement | Why it is needed |
| --- | --- |
| Lesson 0 complete | Ensures `Deploy Solution` pipeline exists and points to workshop YAML. |
| At least two successful `CI Build` runs for the same solution with different versions | Required to test newer vs older build deployment scenarios. |
| `TEST` environment with approval gate configured | Required to validate deployment job and approval behaviour safely. |
| Solution unique name (example: `AccountManager`) | Required runtime input for every deployment run. |
| Permissions to run pipelines and approve environment deployments | Required to execute and complete each scenario end-to-end. |

> **Note**
> If you currently have only one CI artifact version, trigger another `Commit Solution Changes` run and allow `CI Build` to complete before continuing.

> **Workshop note**
> If you plan to test all deployment modes in this lesson (`Update`, `Modern Upgrade`, and `Legacy Upgrade`), run `Commit Solution Changes` before each deployment-mode attempt, then wait for the corresponding `CI Build` run to complete. This ensures each `Deploy Solution` run can select a distinct, newly produced CI artifact version and makes scenario outcomes easier to validate.

---

## Step 1 - Open Deploy Solution and Select the CI Build Artifact Version

1. Open your Azure DevOps project.

![Open Azure DevOps project](./Media/Lesson%201/Step%201/OpenAzureDevOpsProject.png)

*Screenshot: Opening the Azure DevOps project.*

2. Select `Pipelines` and open the pipeline named `Deploy Solution`.

![Open Deploy Solution pipeline](./Media/Lesson%201/Step%201/OpenDeploySolutionPipeline.png)

*Screenshot: Opening the Deploy Solution pipeline details page.*

3. Select `Run pipeline`.

![Select Run pipeline](./Media/Lesson%201/Step%201/SelectRunPipeline.png)

*Screenshot: Opening the Run pipeline panel for Deploy Solution.*

4. In the `Resources` section, expand the `CI-Build` resource selector and observe available CI runs.

![Open CI-Build resource selector](./Media/Lesson%201/Step%201/OpenCIBuildResourceSelector.png)

*Screenshot: Opening the pipeline resource run selector for CI Build artifacts.*

5. Select the most recent successful CI run for baseline testing.

![Select latest CI Build run](./Media/Lesson%201/Step%201/SelectLatestCIBuildRun.png)

*Screenshot: Selecting the latest successful CI Build artifact source.*

> **Why this matters**
> `Deploy Solution` always deploys from the selected CI run artifacts, not directly from repository files at deployment time.

> **Monitoring tip**
> For every scenario in this lesson, keep the run summary page open after selecting `Run`. Watch stage state changes (`Queued` -> `In progress` -> `Succeeded`/`Failed`), open the active deployment job, and then drill into the currently running task so you can see progress in real time rather than waiting for the full run to finish.

---

## Step 2 - First Deployment to Target Environment (Fallback to Update)

Use this scenario when the solution is not already installed in the target environment.

1. In `Run pipeline`, set parameters:

	- `SolutionName`: your solution unique name (example: `AccountManager`)
	- `Solution Import Mode`: choose `Modern Upgrade` (or any value for this test)
	- `Overwrite Unmanaged Customisations`: `false`
	- `Skip Lower Version`: `true`

![Set first deployment parameters](./Media/Lesson%201/Step%202/SetFirstDeploymentParameters.png)

*Screenshot: Entering runtime values for first deployment test.*

2. Select `Run`.

![Queue first deployment run](./Media/Lesson%201/Step%202/QueueFirstDeploymentRun.png)

*Screenshot: Queueing first deployment run.*

3. Approve the `TEST` environment deployment when prompted.

![Approve TEST environment deployment](./Media/Lesson%201/Step%202/ApproveTestEnvironmentDeployment.png)

*Screenshot: Approving TEST environment gate for deployment job.*

4. Open logs and validate behaviour:

	- `Check Solution Installation Status` reports solution not installed.
	- `Import Solution as Update` runs.
	- Upgrade-specific task path is not used for this first deployment.
	- Stage timeline shows approval gate completed before task execution starts.

![Verify first deployment fallback behaviour](./Media/Lesson%201/Step%202/VerifyFirstDeploymentFallbackBehaviour.png)

*Screenshot: Verifying pipeline used update-style import on first install.*

> **Expected behaviour**
> For first deployment, update import path is used regardless of selected import mode. This is by design.

---

## Step 3 - Update Deployment When No Components Were Deleted

Use this scenario when solution changes are additive or modifications only, with no deleted components requiring upgrade flow.

1. Queue a new `Deploy Solution` run and select the newest CI artifact version.

![Select newest CI artifact for update](./Media/Lesson%201/Step%203/SelectNewestCiArtifactForUpdate.png)

*Screenshot: Selecting latest artifact for update deployment scenario.*

2. Set parameters:

	- `Solution Import Mode`: `Update`
	- `Overwrite Unmanaged Customisations`: `false`
	- `Skip Lower Version`: `true`

![Set update deployment parameters](./Media/Lesson%201/Step%203/SetUpdateDeploymentParameters.png)

*Screenshot: Entering runtime values for update deployment.*

3. Run and approve `TEST` deployment.

![Run and approve update deployment](./Media/Lesson%201/Step%203/RunAndApproveUpdateDeployment.png)

*Screenshot: Running update deployment and passing environment approval.*

4. Validate logs show `Import Solution as Update` task executed successfully.

	Also confirm the task summary shows no warnings about missing artifact files (`Scripts`, `Settings`, `Solutions`) and that the transformed deployment settings file was found in the expected pipeline workspace path.

![Verify update import task execution](./Media/Lesson%201/Step%203/VerifyUpdateImportTaskExecution.png)

*Screenshot: Confirming update import task completed successfully.*

> **Use this mode when**
> You are deploying standard iterative changes and do not require component deletion handling via upgrade flow.

---

## Step 4 - Modern Upgrade Deployment (Stage and Upgrade in One Transaction)

Use this scenario when solution is already installed and you want upgrade semantics with a single stage-and-upgrade operation.

1. Queue another run and select a CI artifact newer than what is currently installed.

![Select newer artifact for modern upgrade](./Media/Lesson%201/Step%204/SelectNewerArtifactForModernUpgrade.png)

*Screenshot: Selecting a newer artifact for modern upgrade test.*

2. Set parameters:

	- `Solution Import Mode`: `Modern Upgrade`
	- `Overwrite Unmanaged Customisations`: `false`
	- `Skip Lower Version`: `true`

![Set modern upgrade parameters](./Media/Lesson%201/Step%204/SetModernUpgradeParameters.png)

*Screenshot: Entering runtime values for modern upgrade.*

3. Run and approve deployment.

![Run modern upgrade deployment](./Media/Lesson%201/Step%204/RunModernUpgradeDeployment.png)

*Screenshot: Queueing and approving modern upgrade deployment.*

4. Validate logs show `Import Solution as Stage and Upgrade` executed.

	If this scenario fails, open the first failed task and capture the exact error text plus the 20-30 surrounding log lines before making any changes.

![Verify stage and upgrade task](./Media/Lesson%201/Step%204/VerifyStageAndUpgradeTask.png)

*Screenshot: Confirming stage-and-upgrade task path in logs.*

> **Use this mode when**
> You want upgrade behaviour and your environment supports the modern stage-and-upgrade process.

---

## Step 5 - Legacy Upgrade Deployment (Holding Import and Deferred Apply)

Use this scenario when you need classic two-step upgrade behaviour.

1. Queue a new run with a newer CI artifact.

![Select artifact for legacy upgrade](./Media/Lesson%201/Step%205/SelectArtifactForLegacyUpgrade.png)

*Screenshot: Selecting artifact for legacy upgrade scenario.*

2. Set parameters:

	- `Solution Import Mode`: `Legacy Upgrade`
	- `Overwrite Unmanaged Customisations`: `false`
	- `Skip Lower Version`: `true`

![Set legacy upgrade parameters](./Media/Lesson%201/Step%205/SetLegacyUpgradeParameters.png)

*Screenshot: Entering runtime values for legacy upgrade.*

3. Run and approve deployment.

![Run legacy upgrade deployment](./Media/Lesson%201/Step%205/RunLegacyUpgradeDeployment.png)

*Screenshot: Queueing and approving legacy upgrade run.*

4. Validate logs show sequence:

	1. `Import Solution as Holding Solution`
	2. `Check Import Outcome`
	3. `Apply Upgrade`

	If `Apply Upgrade` does not run, check the `Check Import Outcome` task result first. Legacy upgrade depends on a successful holding import state.

![Verify holding and apply upgrade sequence](./Media/Lesson%201/Step%205/VerifyHoldingAndApplyUpgradeSequence.png)

*Screenshot: Confirming holding import and apply upgrade tasks in sequence.*

> **Use this mode when**
> You need compatibility with environments or operational standards that require separated import and apply-upgrade steps.

---

## Step 6 - Test Skip Lower Version and Deploy an Older CI Build

This step demonstrates safe handling of intentional or accidental older-build deployments.

1. Queue `Deploy Solution` and intentionally select an older successful CI run from the `CI-Build` resource selector.

![Select older CI Build run](./Media/Lesson%201/Step%206/SelectOlderCIBuildRun.png)

*Screenshot: Selecting an older CI artifact version intentionally.*

2. Set `Skip Lower Version` to `true` and run.

![Set skip lower version true](./Media/Lesson%201/Step%206/SetSkipLowerVersionTrue.png)

*Screenshot: Running older-build deployment with skip lower version protection enabled.*

3. Validate logs show lower/equal version import is skipped or blocked according to task behaviour.

![Verify lower version was skipped](./Media/Lesson%201/Step%206/VerifyLowerVersionWasSkipped.png)

*Screenshot: Confirming version-protection behaviour prevented downgrade.*

4. Re-run same older artifact with `Skip Lower Version` set to `false` (TEST only).

![Set skip lower version false](./Media/Lesson%201/Step%206/SetSkipLowerVersionFalse.png)

*Screenshot: Re-running older artifact deployment with version skip disabled.*

5. Validate run outcome and logs to understand downgrade/reimport effect in your environment.

	Record which selected `CI-Build` run version was used for each test so you can correlate behaviour with exact artifact version during troubleshooting.

![Review downgrade test outcome](./Media/Lesson%201/Step%206/ReviewDowngradeTestOutcome.png)

*Screenshot: Reviewing deployment result when lower-version guard is disabled.*

> **When to use**
> Keep `Skip Lower Version = true` as default safety. Set to `false` only for controlled rollback/reimport scenarios with explicit approval.

---

## Step 7 - Test Overwrite Unmanaged Customisations

This step helps you understand managed layer overwrite behaviour.

1. Ensure target environment contains unmanaged customisations over the managed solution layer (if safe test data is available).

![Prepare unmanaged customisation test state](./Media/Lesson%201/Step%207/PrepareUnmanagedCustomisationTestState.png)

*Screenshot: Confirming unmanaged customisations exist in target environment for testing.*

2. Run deployment with `Overwrite Unmanaged Customisations = false` and observe that unmanaged layer is preserved.

![Run with overwrite false](./Media/Lesson%201/Step%207/RunWithOverwriteFalse.png)

*Screenshot: Deploying with overwrite unmanaged customisations disabled.*

3. Run deployment with `Overwrite Unmanaged Customisations = true` (TEST only) and compare resulting behaviour.

![Run with overwrite true](./Media/Lesson%201/Step%207/RunWithOverwriteTrue.png)

*Screenshot: Deploying with overwrite unmanaged customisations enabled.*

4. Document outcome and decide organisation default for this parameter.

	When comparing outcomes, review both pipeline task results and actual Dataverse component state to confirm whether unmanaged layers were retained or overwritten as expected.

![Document overwrite behaviour outcome](./Media/Lesson%201/Step%207/DocumentOverwriteBehaviourOutcome.png)

*Screenshot: Capturing observed differences between overwrite false and true runs.*

> **When to use**
> Use `true` when you intentionally want managed solution contents to replace unmanaged changes. Keep `false` where environment-level unmanaged edits must be retained.

---

## Step 8 - Compare Scenario Runs and Validate Deployment History

1. Open `Deploy Solution` pipeline run history and locate runs from each scenario in this lesson.

![Open deployment run history](./Media/Lesson%201/Step%208/OpenDeploymentRunHistory.png)

*Screenshot: Opening Deploy Solution run history for scenario comparison.*

2. Open each run and record key inputs:

	- Selected `CI-Build` run
	- `Solution Import Mode`
	- `Skip Lower Version`
	- `Overwrite Unmanaged Customisations`

![Compare runtime parameters across runs](./Media/Lesson%201/Step%208/CompareRuntimeParametersAcrossRuns.png)

*Screenshot: Comparing runtime parameter selections across scenario runs.*

3. Review environment deployment history for `TEST` to confirm approved deployments and timestamps.

![Review TEST environment deployment history](./Media/Lesson%201/Step%208/ReviewTestEnvironmentDeploymentHistory.png)

*Screenshot: Reviewing Azure DevOps environment deployment history entries.*

4. Capture final notes for your team on which import mode and parameter defaults to use in standard operations.

![Capture recommended deployment defaults](./Media/Lesson%201/Step%208/CaptureRecommendedDeploymentDefaults.png)

*Screenshot: Recording recommended operational defaults from test outcomes.*

---

## Monitoring and Troubleshooting Guide

Use this quick guide during any deployment run in this lesson.

### Monitor Active Runs

1. Open the pipeline run summary immediately after queueing the run.
2. Watch stage timeline for approval and execution transitions.
3. Select the active deployment job (`deployToTEST` or `deployToPROD`) to view live task progression.
4. Keep the live log pane open during long-running import steps to detect early warnings.

### Review Detailed Logs for Each Run

1. From the run summary, open the completed stage and select the deployment job.
2. Expand each task in execution order and confirm start/end times and result status.
3. Focus on these tasks first for deployment diagnostics:

	- `Check Solution Installation Status`
	- `Transform Deployment Settings File`
	- The selected import task path (`Update`, `Stage and Upgrade`, or `Holding Solution`)
	- `Check Import Outcome` and `Apply Upgrade` (legacy mode)

4. Download full logs when needed so you can compare failing and succeeding runs side-by-side.

### Diagnose Failed Deployments (Fast Path)

When a run fails, use this sequence:

1. Open the first failed task, not the last task in the job.
2. Capture the exact error line and nearby context.
3. Match the failure to likely cause:

	- Approval not granted in target environment: deployment remains pending.
	- Artifact mismatch or missing files: selected CI run does not contain expected solution/settings outputs.
	- Wrong solution unique name: import task cannot find expected managed zip.
	- Token transformation issues: required variable values are missing or invalid for target environment.
	- Version guard conflict: `Skip Lower Version = true` blocks lower/equal version import.
	- Upgrade path mismatch: selected mode does not match actual install/state preconditions.

4. For failures in `TransformDeploymentSettingsFile.ps1`, use this targeted diagnosis:

	- Symptom: task fails while resolving deployment settings values before import.
	- Common cause A (Environment Variable): the deployed solution includes one or more Dataverse Environment Variables, but no value has been configured for that variable in the target environment variable group (`TEST Environment Variables` or `PROD Environment Variables`).
	- Common cause B (Connection Reference): no valid Connection exists in the target Dataverse environment for the connector required by the Connection Reference, or the existing Connection is not shared with the deployment service principal.

5. Resolve `TransformDeploymentSettingsFile.ps1` failures as follows:

	- Environment Variable fix: add the missing variable entry and value to the variable group for the target stage/environment, save, then queue a new deployment run.
	- Connection Reference fix: create a Connection in the target environment for the required connector, share that Connection with the deployment service principal, then queue a new deployment run.

6. After applying either fix, re-run with the same artifact and parameters first to confirm only the identified issue changed.

7. Fix one root cause at a time, then queue a new run.
8. Re-test using the same parameter set first, then change one parameter only if needed.

> **Troubleshooting tip**
> Keep a simple run log for each scenario: run ID, selected CI run, parameter values, first failed task (if any), and final resolution. This makes workshop debugging and team handover significantly faster.

---

## Final Checklist

Before completing Lab 3, confirm the following:

1. You validated first deployment fallback to update-style import when solution was not installed.
2. You validated standard `Update` deployment for no-deletion change sets.
3. You validated `Modern Upgrade` stage-and-upgrade execution path.
4. You validated `Legacy Upgrade` holding import and apply-upgrade execution path.
5. You deployed an older CI build intentionally and observed `Skip Lower Version` behaviour with both `true` and `false`.
6. You tested `Overwrite Unmanaged Customisations` and understood when to keep it disabled or enable it deliberately.
7. You reviewed run history and environment deployment history to confirm full traceability.

---

## Notes for the Workshop

- For first install to an environment, import behaves as update even if upgrade mode is selected.
- `Update` mode is best for straightforward iterations where deleted-component upgrade semantics are not required.
- `Modern Upgrade` is preferred when supported; `Legacy Upgrade` remains useful for compatibility and explicit two-step control.
- Keep `Skip Lower Version` enabled by default to avoid accidental downgrades.
- Use older CI builds only in controlled scenarios (rollback/recovery drills) and always document why.
- Keep `Overwrite Unmanaged Customisations` disabled unless replacing unmanaged layer is intentional and approved.

