# Lesson 0 - Prepare Dataverse Solution in the Development Environment

## Objective

In this lesson you will import a pre-prepared unmanaged Dataverse solution into your Development environment using the Power Apps Maker Portal, and then publish all customisations.

Although you can complete this workshop with your own customisations, a ready-made unmanaged solution package is provided to save time and ensure everyone starts from a known baseline.

By the end of this exercise you will have:

1. Imported the unmanaged `AccountManager` solution into your Development environment.
2. Confirmed the solution import completed successfully.
3. Published all customisations so they are available for export in the next lessons.

Screenshots in this lesson are based on current Power Apps Maker Portal imagery. Your tenant branding, region, and minor navigation labels may differ slightly.

> **Important**
> This lesson must be completed in your **Development** environment only. Do not import this unmanaged solution into your Test or Production environments for this workshop.

## What You Are Building

The Commit Solution pipeline in this lab series exports and unpacks an unmanaged solution from Dataverse, then commits the source-controlled files to your Git repository.

To focus on the DevOps pipeline flow rather than manual solution authoring, this workshop provides a pre-built unmanaged solution package:

`/Assets/Solution/AccountManager_1_0_0_1.zip`

Once imported and published, this solution becomes the source material that your pipeline will export and commit in Lesson 1 and Lesson 2.

## Before You Start

You need the following:

| Requirement | Why it is needed |
| --- | --- |
| Access to Power Apps Maker Portal | Required to import solutions into Dataverse. |
| Maker or System Administrator permissions in the Development environment | Required to import and publish solution customisations. |
| The workshop repository/files available locally | Required to locate the solution package zip file. |
| The Development environment selected in Maker Portal | Ensures the solution is imported into the correct environment. |

## Package Details

Use the following package for this lesson:

| Item | Value |
| --- | --- |
| Package path | `/Assets/Solution/AccountManager_1_0_0_1.zip` |
| Solution type | Unmanaged |
| Intended target | Development environment only |

---

## Step 1 - Open the Power Apps Maker Portal

