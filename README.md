# Orchestra C++ SDK Docker and Pcvipr Recon in Ubuntu 18.04 (Bionic)
## Additional Requirements
1) Orchestra-sdk-1.8-1.x86_64.tgz file (login required, from https://collaborate.mr.gehealthcare.com/)
You'll have to add the orchestra-sdk-1.8-1.x86_64.tgz file (login required, from https://collaborate.mr.gehealthcare.com/) 
to the same folder as the Dockerfile

2) vds gradient files for pcvipr as tar file (psd_gradients.tar.gz)

3) ge_data_tools, mri_recon, and pcvipr_wrapper as tar files.

For developing within the docker environment I recommend using vscode with the docker remote connection addons. Otherwise, build as you would any other docker image.

In the docker image you will need to change username to the *HOST* username to avoid ownership issues.
