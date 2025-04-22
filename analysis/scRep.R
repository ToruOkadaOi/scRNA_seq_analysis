#List of data frames example
library(scRepertoire)
S1 <- read.delim("/home/rstudio/run071-nsclc-4_VDJ_Dominant_Contigs_AIRR.tsv", sep = "\t", header = TRUE, stringsAsFactors = FALSE)

colnames(S1)

#contig.output <- c("/home/rstudio/")
contig_list <- list(S1)
contig.list <- loadContigs(input = S1, 
                           format = "AIRR")

contig_list <- list(S1)
contig.list <- loadContigs(input = '/home/rstudio/', 
                           format = "BD")

data("contig_list") #the data built into scRepertoire

head(contig_list)
head(contig_list[[1]])

# Is it necessary to have paired sequence to identify clonotypes?
# in the tutorial, they specify a sample list, should it be added? undetermined in run071-nsclc-4_VDJ_Dominant_Contigs_AIRR.tsv
combined.TCR <- combineTCR(contig_list,
                           removeNA = FALSE, 
                           removeMulti = FALSE, 
                           filterMulti = FALSE)

# output = a list of contig data frames that will be reduced to the reads associated with a single cell barcode. It will also combine the multiple reads into clone calls by either the nucleotide sequence (CTnt), amino acid sequence (CTaa), the VDJC gene sequence (CTgene), or the combination of the nucleotide and gene sequence (CTstrict).
head(combined.TCR[[1]])
#colnames(combined.TCR)
#combined.TCR

# total or relative numbers of unique clones.
clonalQuant(combined.TCR, 
            cloneCall="strict", 
            chain = "both", 
            scale = TRUE)

# for TRA
clonalQuant(combined.TCR, 
            cloneCall="strict", 
            chain = "TRA", 
            scale = TRUE)

# group by 'barcode'
#clonalQuant(combined.TCR, cloneCall = "gene", group.by = "TCR1", scale = TRUE)

# a total number of clones by the number of instances within the sample or run
clonalAbundance(combined.TCR, 
                cloneCall = "gene", 
                scale = FALSE)

#Clonal abundance = How many cells belong to each clone
clonalAbundance(combined.TCR, cloneCall = "gene", scale = TRUE)

clonalLength(combined.TCR, 
             cloneCall="aa", 
             chain = "both") 

clonalLength(combined.TCR, 
             cloneCall="aa", 
             chain = "TRA", 
             scale = TRUE) 

clonalCompare(combined.TCR, 
              top.clones = 10, 
              samples = c("S1", "S2"), 
              cloneCall="aa", 
              graph = "alluvial")

clonalHomeostasis(combined.TCR, 
                  cloneCall = "gene")

clonalScatter(combined.TCR, 
              cloneCall ="gene", 
              x.axis = "S1", 
              y.axis = "S2",
              dot.size = "total",
              graph = "proportion")

clonalHomeostasis(combined.TCR, 
                  cloneCall = "gene",
                  cloneSize = c(Rare = 0.001, Small = 0.01, Medium = 0.1, Large = 0.3, Hyperexpanded =
                                  1))

combined.TCR <- addVariable(combined.TCR, 
                            variable.name = "Type", 
                            variables = rep(c("B", "L"), 4))

clonalHomeostasis(combined.TCR, 
                  group.by = "Type",
                  cloneCall = "gene")

clonalProportion(combined.TCR, 
                 cloneCall = "gene") 

clonalProportion(combined.TCR, 
                 cloneCall = "nt",
                 clonalSplit = c(1, 5, 10, 100, 1000, 10000)) 

#summarizing repertoires
percentAA(combined.TCR, 
          chain = "TRB", 
          aa.length = 20)

percentAA(combined.TCR, 
          chain = "TRA", 
          aa.length = 20)

positionalEntropy(combined.TCR, 
                  chain = "TRB", 
                  aa.length = 20)

positionalEntropy(combined.TCR, 
                  chain = "TRA", 
                  aa.length = 20)

positionalProperty(combined.TCR[c(1,2)], 
                   chain = "TRB", 
                   aa.length = 20, 
                   method = "Atchley") + 
  scale_color_manual(values = hcl.colors(5, "inferno")[c(2,4)])

vizGenes(combined.TCR, 
         x.axis = "TRBV",
         y.axis = NULL,
         plot = "barplot",  
         scale = TRUE)

#Peripheral Blood
vizGenes(combined.TCR[c(1,3,5,7)], 
         x.axis = "TRBV",
         y.axis = "TRBJ",
         plot = "heatmap",  
         scale = TRUE)

#Lung
vizGenes(combined.TCR[c(2,4,6,8)], 
         x.axis = "TRBV",
         y.axis = "TRBJ",
         plot = "heatmap",  
         scale = TRUE)

percentGenes(combined.TCR, 
             chain = "TRB", 
             gene = "Vgene")

df.genes <- percentGenes(combined.TCR, 
                         chain = "TRB", 
                         gene = "Vgene", 
                         exportTable = TRUE)

df.genes <- percentGenes(combined.TCR, 
                         chain = "TRB", 
                         gene = "Vgene", 
                         exportTable = TRUE)

#Performing PCA
pc <- prcomp(df.genes)

