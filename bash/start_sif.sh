#!/bin/bash

echo 'Insert the directoy(path) to mount'

read d_path

echo 'Specify which port you want to expose for Jupyter'

apptainer shell --bind $d_path:/home /home/aman/docker_master/scrna_complete.sif
