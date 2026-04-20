# Lesson 0 - Create an Azure App Registration for Dataverse and Power Platform

## Objective

In this lesson you will create a Microsoft Entra app registration in the Azure portal that can be used by Power Platform ALM tooling, Azure DevOps pipelines, Dataverse, and Dynamics 365 CE environments.

By the end of this exercise you will have:

1. A single-tenant confidential client app registration.
2. A client secret for workshop use.
3. A Dataverse application user in your target environment.
4. The System Administrator security role assigned to that application user.

Screenshots in this lesson are based on current Microsoft Learn portal imagery. Your tenant branding and minor navigation labels may differ slightly.

> Important
> The app registration itself does not automatically have access to Dataverse. The effective privileges come from the Dataverse application user that you create in each environment and the security roles you assign to it.

## What You Are Building

For this workshop you are creating a server-to-server (S2S) identity for automation. This is the identity your pipelines and tools will use instead of a named interactive user.

For the workshop scenario, one app registration can be reused across multiple Dataverse environments in the same tenant. You must still create an application user in each environment and assign the required security role in each one.

## Before You Start

You need the following:

| Requirement | Why it is needed |
| --- | --- |
| Access to the correct Microsoft Entra tenant | The app registration must be created in the same tenant as the Dataverse environments you want to access. |
| Permission to create app registrations | A dependable minimum is Application Developer. Cloud Application Administrator, Application Administrator, or Global Administrator also work. |
| Permission to create application users in the target Power Platform environment | You need this to bind the app registration to Dataverse. |
| A target Dataverse environment | You will create the application user in this environment. |
| An account that can assign the System Administrator security role in the environment | This gives the app enough privileges for the workshop labs. |

## Values to Record

Capture these values as you go. You will need them again in later labs.

| Value | Example | Where you get it |
| --- | --- | --- |
| App Registration Name | `pp-devops-workshop-s2s` | Entered by you |
| Directory (tenant) ID | `aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee` | App registration Overview |
| Application (client) ID | `11111111-2222-3333-4444-555555555555` | App registration Overview |
| Client Secret Value | `xxxxxxxxxxxxxxxx` | Certificates & secrets page |
| Client Secret Expiry Date | `2027-04-09` | Certificates & secrets page |
| Dataverse Environment URL | `https://org12345.crm11.dynamics.com` | Power Platform admin center or maker portal |

## Step 1 - Create the App Registration in the Azure Portal