#Getting data frame to plot from
df <- as.data.frame(cbind(pc$x[,1:2], rownames(df.genes)))
df$PC1 <- as.numeric(df$PC1)
df$PC2 <- as.numeric(df$PC2)

#Plotting
ggplot(df, aes(x = PC1, y = PC2)) + 
  geom_point(aes(fill =df[,3]), shape = 21, size = 5) + 
  guides(fill=guide_legend(title="Samples")) + 
  scale_fill_manual(values = hcl.colors(nrow(df), "inferno")) + 
  theme_classic() 

percentVJ(combined.TCR[1:2], #First Two Samples
          chain = "TRB")


df.genes <- percentVJ(combined.TCR, 
                      chain = "TRB", 
                      exportTable = TRUE)

#Performing PCA
pc <- prcomp(df.genes)

#Getting data frame to plot from
df <- as.data.frame(cbind(pc$x[,1:2], rownames(df.genes))) 
df$PC1 <- as.numeric(df$PC1)
df$PC2 <- as.numeric(df$PC2)

#Plotting
ggplot(df, aes(x = PC1, y = PC2)) + 
  geom_point(aes(fill =df[,3]), shape = 21, size = 5) + 
  guides(fill=guide_legend(title="Samples")) + 
  scale_fill_manual(values = hcl.colors(nrow(df), "inferno")) + 
  theme_classic() 

percentKmer(combined.TCR, 
            cloneCall = "aa",
            chain = "TRB", 
            motif.length = 3, 
            top.motifs = 25)

#Comparing Clonal Diversity and Overlap
clonalDiversity(combined.TCR, 
                cloneCall = "gene")

combined.TCR <- addVariable(combined.TCR, 
                            variable.name = "Patient", 
                            variables = c("P17", "P17", "P18", "P18", 
                                          "P19","P19", "P20", "P20"))

clonalDiversity(combined.TCR, 
                cloneCall = "gene", 
                group.by = "Patient")
#clonalRarefaction
clonalRarefaction(combined.TCR,
                  plot.type = 1,
                  hill.numbers = 0,
                  n.boots = 2)

clonalRarefaction(combined.TCR,
                  plot.type = 2,
                  hill.numbers = 0,
                  n.boots = 2)

clonalRarefaction(combined.TCR,
                  plot.type = 3,
                  hill.numbers = 0,
                  n.boots = 2)

clonalRarefaction(combined.TCR,
                  plot.type = 1,
                  hill.numbers = 1,
                  n.boots = 2)

clonalRarefaction(combined.TCR,
                  plot.type = 2,
                  hill.numbers = 1,
                  n.boots = 2)

clonalRarefaction(combined.TCR,
                  plot.type = 3,
                  hill.numbers = 1,
                  n.boots = 2)

clonalSizeDistribution(combined.TCR, 
                       cloneCall = "aa", 
                       method= "ward.D2")

clonalOverlap(combined.TCR, 
              cloneCall = "strict", 
              method = "morisita")

clonalOverlap(combined.TCR, 
              cloneCall = "strict", 
              method = "raw")

sub_combined <- clonalCluster(combined.TCR[[2]], 
                              chain = "TRA", 
                              sequence = "aa", 
                              threshold = 0.85, 
                              group.by = NULL)

head(sub_combined[,c(1,2,13)])
#Clustering Patient 19 samples
igraph.object <- clonalCluster(combined.TCR[c(5,6)],
                               chain = "TRB",
                               sequence = "aa",
                               group.by = "sample",
                               threshold = 0.85, 
                               exportGraph = TRUE)

#Setting color scheme
col_legend <- factor(igraph::V(igraph.object)$group)
col_samples <- hcl.colors(3,"inferno")[as.numeric(col_legend)]
color.legend <- factor(unique(igraph::V(igraph.object)$group))

#Plotting
plot(
  igraph.object,
  vertex.size     = sqrt(igraph::V(igraph.object)$size),
  vertex.label    = NA,
  edge.arrow.size = .25,
  vertex.color    = col_samples
)
legend("topleft", legend = levels(color.legend), pch = 16, col = unique(col_samples), bty = "n")
#last few code blocks not run
#Combining Clones and Single-Cell Objects

# Check the first 10 variable features before removal
VariableFeatures(zehn_s)[1:10]
library(Seurat)
library(scRepertoire)
# Remove TCR VDJ genes
scRep_example <- quietTCRgenes(zehn_s) #Error in quietTCRgenes(zehn_s) : could not find function "quietTCRgenes"
#https://www.borch.dev/uploads/screpertoire/articles/attaching_sc

# Check the first 10 variable features after removal
VariableFeatures(scRep_example)[1:10]

scRep_example <- readRDS("scRep_example_full.rds") #Why can't I access this example? Doesn't it come with the package?

#Making a Single-Cell Experiment object
sce <- Seurat::as.SingleCellExperiment(scRep_example)

sce <- combineExpression(combined.TCR, 
                         sce, 
                         cloneCall="gene", 
                         group.by = "sample", 
                         proportion = TRUE)

#Define color palette 
colorblind_vector <- hcl.colors(n=7, palette = "inferno", fixup = TRUE)

plotUMAP(sce, colour_by = "cloneSize") +
  scale_color_manual(values=rev(colorblind_vector[c(1,3,5,7)]))