# Lesson 1 - Test CI Pipeline

## Objective

In this lesson you will validate the `CI Build` pipeline end-to-end by triggering a new source-control commit through `Commit Solution Changes`, allowing the CI trigger conditions to queue `CI Build` automatically, then monitoring and diagnosing the CI run.

By the end of this exercise you will have:

1. Manually run `Commit Solution Changes` with valid runtime parameter values to generate a qualifying commit.
2. Confirmed that the successful commit run automatically triggers `CI Build` using branch and path filters.
3. Monitored the CI run in real time and opened detailed logs for each job and task.
4. Practised diagnosing common CI failures using task-level log evidence.
5. Reviewed and validated published build artifacts (`Scripts`, `Settings`, and `Solutions`) from the successful CI run.

Screenshots in this lesson are based on current Azure DevOps portal imagery. Your organisation branding and minor navigation labels may differ slightly.

> **Important**
> In this workshop flow you do **not** normally run `CI Build` manually. You trigger it by creating a qualifying commit (branch + path match), which `Commit Solution Changes` conveniently produces.

## What You Are Testing

In Lesson 0 you created the `CI Build` pipeline using `/Pipelines/ci-build.yml`. That YAML currently uses:

- Branch filter: `main` (or whichever branch you have configured it to monitor on)
- Path filters: `Scripts/*`, `Settings/*`, `Solutions/*`

`Commit Solution Changes` increments solution version and commits updated solution/settings assets back to source control. Even if no new customisation was made in Dataverse since your previous run, the version increment still creates changes that qualify for the CI trigger.

This means the validation sequence for this lesson is:

1. Manually run `Commit Solution Changes`.
2. Wait for it to push changes to the monitored branch/path.
3. Observe `CI Build` queue and run automatically.
4. Validate logs, outputs, and artifacts.

## Before You Start

You need the following:

| Requirement | Why it is needed |
| --- | --- |
| Lesson 0 complete | Ensures `CI Build` exists and points to `/Pipelines/ci-build.yml`. |
| Lab 1 complete | Ensures `Commit Solution Changes` exists and can push source changes. |
| Permission to run pipelines and view logs/artifacts | Required to monitor, diagnose, and validate run outputs. |
| Correct `SolutionName` unique name for your Dataverse solution | Required by `Commit Solution Changes` runtime parameters. |
| Trigger filters in `ci-build.yml` aligned with your working branch | Required for CI to auto-trigger after commit. |

> **Note**
> If your workshop branch is not `main`, update the `trigger.branches.include` block in `/Pipelines/ci-build.yml` before testing automatic CI execution.

---

## Step 1 - Open Commit Solution Changes to Produce a Qualifying Commit

1. Open your Azure DevOps project.

![Open Azure DevOps project](./Media/Lesson%201/Step%201/OpenAzureDevOpsProject.png)

*Screenshot: Opening the Azure DevOps project.*

2. Select `Pipelines` from the left navigation.

![Select Pipelines](./Media/Lesson%201/Step%201/SelectPipelines.png)

*Screenshot: Opening the Pipelines area.*

3. Select the pipeline named `Commit Solution Changes`.

![Open Commit Solution Changes pipeline](./Media/Lesson%201/Step%201/OpenCommitSolutionChangesPipeline.png)

*Screenshot: Opening the Commit Solution Changes pipeline details page.*

> **Why this step matters**
> This pipeline is the easiest way to produce a real commit under `Solutions` and `Settings`, which are the exact folders monitored by `CI Build` trigger paths.

---

## Step 2 - Run Commit Solution Changes with Valid Parameters

1. Select `Run pipeline`.

![Select Run pipeline](./Media/Lesson%201/Step%202/SelectRunPipeline.png)

*Screenshot: Opening the Run pipeline panel.*

2. Confirm the branch is the one monitored by `CI Build` (for workshop sample: `main` or `master`).

![Confirm monitored branch](./Media/Lesson%201/Step%202/ConfirmMonitoredBranch.png)

*Screenshot: Confirming the run branch matches CI trigger configuration.*

3. Provide runtime `SolutionName` using your Dataverse solution unique name (example: `AccountManager`).

![Set SolutionName parameter](./Media/Lesson%201/Step%202/SetSolutionNameParameter.png)

*Screenshot: Entering a valid SolutionName value.*

4. Provide `CommitMessage` with a clear message, for example:

	`chore: trigger CI validation by committing AccountManager solution updates`

![Set CommitMessage parameter](./Media/Lesson%201/Step%202/SetCommitMessageParameter.png)

