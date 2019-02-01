# conda-builder-linux

Docker image for building linux-64 conda packages. 

Includes Miniconda 3 and conda-build. 
Based upon CentOS 7. 

It is necessary to use buildkit to propagate the secret to get to the private conda repository:

First create a file called `conda_download_key.txt` with the credentials to the OmegaCEN conda registry. E.g. `mylogin:mypassword` without trailing line break.

Then
````
set DOCKER_BUILDKIT=1
docker build --secret id=conda_download_key,src="%CD%/conda_download_key.txt" -t omegacen/conda-builder-fat .
````
