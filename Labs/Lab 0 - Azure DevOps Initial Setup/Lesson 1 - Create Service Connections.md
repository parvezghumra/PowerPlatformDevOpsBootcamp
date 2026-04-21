# Lesson 1 - Create Service Connections in Azure DevOps

## Objective

In this lesson you will create Power Platform service connections in your Azure DevOps project. These service connections allow your pipelines to authenticate to Dataverse and Power Platform environments without embedding credentials directly in pipeline code.

By the end of this exercise you will have:

1. The Power Platform Build Tools extension installed in your Azure DevOps organisation.
2. One service connection per environment, using the `Power Platform` connection type.
3. Each service connection authenticated using the Client Secret from the app registration you created in Lesson 0.

Screenshots in this lesson are based on current Azure DevOps portal imagery. Your organisation branding and minor navigation labels may differ slightly.

> **Important**
> You will need the `Application (client) ID`, `Directory (tenant) ID`, `Client Secret Value`, and each environment's `Dataverse Environment URL` that you recorded in Lesson 0. Have those values ready before you start.

## What You Are Building

You are creating one service connection for each Power Platform environment used in this workshop (Development, Test, and Production). Each service connection uses the `Power Platform` connection type provided by the Power Platform Build Tools extension, and authenticates using the app registration client secret — a server-to-server (S2S) credential that does not require interactive sign-in.

Later labs will reference these service connections by name from pipeline YAML, so the names you choose here must be consistent with the variable values you configure in Lab 0 Lesson 3.

## Before You Start

You need the following:

| Requirement | Why it is needed |
| --- | --- |
| An Azure DevOps organisation and project | Service connections live inside a project. |
| Project Administrator or Build Administrator role in the project | Required to create and manage service connections. |
| The `Application (client) ID` from Lesson 0 | Used to identify the app registration when authenticating. |
| The `Directory (tenant) ID` from Lesson 0 | Used to locate the correct Microsoft Entra tenant. |
| The `Client Secret Value` from Lesson 0 | The credential used to authenticate as the app registration. |
| The Dataverse Environment URL for each environment | Identifies which environment each service connection targets. |

## Values to Record

Capture these values as you create each service connection. You will reference the service connection names in Lesson 3 when configuring variable groups.

| Value | Example | Where you get it |
| --- | --- | --- |
| Development service connection name | `pp-devops-dev` | Entered by you |
| Test service connection name | `pp-devops-test` | Entered by you |
| Production service connection name | `pp-devops-prod` | Entered by you |

## Step 1 - Install the Power Platform Build Tools Extension

> **Note**
> If your organisation already has the Power Platform Build Tools extension installed, skip to Step 2.

1. Open your Azure DevOps organisation in a browser, for example `https://dev.azure.com/<your-organisation>`.

![Open Azure DevOps organisation](./Media/Lesson%201/Step%201/OpenAzureDevOpsOrganisation.png)

*Screenshot: Opening the Azure DevOps organisation.*

