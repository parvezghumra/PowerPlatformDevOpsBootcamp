# Lesson 2 - Test Commit Solution Pipeline

## Objective

In this lesson you will manually run the `Commit Solution Changes` Azure DevOps pipeline, provide runtime parameter values, authorise any protected resources on first run, monitor execution, inspect logs, and validate the resulting Git commit.

By the end of this exercise you will have:

1. Triggered the `Commit Solution Changes` pipeline manually from Azure DevOps.
2. Provided valid runtime values for `SolutionName` and `CommitMessage`.
3. Understood how and when to reference Azure DevOps work items in commit messages using `#` syntax.
4. Authorised required resources on first run (if prompted), such as Service Connections, Environments, or Variable Groups.
5. Monitored run progress and inspected detailed logs for troubleshooting.
6. Verified that unpacked solution files and deployment settings were committed to your Git repository.
7. Explored traceability links between commits and work items (when work items are referenced).

Screenshots in this lesson are based on current Azure DevOps portal imagery. Your organisation branding and minor navigation labels may differ slightly.

> **Important**
> This pipeline is intended to commit source-controlled solution assets from your **Development** environment. It is not a deployment pipeline.

## What This Pipeline Run Does

When you run `Commit Solution Changes`, the pipeline uses the template created in Lesson 1 and performs these high-level actions:

1. Exports unmanaged and managed Dataverse solution packages from Development.
2. Unpacks the unmanaged solution into source-control format under `Solutions/<SolutionName>`.
3. Generates and tokenises deployment settings under `Settings/<SolutionName>.json`.
4. Commits and pushes any resulting changes back to the current Git branch.

This gives you a versioned record of configuration and metadata changes made in Dataverse.

## Before You Start

You need the following:

| Requirement | Why it is needed |
| --- | --- |
| Lesson 0 and Lesson 1 complete | Ensures the solution exists in Development and the pipeline is already created. |
| Pipeline permissions to run and view logs | Required to queue, monitor, and troubleshoot pipeline runs. |
| Permissions to use protected resources (or ability to request/approve access) | First run may require authorisation to Service Connections, Variable Groups, or Environments. |
| A valid solution unique name from Dataverse (for example `AccountManager`) | The export tasks use this value to locate the solution to export. |

> **Note**
> If your Azure DevOps project is brand new and has no work items yet, you can still complete this lesson using a normal commit message with no `#` reference.

---

## Step 1 - Open the Commit Solution Changes Pipeline

1. Open your Azure DevOps project.

![Open Azure DevOps project](./Media/Lesson%202/Step%201/OpenAzureDevOpsProject.png)

*Screenshot: Opening the Azure DevOps project.*

2. Select `Pipelines` from the left navigation.

![Select Pipelines](./Media/Lesson%202/Step%201/SelectPipelines.png)

*Screenshot: Opening the Pipelines area.*

3. Select the pipeline named `Commit Solution Changes`.

![Open Commit Solution Changes pipeline](./Media/Lesson%202/Step%201/OpenCommitSolutionChangesPipeline.png)

*Screenshot: Opening the Commit Solution Changes pipeline details page.*

---

## Step 2 - Manually Run the Pipeline and Provide Runtime Parameters

1. Select `Run pipeline`.

![Select Run pipeline](./Media/Lesson%202/Step%202/SelectRunPipeline.png)

*Screenshot: Opening the Run pipeline panel.*

2. Confirm the correct branch is selected (typically leave the default main/master branch selected).

![Confirm branch selection](./Media/Lesson%202/Step%202/ConfirmBranchSelection.png)

*Screenshot: Confirming the branch used for the run.*

3. In runtime parameters, provide `SolutionName` using the **solution unique name** (not the display name). For this workshop use:

	`AccountManager`

![Set SolutionName parameter](./Media/Lesson%202/Step%202/SetSolutionNameParameter.png)

*Screenshot: Entering the SolutionName runtime parameter.*

> **Why the unique name matters**
> Dataverse export tasks identify solutions by unique name. If you enter a friendly display label instead, the export task may fail with a solution not found error.

4. In `CommitMessage`, enter a meaningful message that describes the change and select `Next: Resources`. Use one of the following patterns:

	- Without work item reference (valid for brand new projects):
	  `chore: commit AccountManager solution updates from Development`

	- With work item reference (if work item exists):
	  `chore: commit AccountManager solution updates #123`

![Set CommitMessage parameter](./Media/Lesson%202/Step%202/SetCommitMessageParameter.png)

*Screenshot: Entering the CommitMessage runtime parameter.*

> **Traceability tip**
> Using `#<WorkItemId>` in the commit message (for example `#123`) enables Azure DevOps to link the commit to that work item automatically.

5. Select `Run` to queue the pipeline.

