# Lesson 2 - Create and Configure Azure DevOps Environments

## Objective

In this lesson you will create Azure DevOps Environment representations for your Power Platform Development, Test, and Production environments. You will also configure pre-deployment approval checks so deployment stages cannot proceed until an approver explicitly approves them.

By the end of this exercise you will have:

1. Three Azure DevOps environments in your project: Development, Test, and Production.
2. Pre-deployment approval checks configured for each environment.
3. Pipeline permissions configured so your deployment pipeline can target each environment.

Screenshots in this lesson are based on current Azure DevOps portal imagery. Your organisation branding and minor navigation labels may differ slightly.

> **Important**
> Azure DevOps Environments are not the same as Power Platform environments. In this workshop, each Azure DevOps Environment acts as a deployment gate and governance layer that maps to one Power Platform environment.

## What You Are Building

For this workshop you are setting up environment-level deployment controls in Azure DevOps. Pipelines will target these environments in later labs, and Azure DevOps will enforce checks before stage execution.

You will configure one approval check per environment so each deployment requires manual confirmation before it can continue. This provides a clear promotion workflow from Development to Test to Production.

## Before You Start

You need the following:

| Requirement | Why it is needed |
| --- | --- |
| An Azure DevOps organisation and project | Environments are created at project scope. |
| Project Administrator, Build Administrator or Contributor role (or equivalent permission to manage environments and checks) as well as Basic level access (rather than Stakeholder) | Required to create environments and configure checks. |
| Service connection names from Lesson 1 | Helpful for consistent naming and later pipeline configuration. |
| Users or groups who will approve deployments | Needed when configuring approval checks. |
| A naming convention for environments | Keeps pipeline references and governance clear. |

## Values to Record

Capture these values as you configure each environment. You will use them in later pipeline lessons.

| Value | Example | Where you get it |
| --- | --- | --- |
| Azure DevOps Environment name (Development) | `pp-dev` | Entered by you |
| Azure DevOps Environment name (Test) | `pp-test` | Entered by you |
| Azure DevOps Environment name (Production) | `pp-prod` | Entered by you |
| Approval users/groups for each environment | `Project Administrators` or named users | Selected by you |

## Step 1 - Navigate to Environments in Azure DevOps

1. Open your Azure DevOps project.

![Open Azure DevOps project](./Media/Lesson%202/Step%201/OpenAzureDevOpsProject.png)

*Screenshot: Opening the Azure DevOps project.*

2. Select `Pipelines` from the left navigation.

![Select Pipelines](./Media/Lesson%202/Step%201/SelectPipelines.png)

*Screenshot: Selecting Pipelines from the left navigation.*

3. Select `Environments`.

![Select Environments](./Media/Lesson%202/Step%201/SelectEnvironments.png)

*Screenshot: Selecting Environments.*

## Step 2 - Create the Development Environment

1. Select `Create environment`. 

![Select Create environment](./Media/Lesson%202/Step%202/SelectCreateEnvironment.png)

*Screenshot: Selecting Create environment.*

2. Enter the environment details:

	| Setting | Value |
	| --- | --- |
	| Name | A meaningful name such as `pp-dev` |
	| Description | Optional text such as `Power Platform Development deployment gate` |
	| Resource | Leave as `None` for this workshop |

![Enter Development environment details](./Media/Lesson%202/Step%202/EnterDevelopmentEnvironmentDetails.png)

*Screenshot: Entering Development environment details.*

3. Select `Create`. If you get an `Access Denied` error when you attempt to create the environment, double-check that you have the `Project Administrator`, `Build Administrator` or `Contributor` role assigned, as well as the `Basic` level of access (rather than `Stakeholder`)

![Create Development environment](./Media/Lesson%202/Step%202/CreateDevelopmentEnvironment.png)

*Screenshot: Creating the Development environment.*

4. Confirm the new environment opens successfully.

![Verify Development environment](./Media/Lesson%202/Step%202/VerifyDevelopmentEnvironment.png)

*Screenshot: Verifying the Development environment was created.*

## Step 3 - Create the Test and Production Environments

Repeat Step 2 twice more to create environments for Test and Production.

Use values similar to the following:

| Environment | Suggested Name | Suggested Description |
| --- | --- | --- |
| Test | `pp-test` | `Power Platform Test deployment gate` |
| Production | `pp-prod` | `Power Platform Production deployment gate` |

1. Select `New environment` and create the Test environment.

![Create Test environment](./Media/Lesson%202/Step%203/CreateTestEnvironment.png)

*Screenshot: Creating the Test environment.*

2. Select `New environment` again and create the Production environment.

![Create Production environment](./Media/Lesson%202/Step%203/CreateProductionEnvironment.png)

*Screenshot: Creating the Production environment.*

3. Verify all three environments appear in the Environments list.

![Verify all environments created](./Media/Lesson%202/Step%203/VerifyAllEnvironmentsCreated.png)

*Screenshot: Verifying Development, Test, and Production environments are listed.*

## Step 4 - Configure Pre-Deployment Approval Check for Development

1. Open the `pp-dev` environment.

![Open Development environment](./Media/Lesson%202/Step%204/OpenDevelopmentEnvironment.png)

*Screenshot: Opening the Development environment.*

2. Select the `Approvals and checks` tab.

![Open Approvals and checks tab](./Media/Lesson%202/Step%204/OpenApprovalsAndChecksTab.png)

*Screenshot: Opening the Approvals and checks tab.*

3. Select the `+` button.

