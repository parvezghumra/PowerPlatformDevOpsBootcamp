# Lesson 4 - Initialise the Azure DevOps Git Repository

## Objective

In this lesson you will create and initialise the Git repository that your Azure DevOps pipelines will use. The repository will start with three root-level folders — `Scripts`, `Templates`, and `Pipelines` — copied from the workshop assets. 

By the end of this exercise you will have:

1. A Git repository in your Azure DevOps project.
2. The `Scripts`, `Templates`, and `Pipelines` folders committed at the root of the repository.
3. All changes pushed to the `main` branch.

Screenshots in this lesson are based on current Azure DevOps portal imagery. Your organisation branding and minor navigation labels may differ slightly.

> **Important**
> This lesson assumes you have Git installed on your local machine. If you do not have Git installed, download it from [https://git-scm.com](https://git-scm.com) before you start.

## What You Are Building

The pipelines in this workshop read scripts, templates, and solution artefacts directly from the Git repository. The initial repository structure provides the scripts and YAML templates the pipelines need from the first run. Additional folders — `Solutions` and `Settings` — will be created and populated automatically by the Commit Solution pipeline over time and do not need to be created manually.

The repository will grow to the following structure as you use the pipelines:

```
Pipelines/
		ci-build.yml
		commit-solution-changes.yml
		deploy-solution.yml
Scripts/
		IsSolutionInstalled.ps1
		ManageProcessState.ps1
		SyncSolutionVersion.ps1
		TokeniseDeploymentSettingsFile.ps1
		TransformDeploymentSettingsFile.ps1
Templates/
		commit-solution-template.yml
		deploy-solution-template.yml
Settings/                           ← Created by the Commit Solution pipeline
		<SolutionName>.json
Solutions/                          ← Created by the Commit Solution pipeline
		<SolutionName>/
```

## Before You Start

You need the following:

| Requirement | Why it is needed |
| --- | --- |
| An Azure DevOps organisation and project | The repository is created inside a project. |
| Project Administrator or Contributor role in the project | Required to create and push to a repository. |
| Git installed on your local machine | Required to clone the repository and commit files. |
| A local copy of the workshop assets | The `Scripts`, `Templates`, and `Pipelines` folders to copy from. |

---

## Step 1 - Create the Azure DevOps Repository

1. Open your Azure DevOps project.

![Open Azure DevOps project](./Media/Lesson%204/Step%201/OpenAzureDevOpsProject.png)

*Screenshot: Opening the Azure DevOps project.*

2. Select `Repos` from the left navigation.

![Select Repos](./Media/Lesson%204/Step%201/SelectRepos.png)

*Screenshot: Selecting Repos from the left navigation.*

3. Select the repository drop-down at the top of the page and then select `New repository`.

![Select New Repository](./Media/Lesson%204/Step%201/SelectNewRepository.png)

*Screenshot: Selecting New repository from the repository drop-down.*

4. Complete the repository creation form:

	 | Setting | Value |
	 | --- | --- |
	 | Repository type | `Git` |
	 | Repository name | A meaningful name for your project, such as `PowerPlatformALM` |
	 | Add a README | Leave unticked — the repository should start completely empty |
	 | Add a .gitignore | Leave as `None` |

	 > **Important**
	 > Do not tick `Add a README` or select a `.gitignore`. The repository must be completely empty so that the initial push from your local machine does not encounter a conflict.

![Complete repository creation form](./Media/Lesson%204/Step%201/CompleteRepositoryCreationForm.png)

*Screenshot: Completing the repository creation form.*

5. Select `Create`.

![Create the repository](./Media/Lesson%204/Step%201/CreateRepository.png)

*Screenshot: Creating the repository.*

6. The empty repository page is displayed. Leave this page open — you will need the clone URL in the next step.

![Empty repository page](./Media/Lesson%204/Step%201/EmptyRepositoryPage.png)

*Screenshot: The empty repository page.*

---

## Step 2 - Clone the Repository Locally

1. On the empty repository page, select `Clone` in the top-right corner.

![Select Clone](./Media/Lesson%204/Step%202/SelectClone.png)

*Screenshot: Selecting Clone.*

2. Copy the HTTPS clone URL displayed in the panel.

![Copy Clone URL](./Media/Lesson%204/Step%202/CopyCloneURL.png)

*Screenshot: Copying the HTTPS clone URL.*

3. Open a terminal on your local machine and navigate to the folder where you want to clone the repository. Then run:

	 ```bash
	 git clone <paste-the-url-you-copied-here>
	 ```

	 For example:

	 ```bash
	 git clone https://dev.azure.com/<your-organisation>/<your-project>/_git/PowerPlatformALM
	 ```

![Clone the repository](./Media/Lesson%204/Step%202/CloneRepository.png)

*Screenshot: Running the git clone command.*

4. When prompted, sign in with your Azure DevOps credentials. Git Credential Manager will handle authentication automatically if it is installed.

![Authenticate during clone](./Media/Lesson%204/Step%202/AuthenticateDuringClone.png)

*Screenshot: Authenticating during the clone.*

5. Navigate into the newly cloned folder:

	 ```bash
	 cd PowerPlatformALM
	 ```

![Navigate into the cloned folder](./Media/Lesson%204/Step%202/NavigateIntoClonedFolder.png)

*Screenshot: Navigating into the cloned repository folder.*

---

## Step 3 - Copy the Scripts, Templates, and Pipelines Folders

1. Open File Explorer (or your preferred file manager) and navigate to the location of your local copy of the workshop assets.

2. Copy the following three folders from the workshop `Assets` directory into the root of your newly cloned repository folder:

	 | Source folder (in workshop assets) | Destination (root of your new repository) |
	 | --- | --- |
	 | `Assets\Scripts` | `<repository root>\Scripts` |
	 | `Assets\Templates` | `<repository root>\Templates` |
	 | `Assets\Pipelines` | `<repository root>\Pipelines` |

	 The result should be:

	 ```
	 <repository root>\
			 Pipelines\
					 ci-build.yml
					 commit-solution-changes.yml
					 deploy-solution.yml
			 Scripts\
					 IsSolutionInstalled.ps1
					 ManageProcessState.ps1
					 SyncSolutionVersion.ps1
					 TokeniseDeploymentSettingsFile.ps1
					 TransformDeploymentSettingsFile.ps1
			 Templates\
					 commit-solution-template.yml
					 deploy-solution-template.yml
	 ```

![Copy folders into the repository](./Media/Lesson%204/Step%203/CopyFoldersIntoRepository.png)

*Screenshot: The three folders copied into the repository root.*

---

## Step 4 - Commit and Push to the Repository

1. In your terminal, from the root of the cloned repository, stage all the new files:

	 ```bash
	 git add --all
	 ```

2. Commit the staged files with a meaningful message:

	 ```bash
	 git commit -m "Initial repository setup - add Scripts, Templates and Pipelines"
	 ```

3. Push the commit to the `main` branch:

	 ```bash
	 git push origin main
	 ```

	 > **Note**
	 > If your default branch is named `master` rather than `main`, substitute `master` in the command above. You can check the branch name in the Azure DevOps Repos page.

![Commit and push to main](./Media/Lesson%204/Step%205/CommitAndPushToMain.png)

*Screenshot: Committing and pushing the initial files to the main branch.*

---

## Step 5 - Verify the Repository Contents in Azure DevOps

1. Return to your Azure DevOps project and open `Repos`.

![Open Repos to verify](./Media/Lesson%204/Step%206/OpenReposToVerify.png)

*Screenshot: Opening Repos to verify the push.*

2. Confirm the repository now shows the three root-level folders.

![Verify three root folders](./Media/Lesson%204/Step%206/VerifyThreeRootFolders.png)

*Screenshot: Verifying the Scripts, Templates, and Pipelines folders at the repository root.*

3. Open the `Scripts` folder and confirm all five PowerShell scripts are present.

![Verify Scripts folder contents](./Media/Lesson%204/Step%206/VerifyScriptsFolderContents.png)

*Screenshot: Verifying the Scripts folder contains all five PowerShell scripts.*

4. Open the `Templates` folder and confirm both YAML template files are present.

![Verify Templates folder contents](./Media/Lesson%204/Step%206/VerifyTemplatesFolderContents.png)

*Screenshot: Verifying the Templates folder contains both YAML template files.*

5. Open the `Pipelines` folder and confirm all three pipeline YAML files are present.

![Verify Pipelines folder contents](./Media/Lesson%204/Step%206/VerifyPipelinesFolderContents.png)

*Screenshot: Verifying the Pipelines folder contains all three pipeline YAML files.*

---

## Notes for the Workshop

- The `Solutions` and `Settings` folders are intentionally absent at this stage. The Commit Solution pipeline creates them automatically the first time it runs successfully for a given solution.
- The relative path `../Templates/commit-solution-template.yml` used inside the pipeline YAML files works correctly because `Pipelines` and `Templates` are sibling folders at the repository root. Do not move or rename these folders.
- If you need to rename the repository after creation, the clone URL will change. Any local clone will need its remote URL updated using `git remote set-url origin <new-url>`.
- If your organisation enforces branch policies on `main` that prevent direct pushes, you may need to push to a feature branch and raise a pull request to complete the initial setup. Consult your Azure DevOps administrator if the push is rejected.
- The solution name `AccountManager` in `ci-build.yml` is a placeholder from the workshop sample. Update it to match your actual solution's unique name before running the CI build pipeline for the first time. This is covered in the CI build lab.