![Queue pipeline run](./Media/Lesson%202/Step%202/QueuePipelineRun.png)

*Screenshot: Queueing the pipeline run with runtime parameter values.*

---

## Step 3 - Resolve First-Run Resource Authorisation Prompts (If Shown)

On first execution, Azure DevOps may block the run until protected resources are authorised.

1. If you see a warning such as `This pipeline needs permission to access a resource before this run can continue`, open the prompt details.

![Open authorisation prompt](./Media/Lesson%202/Step%203/OpenAuthorisationPrompt.png)

*Screenshot: Pipeline prompt requesting access to protected resources.*

2. Review each listed resource. Common examples include:

	- Service Connections
	- Variable Groups
	- Environments

![Review protected resources list](./Media/Lesson%202/Step%203/ReviewProtectedResourcesList.png)

*Screenshot: Reviewing resources that require authorisation.*

3. Select `Permit`, `Authorize resources`, or equivalent action for each required resource.

![Authorize resources](./Media/Lesson%202/Step%203/AuthorizeResources.png)

*Screenshot: Authorising required resources for the pipeline.*

4. Confirm the run continues automatically (or rerun if Azure DevOps requires a new queue action).

![Run continues after authorisation](./Media/Lesson%202/Step%203/RunContinuesAfterAuthorisation.png)

*Screenshot: Pipeline continuing after resource access is granted.*

> **Note**
> If your account cannot approve access, ask a Project Administrator to authorise the resources, then queue the run again.

---

## Step 4 - Monitor Pipeline Run Progress

1. Open the active run summary page.

![Open run summary](./Media/Lesson%202/Step%204/OpenRunSummary.png)

*Screenshot: Viewing the active pipeline run summary.*

2. Observe stage/job/task progress indicators and elapsed time.

![Observe stage and task progress](./Media/Lesson%202/Step%204/ObserveStageAndTaskProgress.png)

*Screenshot: Monitoring live status for each task.*

3. Select the running job to view live logs.

![Open running job logs](./Media/Lesson%202/Step%204/OpenRunningJobLogs.png)

*Screenshot: Opening live logs while the job is running.*

4. Wait for the run to complete and confirm status is `Succeeded`.

![Confirm run succeeded](./Media/Lesson%202/Step%204/ConfirmRunSucceeded.png)

*Screenshot: Successful pipeline completion status.*

---

## Step 5 - Explore Detailed Logs and Understand the Executed Steps

1. From the completed run, open the job logs.

![Open completed run logs](./Media/Lesson%202/Step%205/OpenCompletedRunLogs.png)

*Screenshot: Opening full logs for the completed run.*

2. Expand each task and review the sequence. You should see tasks for:

	- Git setup
	- Power Platform tools installation
	- Connection variable setup
	- Solution version sync and set
	- Publish customisations
	- Export (unmanaged and managed)
	- Unpack solution
	- Generate/tokenise deployment settings
	- Commit and push changes

![Review task sequence in logs](./Media/Lesson%202/Step%205/ReviewTaskSequenceInLogs.png)

*Screenshot: Reviewing the ordered task list in the logs.*

3. For each task, inspect output lines for confirmation messages, generated paths, and warnings.

![Inspect task output details](./Media/Lesson%202/Step%205/InspectTaskOutputDetails.png)

*Screenshot: Inspecting detailed output from an individual task.*

4. If needed, download full logs for offline review.

![Download full logs](./Media/Lesson%202/Step%205/DownloadFullLogs.png)

*Screenshot: Downloading pipeline logs as an archive.*

---

## Step 6 - Diagnose Common Failures (If the Run Does Not Succeed)

If your run fails, use this process:

1. Open the failed task in logs and read the first error line and the surrounding context.

![Open failed task log](./Media/Lesson%202/Step%206/OpenFailedTaskLog.png)

*Screenshot: Opening the task where the failure occurred.*

2. Check whether the failure is related to one of these common causes:

	- Incorrect `SolutionName` (not the Dataverse unique name)
	- Missing/unauthorised Service Connection
	- Missing/unauthorised Variable Group
	- `TokeniseDeploymentSettingsFile.ps1` failed because new Environment Variables or Connection References in the solution are not yet mapped in `Generic Variables`
	- Incorrect environment URL or credentials in variables
	- Branch permission issue when pushing commit

![Review common failure indicators](./Media/Lesson%202/Step%206/ReviewCommonFailureIndicators.png)

*Screenshot: Reviewing log patterns for common failures.*

