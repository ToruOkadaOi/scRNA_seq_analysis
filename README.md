# scRNA_seq_analysis

A full single-cell transcriptomics workflow packaged in a Docker container — built and used during my internship in immunology

Contents include complete Dockerfile, scripts to start container after pulling the images and analysis notebooks for 1. Seurat 2. ScRepertoire 3. Scanpy

List of packages can be checked through pkg_check.R file

Container supports Rstudio and jupyter(with python and R baked in)

A sif file also included for apptainer

##  Docker Image

You can pull the prebuilt image directly from Docker Hub:

[![Docker Hub](https://img.shields.io/badge/DockerHub-scrna_complete-blue?logo=docker)](https://hub.docker.com/r/toluene123/scrna_complete)

### Pull the Image

```bash
# Pull the image (works on most systems)
docker pull toluene123/scrna_complete

# If you're on a specific platform like M series Mac or ARM server, specify the architecture
docker pull --platform linux/amd64 toluene123/scrna_complete