*Screenshot: Entering CommitMessage for traceable run history.*

5. Select `Run`.

![Queue Commit Solution Changes run](./Media/Lesson%201/Step%202/QueueCommitSolutionChangesRun.png)

*Screenshot: Queueing the Commit Solution Changes run.*

> **Important**
> If this is your first run and Azure DevOps requests resource authorisation, approve the listed protected resources so the pipeline can continue.

---

## Step 3 - Confirm Commit Solution Changes Completes Successfully

1. Open the active run summary and monitor progress until it finishes.

![Monitor Commit Solution Changes run](./Media/Lesson%201/Step%203/MonitorCommitSolutionChangesRun.png)

*Screenshot: Monitoring Commit Solution Changes run progress.*

2. Confirm run result is `Succeeded`.

![Confirm Commit Solution Changes succeeded](./Media/Lesson%201/Step%203/ConfirmCommitSolutionChangesSucceeded.png)

*Screenshot: Successful completion status for Commit Solution Changes.*

3. In logs (or summary links), verify a commit was created and pushed to your target branch.

![Verify commit push output](./Media/Lesson%201/Step%203/VerifyCommitPushOutput.png)

*Screenshot: Reviewing output that confirms commit and push execution.*

> **Expected outcome**
> Once this run pushes qualifying changes to the monitored branch/path, Azure DevOps should queue `CI Build` automatically within moments.

---

## Step 4 - Locate the Automatically Triggered CI Build Run

1. Return to `Pipelines` and open `CI Build`.

![Open CI Build pipeline](./Media/Lesson%201/Step%204/OpenCIBuildPipeline.png)

*Screenshot: Opening CI Build pipeline details.*

2. In `Runs`, locate the newest run triggered by a recent commit.

![Locate latest CI run](./Media/Lesson%201/Step%204/LocateLatestCIRun.png)

*Screenshot: Identifying the latest CI Build run in the run list.*

3. Open the run and confirm trigger reason is commit/CI (not manual).

![Confirm CI trigger reason](./Media/Lesson%201/Step%204/ConfirmCITriggerReason.png)

*Screenshot: Verifying run reason shows automatic CI trigger.*

4. Open associated commit details to confirm source branch and changed paths include monitored folders.

![Review triggering commit details](./Media/Lesson%201/Step%204/ReviewTriggeringCommitDetails.png)

*Screenshot: Reviewing commit files that satisfied CI branch/path filters.*

---

## Step 5 - Monitor CI Build Progress in Real Time

1. From the active CI run, view stage and job progress indicators.

![View CI stage and job progress](./Media/Lesson%201/Step%205/ViewCIStageAndJobProgress.png)

*Screenshot: Viewing live stage/job status in the CI run.*

2. Open each job as it executes and observe task-by-task progress:

	- `Build Scripts`
	- `Build Settings`
	- `Build Solutions`

![Open running CI job details](./Media/Lesson%201/Step%205/OpenRunningCIJobDetails.png)

*Screenshot: Opening an in-progress job to watch tasks execute.*

3. Confirm the run eventually reaches `Succeeded`.

![Confirm CI run succeeded](./Media/Lesson%201/Step%205/ConfirmCIRunSucceeded.png)

*Screenshot: Successful completion of the CI Build run.*

> **Tip**
> If one job fails, do not start by reading all logs. Open the first failed task in that job and work outward from that failure point.

---

## Step 6 - Review Detailed Logs for Each Job and Task

1. Open the completed CI run logs.

![Open CI completed run logs](./Media/Lesson%201/Step%206/OpenCICompletedRunLogs.png)

*Screenshot: Opening detailed logs for the completed CI run.*

2. In `Build Scripts`, validate:

	- `CopyFiles@2` copied files from repository `Scripts` folder.
	- `PublishBuildArtifacts@1` published artifact name `Scripts`.

![Review Build Scripts logs](./Media/Lesson%201/Step%206/ReviewBuildScriptsLogs.png)

*Screenshot: Verifying Build Scripts log output and publish confirmation.*

3. In `Build Settings`, validate:

	- `CopyFiles@2` copied files from repository `Settings` folder.
	- `PublishBuildArtifacts@1` published artifact name `Settings`.

![Review Build Settings logs](./Media/Lesson%201/Step%206/ReviewBuildSettingsLogs.png)

*Screenshot: Verifying Build Settings log output and publish confirmation.*

4. In `Build Solutions`, validate:

	- `PowerPlatformToolInstaller@2` completed successfully.
	- `PowerPlatformPackSolution@2` packed the expected solution folder.
	- `PublishBuildArtifacts@1` published artifact name `Solutions`.

