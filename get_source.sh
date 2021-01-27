#!/bin/bash

# Ask for github username and password
echo "Input github Credentials:"
read -p 'Username: ' GIT_USER
read -sp 'Password: ' GIT_PASS

#GE tools
git clone https://$GIT_USER:$GIT_PASS@github.com/uwmri/ge_data_tools.git
tar -cvzf ge_data_tools.tgz ge_data_tools && rm -rf ge_data_tools

#MRI Recon
git clone https://$GIT_USER:$GIT_PASS@github.com/uwmri/mri_recon.git
tar -cvzf mri_recon.tgz mri_recon && rm -rf mri_recon

#Wrapper
git clone https://$GIT_USER:$GIT_PASS@github.com/uwmri/pcvipr_wrapper.git
tar -cvzf pcvipr_wrapper.tgz pcvipr_wrapper && rm -rf pcvipr_wrapper

# Kevin's Gradient Files
wget https://www.medphysics.wisc.edu/~kmjohnso/PsdGradFiles.tar 