3. If the failure occurred in `TokeniseDeploymentSettingsFile.ps1`, update token mappings in the `Generic Variables` variable group:

	1. Open `Pipelines` > `Library` > `Generic Variables`.

	![Open Generic Variables group](./Media/Lesson%202/Step%206/OpenGenericVariablesGroup.png)

	*Screenshot: Opening the Generic Variables variable group from Pipeline Library.*

	2. Edit `EnvironmentVariableTokens` and add entries for any new Dataverse Environment Variables in your solution`.

	```json
	[
	  { 
		"SchemaName": "ppdobc_TaskSubject", 
		"StaticToken": "TaskSubject"
	  }
	]
	```

	![Update EnvironmentVariableTokens](./Media/Lesson%202/Step%206/UpdateEnvironmentVariableTokens.png)

	*Screenshot: Adding missing EnvironmentVariableTokens mappings in Generic Variables.*

	3. Edit `ConnectionReferenceTokens` and add entries for any new Connection References in your solution.

	```json
	[
	  {
	    "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_commondataserviceforapps",
	    "StaticToken": "DataverseConnection"
	  }
	]
	```

	![Update ConnectionReferenceTokens](./Media/Lesson%202/Step%206/UpdateConnectionReferenceTokens.png)

	*Screenshot: Adding missing ConnectionReferenceTokens mappings in Generic Variables.*

	4. Save the variable group changes.

	![Save Generic Variables updates](./Media/Lesson%202/Step%206/SaveGenericVariablesUpdates.png)

	*Screenshot: Saving Generic Variables after updating token arrays.*

	> **Important**
	> Keep both values as valid JSON arrays. A malformed JSON value in either variable will also cause tokenisation to fail.

4. Apply the fix, then select `Run new` to queue another run.

![Queue rerun after fix](./Media/Lesson%202/Step%206/QueueRerunAfterFix.png)

*Screenshot: Queueing a new run after resolving the issue.*

> **Tip**
> Start by fixing the earliest failing task. Later errors are often downstream effects.

---

## Step 7 - Validate the Git Commit and Changed Files

1. From the pipeline summary, open the commit link shown in the final `Commit Solution Changes` task output, or navigate to `Repos` > `Commits`.

![Open commit from pipeline](./Media/Lesson%202/Step%207/OpenCommitFromPipeline.png)

*Screenshot: Opening the commit produced by the pipeline run.*

2. Review changed files and confirm expected outputs exist, including:

	- `Solutions/AccountManager/...` (unpacked solution content)
	- `Settings/AccountManager.json` (tokenised deployment settings)

![Review committed solution files](./Media/Lesson%202/Step%207/ReviewCommittedSolutionFiles.png)

*Screenshot: Reviewing unpacked solution and settings file changes in the commit.*

3. Confirm the commit message matches the runtime `CommitMessage` parameter you provided.

![Verify commit message](./Media/Lesson%202/Step%207/VerifyCommitMessage.png)

*Screenshot: Verifying the pushed commit message content.*

---

## Step 8 - Explore Work Item Traceability (When Work Item IDs Are Used)

If your commit message included `#<WorkItemId>`, confirm bi-directional links:

1. Open the commit details and locate linked work item references.

![View work item link from commit](./Media/Lesson%202/Step%208/ViewWorkItemLinkFromCommit.png)

*Screenshot: Commit showing link to referenced work item.*

2. Open the linked work item and review the `Development` or `Links` section for the backlink to the commit.

![View commit link from work item](./Media/Lesson%202/Step%208/ViewCommitLinkFromWorkItem.png)

*Screenshot: Work item showing backlink to the commit.*

3. If your project has no work items yet, create a simple task/bug/user story, rerun the pipeline with `#<new id>` in the commit message, then verify links again.

![Create first work item if needed](./Media/Lesson%202/Step%208/CreateFirstWorkItemIfNeeded.png)

*Screenshot: Creating a work item in a new project for traceability testing.*

> **Note**
> End-to-end traceability is strongest when every solution commit references the work item that drove the change.

---

## Final Checklist

Before moving to the next lab, confirm the following:

1. You manually ran `Commit Solution Changes` from Azure DevOps.
2. You provided valid `SolutionName` and `CommitMessage` parameter values.
3. You resolved any first-run resource authorisation prompts.
4. You reviewed run progress and task-level logs.
5. You can identify how to diagnose and rerun after failures, including token mapping failures in `Generic Variables`.
6. You verified unpacked solution and deployment settings files were committed to the repository.
7. You validated commit/work item traceability links (or understand how to test this after creating a first work item).

---

## Notes for the Workshop

- `SolutionName` must match the Dataverse unique name exactly.
- `CommitMessage` is not just documentation; it is also the traceability bridge to Azure DevOps work items when `#<id>` is included.
- On first run, authorising protected resources is a normal security step in Azure DevOps.
- If tokenisation fails in `TokeniseDeploymentSettingsFile.ps1`, update `EnvironmentVariableTokens` and `ConnectionReferenceTokens` in `Generic Variables` to include any new items introduced in the solution.
- If no Dataverse changes exist since the last successful run, the commit step may report no changes to commit.

