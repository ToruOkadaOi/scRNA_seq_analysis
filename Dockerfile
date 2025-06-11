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

# Set compiler flags (as a Docker ENV directive) ## This can be removed as it was for velocyto.R
ENV CXXFLAGS="-fPIC -O2 -Wall"

# Fix velocyto.R installation # This part is not working 
RUN apt-get update && apt-get install -y \
    libprotobuf-dev protobuf-compiler libhdf5-dev python3 python3-pip python3-dev && \
    pip3 install --break-system-packages --force-reinstall h5py numpy && \
    export CXXFLAGS="-fPIC -O2 -Wall" && \
    Rscript -e "Sys.setenv(RETICULATE_PYTHON = '/usr/bin/python3'); remotes::install_github('velocyto-team/velocyto.R@83e6ed92c2d9c9640122dcebf8ebbb5788165a21', upgrade=FALSE, type='source')"

# .yml file was first copied to the build directory
COPY scanpy_v1.10.4_r.yml /tmp/scanpy_v1.10.4_r.yml

# Installing miniforge for which comes with conda and then proceeding with mamba for faster dependency resolve. Environment created for scanpy is named - 'scanpy_v1.10.4_r'
# download
RUN wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O /tmp/miniforge.sh && \
#install
    bash /tmp/miniforge.sh -b -p /opt/conda && \
#remove
    rm /tmp/miniforge.sh && \
#symlink to conda environment activation
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
#mamba install
    /opt/conda/bin/conda install -y mamba -n base -c conda-forge && \
#add to path
    export PATH="/opt/conda/bin:$PATH" && \
#create environment
    mamba env create -f /tmp/scanpy_v1.10.4_r.yml && \
#clean up
    conda clean -a -y && rm -rf /tmp/scanpy_v1.10.4_r.yml /root/.cache/pip

#prioritizing executables from the scanpy environment and the base Conda
ENV PATH="/opt/conda/envs/scanpy_v1.10.4_r/bin:/opt/conda/bin:$PATH"

#Installing ipykernel for jupyter support
RUN conda run -n scanpy_v1.10.4_r python -m ipykernel install --user --name=scanpy --display-name "python_scanpy"

WORKDIR /home/rstudio

#installing jupyter notebook and ipykernel systemwide ## ipykernel could also be installed with conda env using .yml file for faster building
RUN apt-get update && apt-get install -y python3-pip && \
    pip3 install --no-cache-dir notebook ipykernel

#making sure binaries are accessible in docker shell
ENV PATH="/usr/local/bin:$PATH"

#installing R kernel for jupyter ## Select kernel with name R (shared) in jupyter as it is the system wide one
RUN R -e "install.packages('IRkernel', repos='https://cloud.r-project.org'); \
          IRkernel::installspec(name = 'system-r', displayname = 'R (shared)', user = FALSE)"

# Velocyto in python

ENV CONDA_HTTP_TIMEOUT=120
ENV CONDA_RETRIES=5

RUN mamba create -n velocyto -y numpy scipy cython numba matplotlib scikit-learn h5py click ipykernel && \
    conda clean -afy

SHELL ["conda", "run", "-n", "velocyto", "/bin/bash", "-c"]

RUN pip install pysam && \
    pip install --no-build-isolation velocyto

RUN velocyto --version || echo "install or version check failed"

RUN python -m ipykernel install --user --name=velocyto --display-name "python_velocyto"

# velocyto in R

ENV MAKEFLAGS="-j4"
ENV PKG_CXXFLAGS="-std=gnu++11 -fopenmp -fpic -g -O2"

# dep - apt
RUN apt-get update && apt-get install -y \
    libbamtools-dev \
    libboost-dev \
    libboost-iostreams-dev \
    libboost-log-dev \
    libboost-system-dev \
    libboost-test-dev \
    libhdf5-dev \
    libarmadillo-dev

# clean - apt
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# dep - R
RUN Rscript -e "install.packages('BiocManager', repos='https://packagemanager.posit.co/cran/2025-02-07')" && \
    Rscript -e "install.packages(c('Rcpp','RcppArmadillo','Matrix','mgcv','abind','igraph','data.table','devtools','h5','Rtsne','cluster'), repos='https://packagemanager.posit.co/cran/2025-02-07')" && \
    Rscript -e "BiocManager::install(c('pcaMethods','edgeR','Rsamtools','GenomicAlignments','GenomeInfoDb','Biostrings'), update = FALSE, ask = FALSE)"


# Clone and install velocyto.R directly into system R library
RUN git clone https://github.com/velocyto-team/velocyto.R /tmp/velocyto.R && \
    sed -i 's/Rf_warning(es.str().c_str());/Rf_warning("%s", es.str().c_str());/' /tmp/velocyto.R/src/routines.cpp && \
    R -e "Sys.setenv(PKG_CXXFLAGS='-std=gnu++11 -fopenmp -fpic -g -O2'); devtools::install_local('/tmp/velocyto.R', INSTALL_opts = c('--library=/usr/local/lib/R/site-library'))" && \
    rm -rf /tmp/velocyto.R
