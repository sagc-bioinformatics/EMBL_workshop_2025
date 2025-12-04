# Load libraries ####
library(rlang)
library(stringr)
library(argparse)
library(ggplot2)
library(dplyr)
library(forcats)

library(DOSE)
library(enrichplot)
library(clusterProfiler)
library(AnnotationDbi)
library(lplyr)
library(msigdbr)
library(msigdbdf)
library(org.Hs.eg.db)
library(org.Mm.eg.db)

# Argument parser ####
parser <- ArgumentParser(description = "Run GSEA analysis using DEG from Loupe Browser. This will be against mouse GO:BP.")
parser$add_argument(
  "-w", "--workdir",
  type = "character",
  help = "User's preferred working directory",
  default = getwd()
)
parser$add_argument(
  "-d", "--degfile",
  type = "character",
  help = "Path to DEG CSV file from Loupe Browser",
  default = "brain_vs_alcohol_DEGall.csv"
)
parser$add_argument(
  "-c", "--cluster",
  type = "character",
  help = "The cluster name made in Loupe Browser to use as input gene set",
  default = "alcohol_preference"
)
args <- parser$parse_args()
setwd(args$workdir)
cat("Working directory set to:", getwd(), "\n")
if (!file.exists(args$degfile)) {
  stop(paste("DEG file not found:", args$degfile))
}
deg_df <- read.csv(args$degfile, header = TRUE)
## Throw an error if cluster name not found in DEG file ####
logfc_col <- paste0(args$cluster, ".Log2.Fold.Change")
pval_col <- paste0(args$cluster, ".P.Value")
if (!(logfc_col %in% colnames(deg_df)) || !(pval_col %in% colnames(deg_df))) {
  stop(paste("DEG file does not contain expected columns for cluster:", args$cluster))
}
cat("Loaded DEG gene list with", nrow(deg_df), "rows.\n")


################Mouse Embryo GSEA Start#############################
# Volcano plot of the alcohol preference DEG for visualization ####
# See tutorial in https://erikaduan.github.io/posts/2021-01-02-volcano-plots-with-ggplot2/
## Volcano plotting ####
vol_plot <- deg_df %>% 
  ggplot(aes(x = !!sym(logfc_col),
             y = -log10(!!sym(pval_col)))) +
  geom_point() +
  ylim(0,10)
vol_plot
## Saving the plot ####
ggsave(filename = file.path(args$workdir,
                            "volplot_tutorial.pdf"),
       dpi = 600,
       width = 17, 
       height = 10, 
       unit = "cm",
       vol_plot)

# Prepare reference gene sets for analysis ####
# Here I want to download mouse GO:BP
msig <- msigdbr(species = "Mus musculus")
c5_t2g <- msig %>%
  filter(gs_cat == "C5", gs_subcat == "GO:BP") %>%
  select(gs_name, ensembl_gene) %>%
  distinct()

# Let's focus on alcohol preference. Sort by p-value and get the top 100. ####
df <- deg_df %>% 
  dplyr::select(FeatureName, 
                !!sym(logfc_col), 
                !!sym(pval_col)) %>% 
  dplyr::top_n(100, -!!sym(pval_col)) %>% 
  dplyr::rename(SYMBOL = FeatureName) %>% 
  dplyr::rename(Log2FC = !!sym(logfc_col)) %>% 
  dplyr::select(-!!sym(pval_col))
## Converting the SYMBOL into ENTREZ ID ####
ensembl_data <- AnnotationDbi::select(org.Mm.eg.db, 
                                     keys = df$SYMBOL,
                                     columns = c("SYMBOL", "ENSEMBL"),
                                     keytype = "SYMBOL")
## Removing NA's ####
anno <- ensembl_data %>% 
  dplyr::filter(!is.na(ENSEMBL)) %>%
  inner_join(df, by = "SYMBOL")
## Turn dataframe into named vector ####
geneList <- setNames(anno$Log2FC, anno$ENSEMBL)
geneList <- sort(geneList, decreasing = TRUE)

# Run GSEA ####
c5 <- GSEA(geneList, 
           TERM2GENE = c5_t2g)
## Add gene symbols to the output for easy intrepretation ####
c5 <- setReadable(c5, OrgDb = org.Mm.eg.db, keyType = "ENSEMBL")
c5_df <- c5@result
# Plotting top 10 upregulated gene sets ####
options(repr.plot.width=10, repr.plot.height=6)
sorted_c5<- c5@result[order(c5@result$NES, decreasing = F),]
sorted_c5$color<-ifelse(sorted_c5$NES>0, 
                        "Enriched among alcohol-preference genes", 
                        "Enriched among other genes in the temporal lobe")
sorted_c5 %>%
  dplyr::group_by(color) %>%
  dplyr::arrange(desc(abs(NES))) %>%
  slice_head(n = 10) %>%
  ggplot(aes(x = NES, 
             y = reorder(Description, NES), 
             fill = color)) +
  geom_bar(stat = "identity") +
  geom_vline(xintercept = 0) +
  labs(y = "Description") +
  theme_classic() +
  scale_fill_manual(values=c("#ffa557", "#4296f5")) +
  theme(legend.position = "right")
## Saving the plot ####
ggsave(filename = file.path(args$workdir,
                            "go_barplot_tutorial.pdf"),
       dpi = 600,
       width = 30, 
       height = 15, 
       unit = "cm")

# Select one of the gene sets to explore more in-depth ####
# I found the "central nervous system neuron differentiation" in the Msigdb website: https://www.gsea-msigdb.org/gsea/msigdb/mouse/geneset/GOBP_CENTRAL_NERVOUS_SYSTEM_NEURON_DIFFERENTIATION.html
options(repr.plot.width=8, repr.plot.height=6)
gseaplotted <- gseaplot(c5, by = "all", 
         title = "Neuron differentiation", 
         geneSetID = "GOBP_CENTRAL_NERVOUS_SYSTEM_NEURON_DIFFERENTIATION")
## Saving the plot ####
ggsave(filename = file.path(args$workdir,
                            "gseaplot_tutorial.pdf"),
       dpi = 600,
       width = 30, 
       height = 20,
       unit = "cm",
       gseaplotted)

c5_df["GOBP_CENTRAL_NERVOUS_SYSTEM_NEURON_DIFFERENTIATION",]
cnetplotted <- cnetplot(c5, 
         categorySize="pvalue", 
         showCategory = c("GOBP_CENTRAL_NERVOUS_SYSTEM_NEURON_DIFFERENTIATION"))
## Saving the plot ####
ggsave(filename = file.path(args$workdir,
                            "cnet_tutorial.pdf"),
       dpi = 600,
       width = 30, 
       height = 15, 
       unit = "cm",
       cnetplotted)

# For references of all the packages and tools used in this session ####
sessionInfo()
.libPaths()

################Mouse Embryo GSEA End#############################


