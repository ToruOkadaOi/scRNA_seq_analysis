#1. Seurat using sctransform on patient 4
library(Seurat)
library(ggplot2)
library(sctransform)

patient3.data <- Read10X(data.dir = "/home/rstudio/run070/run070-nsclc-3_RSEC_MolsPerCell_MEX")
patient3 <- CreateSeuratObject(counts = patient3.data, project = "zehn_dataset", min.cells = 3, min.features = 200)

#ncol(zehn)
#Assays(zehn)
#zehn[["RNA"]]
#GetAssayData(zehn, slot = "counts")[, 1:30] #counts are inside Assays

#QC #calculates the percentage of counts originating from a set of features #mitochondrial contamination
patient3[["percent.mt"]] <- PercentageFeatureSet(patient3, pattern = "^MT-")

# Violin Plot
VlnPlot(patient3, features = c("nFeature_RNA", "nCount_RNA", "percent.mt"), ncol = 3)

# run sctransform
# this single command replaces NormalizeData(), ScaleData(), and FindVariableFeatures() #install glmGamPoi
patient3_transform <- SCTransform(patient3, verbose = FALSE) #No filtering based on mito. contamination

#2. scRepertoire on patient 4

library(scRepertoire)
S1 <- read.delim("/home/rstudio/run070/run070-nsclc-3_VDJ_Dominant_Contigs_AIRR.tsv", sep = "\t", header = TRUE, stringsAsFactors = FALSE)

contig_list <- list(S1)
contig.list <- loadContigs(input = S1, 
                           format = "AIRR")

#3. Seurat using sctransform on patient 3



#4. scRepertoire on patient 3

#5. Seurat using sctransform and RPCA integration on patients 3 and 4

#6. scRepertoire on patients 3 and 4
