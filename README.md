# Power Platform DevOps Bootcamp

Welcome to the Power Platform DevOps Bootcamp hosted by [Power Community](https://www.powercommunity.com/). In this repository you will find all the learning materials, and instructions necessary for the bootcamp.

## Your Instructors

The bootcamp is led by [Wael Hamze](https://www.linkedin.com/in/waelhamze/) and [Parvez Ghumra](https://www.linkedin.com/in/parvezghumra). It is intended to be an interactive learning experience, so feel free to ask questions and engage during the day. We hope you find it helpful and that it gives you a good starting point for learning Power Platform DevOps principles. If you have any follow-up questions after the bootcamp, don't hesitate to reach out to us on LinkedIn.

## Minimum Requirements

In order to get the most value out of the bootcamp, we recommend that you have the following as a minimum:
1. Basic experience of customising Power Platform including Dataverse, Model Driven Apps and Power Automate using the [Power Apps Maker Portal](https://make.powerapps.com)
2. A laptop with power supply and any necessary accessories with:
    
    a. [VSCode](https://code.visualstudio.com/download)

    b. [Git](https://git-scm.com/install/windows)

    c. [Power Platform CLI](https://aka.ms/pac)

    d. [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell?view=powershell-7.6)

3. Three [Power Platform Developer environments](https://learn.microsoft.com/en-us/power-platform/developer/plan) with Dataverse enabled and [admin level access in these environments](https://admin.powerplatform.microsoft.com)
4. [An Azure App Registration with Client ID and Secret registered as an S2S App](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/walkthrough-register-app-azure-active-directory#confidential-client-app-registration) in each of 3 environments with the System Administrator Security Role
5. An [Azure DevOps organization](https://dev.azure.com/) with either:
    a. Full organization admin rights; OR
    b. A [project](https://learn.microsoft.com/en-us/azure/devops/organizations/projects/create-project?view=azure-devops&tabs=browser) with admin rights in it and the Power Platform Build Tools extension for Azure DevOps pre-installed
6. A working [Microsoft-hosted agent](https://aka.ms/azpipelines-parallelism-request) in Azure DevOps to process pipelines
7. Curiosity to learning DevOps for Power Platform 

## Background

You are a DevOps Engineer at Zava Construction supporting a Power Platform implementation project where a team of 3 low-code/no-code developers are building a solution for internal use. They share the same development environment and require quality assurance to be conducted in a dedicated test environment before the solution is allowed to be deployed to production
![Source Control Centric DevOps for Power Platform](https://github.com/parvezghumra/PowerPlatformDevOpsBootcamp/blob/main/Media/SourceControlCentricALMForPowerPlatform.png)

## The Challenge

Implement a source control centric development, build and deployment process using the capabilities available within Azure DevOps. The labs in this repository will guide you through the setup and at the end of the bootcamp a working solution will be shared with you.

