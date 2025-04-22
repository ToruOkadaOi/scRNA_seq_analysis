#rstudio
FROM rocker/rstudio:4.4.2

#no prompts during install
ENV DEBIAN_FRONTEND=noninteractive

#dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev libssl-dev libxml2-dev libgit2-dev pandoc \
    libblas-dev liblapack-dev libopenblas-dev gfortran libfftw3-dev libgsl-dev \
    libnlopt-dev libmpfr-dev libgmp-dev libsqlite3-dev libzstd-dev libbz2-dev \
    liblzma-dev zlib1g-dev libpcre2-dev libboost-all-dev libeigen3-dev \
    libcairo2-dev libpng-dev libjpeg-dev libtiff-dev libmagick++-dev \
    libharfbuzz-dev libfribidi-dev libfreetype6-dev libfontconfig1-dev libx11-dev \
    libxext-dev libxrender-dev libicu-dev libproj-dev libgeos-dev libgdal-dev \
    libnetcdf-dev libreadline-dev libncurses5-dev tcl8.6-dev tk8.6-dev \
    libv8-dev libjson-c-dev ghostscript libpoppler-cpp-dev libpoppler-glib-dev \
    libgraphviz-dev graphviz imagemagick libjpeg-turbo8-dev build-essential \
    pkg-config libudunits2-dev libgeos-dev libprotobuf-dev protobuf-compiler \
    libhdf5-dev python3 python3-pip python3-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/samtools/htslib/releases/download/1.18/htslib-1.18.tar.bz2 && \
    tar -xvf htslib-1.18.tar.bz2 && \
    cd htslib-1.18 && ./configure --enable-libcurl && make -j$(nproc) && make install && \
    cd .. && rm -rf htslib-1.18*

# adding user
RUN useradd -m -u 1001 aman && echo 'aman:123' | chpasswd && usermod -aG sudo aman && usermod -aG rstudio aman
RUN mkdir -p /home/rstudio/data && chown -R aman:aman /home/rstudio
#bindable volume path
VOLUME ["/home/rstudio/data"]

#install biocmanager
RUN Rscript -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager', repos = 'https://packagemanager.posit.co/cran/2025-02-07')"

RUN Rscript -e "update.packages(ask = FALSE, repos = 'https://packagemanager.posit.co/cran/2025-02-07')"

RUN Rscript -e "install.packages(c('png', 'ggplot2', 'openxlsx', 'plyr', 'dplyr', 'gridExtra', 'pheatmap', 'ggplotify', 'cowplot'), repos = 'https://packagemanager.posit.co/cran/2025-02-07')"

RUN Rscript -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/2025-02-07', BioC_mirror = 'https://packagemanager.posit.co/bioconductor/2025-02-07')); Sys.setenv('R_BIOC_VERSION' = '3.20'); BiocManager::install('multtest', update = FALSE)"

RUN Rscript -e "install.packages(c('mnormt', 'SparseM', 'mvtnorm', 'robustbase', 'metap'), repos = 'https://packagemanager.posit.co/cran/2025-02-07')"

RUN Rscript -e "install.packages(c('data.table', 'reshape2', 'future', 'httr', 'patchwork', 'matrixStats', 'parallelly', 'RcppArmadillo', 'igraph', 'plotly'), repos = 'https://packagemanager.posit.co/cran/2025-02-07')"

RUN Rscript -e "install.packages(c('Seurat', 'SeuratObject', 'ggpubr', 'ggrastr', 'magick', 'tiff', 'concaveman', 'svglite', 'msigdbr', 'VennDiagram', 'gdata', 'VGAM', 'fields', 'ellipse'), repos = 'https://packagemanager.posit.co/cran/2025-02-07')"

RUN Rscript -e "install.packages('remotes', repos = 'https://packagemanager.posit.co/cran/2025-02-07')"

RUN Rscript -e "remotes::install_github('mojaveazure/seurat-disk', upgrade=FALSE, type='source'); \
                remotes::install_github('immunogenomics/presto', upgrade=FALSE, type='source'); \
                remotes::install_github('chris-mcginnis-ucsf/DoubletFinder', upgrade=FALSE, type='source')"

RUN Rscript -e "BiocManager::install(c('GSEABase', 'clusterProfiler', 'scRepertoire', 'ComplexHeatmap', 'scDblFinder'))"

RUN Rscript -e "BiocManager::install(c('GenomicFeatures', 'TxDb.Mmusculus.UCSC.mm10.knownGene', 'org.Hs.eg.db', 'org.Mm.eg.db'))"

#velocyto.R ## not working
RUN pip3 install --break-system-packages --force-reinstall h5py numpy && \
    Rscript -e "Sys.setenv(RETICULATE_PYTHON = '/usr/bin/python3'); remotes::install_github('velocyto-team/velocyto.R', upgrade=FALSE, type='source')"

RUN Rscript -e "install.packages('concaveman', repos='https://packagemanager.posit.co/cran/2025-02-07', INSTALL_opts = '--no-multiarch')"

ENV CXXFLAGS="-fPIC -O2 -Wall"

WORKDIR /home/rstudio

