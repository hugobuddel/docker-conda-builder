# syntax=docker/dockerfile:experimental
FROM centos:7

LABEL maintainer="teake.nutma@gmail.com"
LABEL description="Builds linux-64 conda packages. CentOS 7 + miniconda + conda-build."

# Set a UTF-8 locale. Useful for running Python 3 programs.
ENV LANG=en_US.utf-8 \
    LC_ALL=en_US.utf-8

# Fetch updates and install dependencies.
# bzip2 is required for installing conda.
# git and openssh-clients are required for cloning git repositories in recipes.
# patch is required for applying patches in recipes.
RUN yum -y update && \
    yum -y install bzip2 git openssh-clients patch && \
    yum clean all && \
    rm -rf /var/cache/yum
# Install the latest Miniconda with Python 3 and update everything.
RUN curl https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    /opt/conda/bin/conda config --set show_channel_urls True && \
    /opt/conda/bin/conda config --set path_conflict prevent && \
    /opt/conda/bin/conda update --yes --all && \
    /opt/conda/bin/conda install --yes conda-build conda-verify && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh
# Fetch several useful packages
RUN --mount=type=secret,id=conda_download_key /opt/conda/bin/conda \
    install \
    -c https://$(cat /run/secrets/conda_download_key)@conda.astro-wise.org \
    numpy matplotlib python-dateutil astropy \
    cx_oracle instantclient \
    bpz galfit galphot htm ldac ltl mdia \
    ccfits cdsclient cosmicfits eclipse \
    photz psfex scamp sextractor \
    shapelets stiff stsci.distutils swarp vodia wcslib \
    pytest pytest-cov mock psycopg2 \
    common

# Add a shell script that activates conda ...
COPY entrypoint.sh /opt/docker/bin/entrypoint.sh
# ... and make it the Docker entrypoint so that conda is available when we run a container.
ENTRYPOINT [ "/bin/bash", "/opt/docker/bin/entrypoint.sh" ]
# Provide a default command (`bash`), which will start if the user doesn't specify one.
CMD [ "/bin/bash" ]
