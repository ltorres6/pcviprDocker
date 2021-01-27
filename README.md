# Orchestra C++ SDK Docker and Pcvipr Recon in Ubuntu 18.04 (Bionic)
## Additional Requirements
* orchestra-sdk-1.10-1.tgz file (login required, from https://collaborate.mr.gehealthcare.com/)
* Access to https://github.com/uwmri (Kevin Johnson)

## Instructions
* Place orchestra-sdk-1.10-1.tgz file in this folder.

* run "./get_source.sh" to pull ge_tools, mri_recon, and pcvipr_wrapper from github and tar them. This script will ask for your github username and password.

* change the username on lines 10 and 111 to the username on the host machine

* Build the image using "docker build ."

For developing within the docker environment I recommend using vscode with the docker remote connection addons. Otherwise, build as you would any other docker image.

In the docker image you will need to change username to the *HOST* username to avoid ownership issues.