![Select +](./Media/Lesson%202/Step%204/SelectAddCheck.png)

*Screenshot: Selecting Add check.*

4. Choose the `Approvals` check type.

![Select Approvals check type](./Media/Lesson%202/Step%204/SelectApprovalsCheckType.png)

*Screenshot: Selecting the Approvals check type.*

5. Configure the approval check:

	| Setting | Value |
	| --- | --- |
	| Approvers | Select your workshop approver user(s) or group(s). If selecting one of the built-in groups, ensure you select the one corresponding to the Azure DevOps project you're working in |
	| Instructions | Optional guidance such as `Approve deployment to Development` |
	| Allow approvers to approve their own runs (under `Advanced`) | Set based on your governance preference |
	| Timeout (under `Control options`) | Use an appropriate timeout (for workshop, default is fine) |

![Configure Development approval check](./Media/Lesson%202/Step%204/ConfigureDevelopmentApprovalCheck.png)

*Screenshot: Configuring the Development approval check.*

6. Select `Create`.

![Create Development approval check](./Media/Lesson%202/Step%204/CreateDevelopmentApprovalCheck.png)

*Screenshot: Creating the Development approval check.*

7. Verify the Approvals check appears in the list for the environment.

![Verify Development approval check](./Media/Lesson%202/Step%204/VerifyDevelopmentApprovalCheck.png)

*Screenshot: Verifying Development approval check is active.*

## Step 5 - Configure Pre-Deployment Approval Checks for Test and Production

Repeat Step 4 for both `pp-test` and `pp-prod`.

For most workshop scenarios:

- Test can use the same approvers as Development.
- Production should include a stricter approver group where possible.

1. Open the `pp-test` environment and add an `Approvals` check.

![Configure Test approval check](./Media/Lesson%202/Step%205/ConfigureTestApprovalCheck.png)

*Screenshot: Configuring approval check for Test.*

2. Open the `pp-prod` environment and add an `Approvals` check.

![Configure Production approval check](./Media/Lesson%202/Step%205/ConfigureProductionApprovalCheck.png)

*Screenshot: Configuring approval check for Production.*

3. Verify all three environments now show an approval check.

![Verify all approval checks](./Media/Lesson%202/Step%205/VerifyAllApprovalChecks.png)

*Screenshot: Verifying approval checks exist for Development, Test, and Production.*

> **Important**
> A deployment stage that targets an environment will pause and wait for approval until one of the configured approvers approves the check.

## Step 6 - Grant Pipeline Permissions to Use Each Environment

> **Important**
> You will not be able to complete this steup before creating your pipelines. So omit it for now and complete this step after creating each of the three pipelines in labs 1, 2 and 3.

By default, environment usage can be restricted. In this step you explicitly grant your pipeline permission to target each environment.

1. Open the `pp-dev` environment.

![Open Development environment permissions](./Media/Lesson%202/Step%206/OpenDevelopmentEnvironmentPermissions.png)

*Screenshot: Opening Development environment to manage permissions.*

2. Select the `Security` button under the elipses (...) button (label may vary by Azure DevOps UI version).

![Open Pipeline permissions](./Media/Lesson%202/Step%206/OpenPipelinePermissions.png)

*Screenshot: Opening pipeline permissions for the environment.*

3. Grant access using one of the following approaches:

	| Option | When to use |
	| --- | --- |
	| `Open access` (all pipelines) | Best for workshop simplicity and reduced setup friction. |
	| Restrict access to selected pipelines | Best for controlled projects and production governance. |

![Configure Development pipeline permissions](./Media/Lesson%202/Step%206/ConfigureDevelopmentPipelinePermissions.png)

*Screenshot: Configuring pipeline permissions for Development environment.*

4. If using restricted access, select `+` and add your deployment pipeline definition.

![Add pipeline permission entry](./Media/Lesson%202/Step%206/AddPipelinePermissionEntry.png)

*Screenshot: Adding a specific pipeline permission entry.*

5. Save your permission changes.

![Save environment permissions](./Media/Lesson%202/Step%206/SaveEnvironmentPermissions.png)

*Screenshot: Saving environment permission changes.*

6. Repeat these permission steps for `pp-test` and `pp-prod`.

![Repeat permissions for Test and Production](./Media/Lesson%202/Step%206/RepeatPermissionsForTestAndProduction.png)

*Screenshot: Repeating pipeline permissions configuration for Test and Production.*

## Step 7 - Verify End-to-End Environment Configuration

1. Return to the Environments list and open each environment.
2. Confirm each environment has:

	- The correct name and description.
	- One active `Approvals` check.
	- Pipeline permissions configured as intended. (Recheck after completing step 6 after pipeline creation in labs 1, 2 and 3)

![Verify end-to-end environment configuration](./Media/Lesson%202/Step%207/VerifyEndToEndEnvironmentConfiguration.png)

*Screenshot: Verifying all environment configuration is complete.*

3. Record your final environment names and approver selections for use in later labs.

## Notes for the Workshop

- Keep Azure DevOps Environment names simple and consistent, for example `pp-dev`, `pp-test`, and `pp-prod`.
- In workshop scenarios, using `Open access` for pipeline permissions is acceptable to reduce friction.
- In real projects, prefer restricted pipeline permissions and tighter approver groups for Production.
- If deployments fail with environment authorization errors, verify both environment permissions and pipeline-level authorization prompts.
- If approvals do not appear during deployment, confirm the stage is targeting the correct environment name in the pipeline YAML.