2. Select the shopping bag icon in the top-right corner to open the Visual Studio Marketplace, or navigate directly to [https://marketplace.visualstudio.com/azuredevops](https://marketplace.visualstudio.com/azuredevops).

![Open the Visual Studio Marketplace](./Media/Lesson%201/Step%201/OpenVisualStudioMarketplace.png)

*Screenshot: Opening the Visual Studio Marketplace.*

3. Search for `Power Platform Build Tools`.

![Search for Power Platform Build Tools](./Media/Lesson%201/Step%201/SearchForPowerPlatformBuildTools.png)

*Screenshot: Searching for Power Platform Build Tools in the Marketplace.*

4. Select the `Power Platform Build Tools` result published by `Microsoft`.

![Select Power Platform Build Tools](./Media/Lesson%201/Step%201/SelectPowerPlatformBuildTools.png)

*Screenshot: Selecting the Power Platform Build Tools extension.*

5. Select `Get it free`.

![Select Get it free](./Media/Lesson%201/Step%201/SelectGetItFree.png)

*Screenshot: Selecting Get it free.*

6. Select your Azure DevOps organisation from the drop-down list.

![Select your Azure DevOps organisation](./Media/Lesson%201/Step%201/SelectOrganisation.png)

*Screenshot: Selecting the target Azure DevOps organisation.*

7. Select `Install`.

![Install the extension](./Media/Lesson%201/Step%201/InstallExtension.png)

*Screenshot: Installing the extension into the organisation.*

8. Once installation is complete, select `Proceed to organisation` to return to Azure DevOps.

![Proceed to organisation](./Media/Lesson%201/Step%201/ProceedToOrganisation.png)

*Screenshot: Returning to the Azure DevOps organisation after installation.*

### Notes for the Workshop

- The extension is installed at the organisation level, so it becomes available to all projects in that organisation immediately.
- You need organisation-level permissions to install extensions. If you do not have them, ask your Azure DevOps organisation administrator to install the extension.

## Step 2 - Navigate to Service Connections

1. In your Azure DevOps project, select `Project settings` in the bottom-left corner.

![Open Project Settings](./Media/Lesson%201/Step%202/OpenProjectSettings.png)

*Screenshot: Opening Project Settings.*

2. Under the `Pipelines` section in the left navigation, select `Service connections`.

![Select Service Connections](./Media/Lesson%201/Step%202/SelectServiceConnections.png)

*Screenshot: Selecting Service Connections under Pipelines.*

## Step 3 - Create the Development Service Connection

1. Select `New service connection`.

![Select New service connection](./Media/Lesson%201/Step%203/SelectNewServiceConnection.png)

*Screenshot: Selecting New service connection.*

2. In the service connection type list, search for or scroll to `Power Platform` and select it.

![Select the Power Platform connection type](./Media/Lesson%201/Step%203/SelectPowerPlatformConnectionType.png)

*Screenshot: Selecting the Power Platform connection type.*

3. Select `Next`.

![Select Next](./Media/Lesson%201/Step%203/SelectNext.png)

*Screenshot: Selecting Next to proceed.*

4. Complete the connection details form with the following values:

	| Setting | Value |
	| --- | --- |
	| Authentication method | `Client secret` |
	| Server URL | The Dataverse Environment URL for your Development environment, e.g. `https://org12345-dev.crm11.dynamics.com` |
	| Tenant ID | The `Directory (tenant) ID` you recorded in Lesson 0 |
	| Application ID | The `Application (client) ID` you recorded in Lesson 0 |
	| Client secret of application | The `Client Secret Value` you recorded in Lesson 0 |
	| Service connection name | A meaningful name such as `pp-devops-dev` |
	| Grant access permission to all pipelines | Tick this box for the workshop |

![Complete the Development service connection form](./Media/Lesson%201/Step%203/CompleteDevelopmentConnectionForm.png)

*Screenshot: Completing the Development service connection form.*

5. Select `Save`.

![Save the service connection](./Media/Lesson%201/Step%203/SaveServiceConnection.png)

*Screenshot: Saving the service connection.*

6. Verify the new service connection appears in the list with a green status indicator.

![Verify the Development service connection](./Media/Lesson%201/Step%203/VerifyDevelopmentServiceConnection.png)

*Screenshot: Verifying the Development service connection was created successfully.*

> **Important**
> Record the exact service connection name you used. Pipeline YAML and variable groups reference service connections by name and the value must match exactly, including capitalisation.

## Step 4 - Create the Test Service Connection

Repeat the steps in Step 3 for your Test environment, using these values:

| Setting | Value |
| --- | --- |
| Authentication method | `Client secret` |
| Server URL | The Dataverse Environment URL for your Test environment, e.g. `https://org12345-test.crm11.dynamics.com` |
| Tenant ID | The `Directory (tenant) ID` you recorded in Lesson 0 |
| Application ID | The `Application (client) ID` you recorded in Lesson 0 |
| Client secret of application | The `Client Secret Value` you recorded in Lesson 0 |
| Service connection name | A meaningful name such as `pp-devops-test` |
| Grant access permission to all pipelines | Tick this box for the workshop |

1. Select `New service connection`, choose `Power Platform`, and select `Next`.

![Select New service connection for Test](./Media/Lesson%201/Step%204/SelectNewServiceConnectionForTest.png)

*Screenshot: Selecting New service connection for the Test environment.*

2. Complete the form with the Test environment values and select `Save`.

![Complete the Test service connection form](./Media/Lesson%201/Step%204/CompleteTestConnectionForm.png)

*Screenshot: Completing the Test service connection form.*

3. Verify the Test service connection appears in the list.

![Verify the Test service connection](./Media/Lesson%201/Step%204/VerifyTestServiceConnection.png)

*Screenshot: Verifying the Test service connection was created successfully.*

## Step 5 - Create the Production Service Connection

Repeat the steps in Step 3 for your Production environment, using these values:

| Setting | Value |
| --- | --- |
| Authentication method | `Client secret` |
| Server URL | The Dataverse Environment URL for your Production environment, e.g. `https://org12345-prod.crm11.dynamics.com` |
| Tenant ID | The `Directory (tenant) ID` you recorded in Lesson 0 |
| Application ID | The `Application (client) ID` you recorded in Lesson 0 |
| Client secret of application | The `Client Secret Value` you recorded in Lesson 0 |
| Service connection name | A meaningful name such as `pp-devops-prod` |
| Grant access permission to all pipelines | Tick this box for the workshop |

1. Select `New service connection`, choose `Power Platform`, and select `Next`.

![Select New service connection for Production](./Media/Lesson%201/Step%205/SelectNewServiceConnectionForProduction.png)

*Screenshot: Selecting New service connection for the Production environment.*

2. Complete the form with the Production environment values and select `Save`.

![Complete the Production service connection form](./Media/Lesson%201/Step%205/CompleteProductionConnectionForm.png)

*Screenshot: Completing the Production service connection form.*

3. Verify the Production service connection appears in the list.

![Verify the Production service connection](./Media/Lesson%201/Step%205/VerifyProductionServiceConnection.png)

*Screenshot: Verifying the Production service connection was created successfully.*

## Step 6 - Verify All Three Service Connections

Once all three service connections are created, your Service Connections list should show entries for Development, Test, and Production, each using the `Power Platform` connection type.

![Verify all service connections](./Media/Lesson%201/Step%206/VerifyAllServiceConnections.png)

*Screenshot: All three Power Platform service connections visible in the list.*

### Notes for the Workshop

- All three service connections use the same app registration credentials. The `Server URL` is the only value that differs between them.
- The `Grant access permission to all pipelines` setting allows any pipeline in this project to use the service connection without requiring individual approvals. This is appropriate for a workshop environment. Review this setting for production use in your own organisation.
- If a service connection shows a warning or error status, select it and use the `Verify` button to test the connection. The most common causes are an incorrect Server URL, an expired client secret, or a missing Dataverse application user in that environment.
- You must have an application user created in each Dataverse environment with the System Administrator security role assigned, as completed in Lesson 0 Step 4 and Step 5, for the service connection to authenticate successfully.