1. Open a browser and navigate to [https://make.powerapps.com](https://make.powerapps.com).

![Open Power Apps Maker Portal](./Media/Lesson%200/Step%201/OpenPowerAppsMakerPortal.png)

*Screenshot: Opening the Power Apps Maker Portal.*

2. Sign in with your workshop account if prompted.

![Sign in to Maker Portal](./Media/Lesson%200/Step%201/SignInToMakerPortal.png)

*Screenshot: Signing in to the Maker Portal.*

3. In the top-right environment selector, choose your **Development** environment.

![Select Development environment](./Media/Lesson%200/Step%201/SelectDevelopmentEnvironment.png)

*Screenshot: Selecting the Development environment from the environment selector.*

> **Important**
> Verify the environment name carefully before continuing. Importing into the wrong environment will affect later pipeline steps and may require cleanup.

---

## Step 2 - Navigate to Solutions

1. In the left navigation menu, select `Solutions`.

![Open Solutions area](./Media/Lesson%200/Step%202/OpenSolutionsArea.png)

*Screenshot: Opening the Solutions area in Maker Portal.*

2. Confirm you are on the Solutions list page for the Development environment.

![Confirm Solutions list](./Media/Lesson%200/Step%202/ConfirmSolutionsList.png)

*Screenshot: Solutions list in the Development environment.*

---

## Step 3 - Start the Solution Import

1. Select `Import solution` from the command bar.

![Select Import solution](./Media/Lesson%200/Step%203/SelectImportSolution.png)

*Screenshot: Selecting Import solution from the command bar.*

2. In the import panel, select `Browse`.

![Select Browse in import panel](./Media/Lesson%200/Step%203/SelectBrowseInImportPanel.png)

*Screenshot: Selecting Browse to choose a solution package file.*

3. Navigate to your local workshop folder and select:

	`/Assets/Solution/AccountManager_1_0_0_1.zip`

![Choose AccountManager solution zip](./Media/Lesson%200/Step%203/ChooseAccountManagerSolutionZip.png)

*Screenshot: Selecting the AccountManager_1_0_0_1.zip file.*

4. Select `Open` in the file picker.

![Open selected solution zip](./Media/Lesson%200/Step%203/OpenSelectedSolutionZip.png)

*Screenshot: Confirming the selected solution package file.*

---

## Step 4 - Review and Complete the Import

1. Review the solution details shown by the import wizard (solution name, version, and publisher).

![Review solution details](./Media/Lesson%200/Step%204/ReviewSolutionDetails.png)

*Screenshot: Reviewing solution metadata before import.*

2. Select `Next` to continue.

![Select Next in import wizard](./Media/Lesson%200/Step%204/SelectNextInImportWizard.png)

*Screenshot: Proceeding to the next step of the import wizard.*

3. If prompted for connection references or environment variables, keep the default workshop values and continue.

![Review import configuration](./Media/Lesson%200/Step%204/ReviewImportConfiguration.png)

*Screenshot: Reviewing optional import configuration values.*

4. Select `Import`.

![Select Import button](./Media/Lesson%200/Step%204/SelectImportButton.png)

*Screenshot: Starting the solution import.*

5. Wait for the import to complete, then confirm the status shows success.

![Verify import success](./Media/Lesson%200/Step%204/VerifyImportSuccess.png)

*Screenshot: Solution import completed successfully.*

> **Note**
> Import time can vary by environment and tenant performance. If you see a temporary processing message, wait until the final status is shown.

---

## Step 5 - Verify the Solution Is Available

1. Return to the `Solutions` list.

![Return to Solutions list](./Media/Lesson%200/Step%205/ReturnToSolutionsList.png)

*Screenshot: Returning to the Solutions list after import.*

2. Confirm the `AccountManager` solution appears in the list.

![Verify AccountManager solution](./Media/Lesson%200/Step%205/VerifyAccountManagerSolution.png)

*Screenshot: Verifying the AccountManager solution exists in the Development environment.*

3. Open the solution and verify at least one component (for example, a table, app, or cloud flow) is present.

![Verify solution components](./Media/Lesson%200/Step%205/VerifySolutionComponents.png)

*Screenshot: Confirming components are present inside the imported solution.*

---

## Step 6 - Publish All Customisations

1. In Maker Portal, open `Solutions` and select `Publish all customizations` from the command bar.

![Select Publish all customizations](./Media/Lesson%200/Step%206/SelectPublishAllCustomizations.png)

*Screenshot: Selecting Publish all customizations.*

2. Confirm the publish action when prompted.

![Confirm publish all customizations](./Media/Lesson%200/Step%206/ConfirmPublishAllCustomizations.png)

*Screenshot: Confirming the publish operation.*

3. Wait for the publish operation to complete.

![Publish operation complete](./Media/Lesson%200/Step%206/PublishOperationComplete.png)

*Screenshot: Publish all customizations completed successfully.*

---

## Step 7 - Final Validation for the Next Lesson

Before moving to Lesson 1, confirm the following checklist:

1. You imported `AccountManager_1_0_0_1.zip` into the Development environment.
2. The import completed successfully with no blocking errors.
3. The `AccountManager` solution is visible in the Solutions list.
4. `Publish all customizations` has completed.

![Final validation checklist](./Media/Lesson%200/Step%207/FinalValidationChecklist.png)

*Screenshot: Final validation before starting Lesson 1.*

---

## Notes for the Workshop

- This package is intentionally unmanaged so the Commit Solution pipeline can export and unpack source for version control.
- If you import additional personal customisations, they may appear in exports and create extra differences in Git. For a consistent workshop outcome, use only the provided package during this lab.
- If `Publish all customizations` is skipped, some recently imported metadata may not be fully available to downstream export operations.
- If import fails, check that you selected the correct zip file, that your account has the right permissions in the environment, and that the target is the Development environment.