![Review Build Solutions logs](./Media/Lesson%201/Step%206/ReviewBuildSolutionsLogs.png)

*Screenshot: Verifying Build Solutions tool install, pack, and publish outputs.*

5. Optionally download full logs for offline analysis.

![Download CI logs](./Media/Lesson%201/Step%206/DownloadCILogs.png)

*Screenshot: Downloading full CI logs archive for deeper troubleshooting.*

---

## Step 7 - Diagnose and Debug Common CI Failures

If your CI run fails, use this repeatable approach:

1. Open the first failed task and capture exact error text plus nearby lines.

![Open failed CI task log](./Media/Lesson%201/Step%207/OpenFailedCITaskLog.png)

*Screenshot: Opening the first failed task in CI logs.*

2. Match the failure against common causes:

	- Branch/path trigger mismatch (run not auto-queued after commit)
	- Missing repository folder expected by copy tasks (`Scripts`, `Settings`, or `Solutions`)
	- Incorrect solution folder or solution unique name in `PowerPlatformPackSolution@2`
	- Power Platform tooling install failure on agent
	- Artifact path mismatch causing publish task failure

![Review common CI failure indicators](./Media/Lesson%201/Step%207/ReviewCommonCIFailureIndicators.png)

*Screenshot: Reviewing common failure patterns in CI logs.*

3. Validate YAML paths and names in `/Assets/Pipelines/ci-build.yml` against the repository layout.

![Validate CI YAML paths and names](./Media/Lesson%201/Step%207/ValidateCIYamlPathsAndNames.png)

*Screenshot: Comparing YAML task inputs to actual repository folders.*

4. After fixing the root cause, queue another `Commit Solution Changes` run to generate a fresh commit and retrigger CI.

![Queue retrigger commit run](./Media/Lesson%201/Step%207/QueueRetriggerCommitRun.png)

*Screenshot: Queueing another Commit Solution Changes run to retrigger CI automatically.*

> **Tip**
> Debugging is fastest when you fix only the earliest failing task, rerun, and re-evaluate. Later errors are often side effects.

---

## Step 8 - Review Published Build Artifacts from Successful CI Run

1. Open the successful `CI Build` run summary and select the `Artifacts` tab/section.

![Open CI artifacts section](./Media/Lesson%201/Step%208/OpenCIArtifactsSection.png)

*Screenshot: Opening artifacts published by the successful CI run.*

2. Confirm the expected artifacts are present:

	- `Scripts`
	- `Settings`
	- `Solutions`

![Confirm expected artifacts list](./Media/Lesson%201/Step%208/ConfirmExpectedArtifactsList.png)

*Screenshot: Confirming Scripts, Settings, and Solutions artifacts are published.*

3. Browse each artifact and inspect file contents:

	- `Scripts` contains workshop PowerShell scripts.
	- `Settings` contains deployment settings files.
	- `Solutions` contains packed solution zip output.

![Browse artifact contents](./Media/Lesson%201/Step%208/BrowseArtifactContents.png)

*Screenshot: Browsing files inside each published artifact.*

4. Download artifacts and verify they are suitable inputs for downstream deployment pipeline stages.

![Download CI artifacts](./Media/Lesson%201/Step%208/DownloadCIArtifacts.png)

*Screenshot: Downloading artifacts for validation and deployment readiness checks.*

> **Why this matters**
> The deployment pipeline in Lab 3 consumes these artifacts. A successful CI run is only truly useful if the published artifacts contain the expected, deployable outputs.

---

## Final Checklist

Before moving to Lab 3, confirm the following:

1. You ran `Commit Solution Changes` manually with valid parameters.
2. The commit run pushed qualifying changes to the monitored branch/path.
3. `CI Build` was triggered automatically (not manually) from that commit.
4. You monitored CI execution and reviewed task-level logs.
5. You know how to diagnose branch/path trigger, copy, pack, and publish failures.
6. You validated published `Scripts`, `Settings`, and `Solutions` artifacts.

---

## Notes for the Workshop

- In this workshop design, `Commit Solution Changes` is the practical trigger source for CI validation.
- A version increment in the Dataverse solution is usually enough to produce commit changes that satisfy CI path filters.
- If CI does not auto-trigger, first verify branch and path filters in `/Assets/Pipelines/ci-build.yml`, then verify the pushed commit actually touched monitored folders.
- Treat artifacts as the contract between CI and deployment. Always inspect them when validating pipeline quality.

