#!/bin/bash

# Activate the `root` conda environment.
. /opt/conda/bin/activate root

# Run whatever the user wants to.
exec "$@"