1. Open the Azure portal at [https://portal.azure.com](https://portal.azure.com) in a private browser session.

![Open the Azure portal](./Media/Lesson%200/Step%201/OpenAzurePortal.png)

*Screenshot: Opening the Azure portal.*

2. Sign in with an account in the same tenant as your Power Platform environments.

![Sign In](./Media/Lesson%200/Step%201/SignIn.png)

*Screenshot: Signing in.*

![Enter password](./Media/Lesson%200/Step%201/EnterPassword.png)

*Screenshot: Entering password.*

![Proceed through MFA](./Media/Lesson%200/Step%201/ProceedThroughMFA.png)

*Screenshot: Proceeding through MFA.*

![Choose whether to remain signed in](./Media/Lesson%200/Step%201/ChooseWhetherToRemainSignedIn.png)

*Screenshot: Choosing whether to remain signed in.*

3. In the portal search bar, search for `Microsoft Entra ID` and open it.

![Search for and open Microsoft Entra ID](./Media/Lesson%200/Step%201/SearchForAndOpenMicrosoftEntraID.png)

*Screenshot: Searching for and opening Microsoft Entra ID.*

4. In the left navigation, select `App registrations` under the `Manage` section.

![Select App Registrations](./Media/Lesson%200/Step%201/SelectAppRegistrations.png)

*Screenshot: Select App Registrations.*

5. Select `+ New registration`.

![Select New registration](./Media/Lesson%200/Step%201/SelectNewRegistration.png)

*Screenshot: Select + New registration.*

6. Complete the registration form with the following values:

	| Setting | Value for the workshop |
	| --- | --- |
	| Name | Use a meaningful name such as `pp-devops-workshop-s2s` |
	| Supported account types | `Single tenant only - <Your Tenant Name>` |
	| Redirect URI | Leave blank for this workshop scenario |

![Create App Registration](./Media/Lesson%200/Step%201/CreateAppRegistration.png)

*Screenshot: Create App Registration.*

7. Select `Register`.
8. On the `Overview` page, copy and save these two values:
	- `Application (client) ID`
	- `Directory (tenant) ID`

![Copy App Registration Details](./Media/Lesson%200/Step%201/CopyAppRegistrationDetails.png)

*Screenshot: Copy App Registration Details.*

### Notes for the Workshop

- Use `single tenant` unless you have a specific reason to support multiple tenants.
- Do not configure a redirect URI for this confidential client workshop scenario.
- Do not enable public client flows for this lesson.
- Do not add Microsoft Graph or other high-privilege API permissions just to make Dataverse automation work.

## Step 2 - Create a Client Secret

1. In your app registration, go to `Certificates & secrets`.
![Client secret in Certificates and secrets](./Media/Lesson%200/Step%202/NavigateToCertificatesAndSecrets.png)

*Screenshot: Navigate to Certificates & Secrets area in App Registration*

2. Select the `Client secrets` tab.
![Client secrets tab](./Media/Lesson%200/Step%202/ClientSecretsTab.png)

*Screenshot: Select Client Secrets tab*

3. Select `+ New client secret`.
![Client secrets tab](./Media/Lesson%200/Step%202/Click+NewClientSecret.png)

*Screenshot: Click +New Client Secret*

4. Enter a description such as `Power Platform DevOps Bootcamp`.

5. Choose an expiry that matches your organization policy.
	- Microsoft recommends short-lived secrets and regular rotation.
	- For a workshop or lab, choose a duration that will not expire before you complete the exercises.

6. Select `Add`.

![Enter Client Secret Description and Expiry](./Media/Lesson%200/Step%202/EnterClientSecretDescriptionAndExpiry.png)

*Screenshot: Enter Client Secret Description and Expiry*

7. Immediately copy the `Value` column for the new secret and store it safely.

> Important
> Copy the secret `Value`, not the `Secret ID`. You will not be able to see the secret value again after you leave or refresh the page.

![Copy secret value](./Media/Lesson%200/Step%202/CopySecretValue.png)

*Screenshot: Copy secret value*

## Step 3 - Decide Whether You Need API Permissions

For this workshop scenario, the answer is normally `no`.

For a confidential client used with Dataverse server-to-server authentication:

- The critical configuration is the Dataverse application user.
- The critical authorization is the Dataverse security role.
- You do not need to add delegated `user_impersonation` permissions for normal pipeline-based Dataverse access.

That delegated permission is commonly used in interactive user sign-in scenarios, not this workshop's S2S automation pattern.

![API Permissions Not Required](./Media/Lesson%200/Step%203/APIPermissionsNotRequired.png)

*Screenshot: API Permissions Not Required*

## Step 4 - Create the Dataverse Application User

Now bind the app registration to the Dataverse environment.

1. Open the Power Platform admin center at [https://admin.powerplatform.microsoft.com](https://admin.powerplatform.microsoft.com).
![Navigate to Power Platform Admin Centre](./Media/Lesson%200/Step%204/NavigateToPPAC.png)

*Screenshot: Sign in to Power Platform Admin Centre*

2. Sign in with an account that can manage the target environment.
![Login to Power Platform Admin Center](./Media/Lesson%200/Step%204/LoginToPPAC.png)

*Screenshot: Sign in to Power Platform Admin Centre*

![Enter password to sign in to Power Platform Admin Center](./Media/Lesson%200/Step%204/EnterPasswordToLoginToPPAC.png)

*Screenshot: Enter password to sign in to Power Platform Admin Centre*

![Choose whether to remain signed in to Power Platform Admin Center](./Media/Lesson%200/Step%204/ChooseWhetherToRemainSignedInToPPAC.png)

*Screenshot: Choose whether to remain signed in to Power Platform Admin Centre*

3. Select `Manage`.
4. Select `Environments`.
5. Open the environment you want this app to access.

![Open desired environment in Power Platform Admin Center](./Media/Lesson%200/Step%204/OpenDesiredEnvironmentInPPAC.png)

*Screenshot: Open desired environment in Power Platform Admin Centre*

6. Select `See all` under `S2S Apps` in the environment landing page
![Navigate to S2S Apps from the environment landing page](./Media/Lesson%200/Step%204/NavigateToS2SAppsInPPAC.png)

*Screenshot: Navigate to S2S Apps in the desired environment*

7. Select `+ New app user`.
![Select + New App User](./Media/Lesson%200/Step%204/ClickNewAppUser.png)

*Screenshot: Select +New App User*

8. Select `+ Add an app`.

![Select Add an App](./Media/Lesson%200/Step%204/SelectAddAnApp.png)

*Screenshot: Select Add an App*

9. Search for the app registration you created earlier.
10. Select the app and then select `Add`.

![Search for and select the App Registration](./Media/Lesson%200/Step%204/SearchForAndSelectAppRegistration.png)

*Screenshot: Search for and Select App Registration*

11. Set the `Business Unit`.
	 - In most workshop environments, the root business unit is fine.

![Select Business Unit for S2S App](./Media/Lesson%200/Step%204/SelectBusinessUnitForS2SApp.png)

*Screenshot: Search for and Select App Registration*

12. Assign the `System Administrator` security role.

![Find and Select System Administrator Role for Assignment](./Media/Lesson%200/Step%204/FindAndSelectSystemAdministratorRoleForAssignment.png)

*Screenshot: Search for and Select App Registration*

13. Select `Create`.

## Step 5 - Repeat for Every Environment Needed by the Workshop

This workshop uses three environments, namely Development, Test, and Production. So repeat only the step for adding the S2S App User to each environment.

You usually do not need three separate app registrations if:

- all environments are in the same tenant
- the same automation identity is acceptable for all three environments

However, you do need a separate application user in each environment.

## Step 6 - Verify the Configuration

Confirm the following before moving on:

| Check | Expected result |
| --- | --- |
| App registration exists in Microsoft Entra ID | Yes |
| Client secret was copied and stored | Yes |
| Tenant ID and Client ID were recorded | Yes |
| Application user exists in the Dataverse environment | Yes |
| Application user has `System Administrator` | Yes |

## Common Mistakes

### Mistake 1 - Creating the app registration in the wrong tenant

If the app is not in the same tenant as the Dataverse environment, you will not be able to bind it correctly as an application user.

### Mistake 2 - Copying the Secret ID instead of the Secret Value

Only the `Value` works as the client secret.

### Mistake 3 - Forgetting to create the Dataverse application user

This is the most common issue. The Azure app registration alone is not enough.

### Mistake 4 - Assigning too little privilege in Dataverse

For this workshop, use `System Administrator` to avoid permission-related noise during the labs.

### Mistake 5 - Adding unnecessary API permissions

For the workshop S2S pattern, extra delegated permissions do not replace the Dataverse application user and are usually not the missing step.

## Security Guidance

For the workshop, a client secret is acceptable. For production, prefer a certificate or managed identity where supported.

Minimum good practice:

1. Keep the secret in Azure Key Vault, Azure DevOps secret variables, or another approved secret store.
2. Do not paste the secret into source control.
3. Rotate the secret before it expires.
4. Use separate application users and role assignments per environment.
5. Review whether `System Administrator` is appropriate outside a workshop context.

## Summary

You now have:

1. A Microsoft Entra app registration.
2. A client ID, tenant ID, and client secret.
3. A Dataverse application user bound to that app registration in each environment.
4. System Administrator rights in each environment for workshop automation.

This is the identity you will use in later labs for Power Platform ALM and Azure DevOps pipeline authentication.

## Reference Links

- [Register an application in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app)
- [Add and manage application credentials in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity-platform/how-to-add-credentials?tabs=client-secret)
- [Register an app with Microsoft Entra ID for Dataverse](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/walkthrough-register-app-azure-active-directory#confidential-client-app-registration)
- [Manage application users in the Power Platform admin center](https://learn.microsoft.com/en-us/power-platform/admin/manage-application-users)
