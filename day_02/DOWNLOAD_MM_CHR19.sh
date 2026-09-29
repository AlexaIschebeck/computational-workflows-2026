# chr19 sequence (GRCm38, Ensembl release 102 = last GRCm38 release)
curl -O https://ftp.ensembl.org/pub/release-102/fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.chromosome.19.fa.gz
# full annotation, then keep only chr19 (Ensembl names it "19", no "chr" prefix)
curl -O https://ftp.ensembl.org/pub/release-102/gtf/mus_musculus/Mus_musculus.GRCm38.102.gtf.gz

