# GitlabTemplates

Repository containing the Issue and Merge Request templates for usage in other projects

## Getting started

This repository should be added as a subtree in your project so you have its files in its repository and you can edit them as needed. The gitlab templates should be in the .gitlab folder in your project root. To add the subtree, use the following command

`git subtree add --prefix .gitlab git@git.gdservers.com.br:eds-perto-fw/development-tools/gitlabtemplates.git main --squash`


## Updating your subtree

You should keep the subtree in your project updated to make sure your templates are according to the team standards. Also, if your subtree becomes outdated it may fail your pipeline job **verify**. To update the subtree in your project, use the following commmand

`git subtree pull --prefix .gitlab git@git.gdservers.com.br:eds-perto-fw/development-tools/gitlabtemplates.git main --squash`