# List of packages to check
packages <- c(
  'BiocManager', 'png', 'ggplot2', 'openxlsx', 'plyr', 'dplyr', 'gridExtra', 
  'pheatmap', 'ggplotify', 'cowplot', 'devtools', 'doParallel', 'reticulate', 
  'multtest', 'mnormt', 'SparseM', 'mvtnorm', 'robustbase', 'metap', 
  'data.table', 'reshape2', 'future', 'httr', 'patchwork', 'matrixStats', 
  'parallelly', 'RcppArmadillo', 'igraph', 'plotly', 'Seurat', 'SeuratObject', 
  'ggpubr', 'ggrastr', 'magick', 'tiff', 'concaveman', 'svglite', 'msigdbr', 
  'VennDiagram', 'gdata', 'VGAM', 'fields', 'ellipse', 'GSEABase', 
  'clusterProfiler', 'scRepertoire', 'ComplexHeatmap', 'scDblFinder', 
  'GenomicFeatures', 'TxDb.Mmusculus.UCSC.mm10.knownGene', 'org.Hs.eg.db', 
  'org.Mm.eg.db'
)

# Check if each package is installed
missing <- packages[!sapply(packages, require, character.only = TRUE)]
if (length(missing) > 0) {
  cat("Missing packages:\n")
  print(missing)
} else {
  cat("All packages are installed correctly!\n")
}

# Check GitHub-installed packages
github_packages <- c(
  'SeuratDisk', 'presto', 'DoubletFinder', 'velocyto.R'
)

missing_github <- github_packages[!sapply(github_packages, require, character.only = TRUE)]
if (length(missing_github) > 0) {
  cat("Missing GitHub-installed packages:\n")
  print(missing_github)
} else {
  cat("All GitHub-installed packages are installed correctly!\n")
}

library(Seurat)
library(SeuratObject)
