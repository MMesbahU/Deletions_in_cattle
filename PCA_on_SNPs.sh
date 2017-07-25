#!/bin/bash


#	Select high-quality bi-allelic SNPs using VCFtools (0.1.15): chr = (1 to 29); VCFtools (0.1.15)
vcftools \
	--vcf  File.Chr${chr}.vcf \
	--minQ 50 \
	--min-alleles 2 \
	--max-alleles 2 \
	--remove-indels \
	--recode 
	-c | gzip -c > File.Chr${chr}.vcf.gz

#	Keep SNPs with 100% genotype

for chr in {1..29} 
do 
	plink-1.9-rc \
		--vcf File.Chr${chr}.vcf.gz \
		--geno 0.0 \
		--recode vcf \
		--cow \
		--out File.Chr${chr}.no-missing 
done
 
#	Extract chromosome and SNP positions

for chr in {1..29} 
do 
	grep -v '^#' File.Chr${chr}.no-missing.vcf | cut -f1,2 > Chr$chr.Positions.dat 
done

#	Randomly select 1% SNPs from each chromosome 
#Select ≤1% SNPs

for chr in {1..29} 
do 
	awk 'BEGIN {srand()} !/^$/ { if (rand() <= .01) print $0}' Chr$chr.Positions.dat > Chr$chr.random_positions.dat 
done


# Filter VCF file for selected SNPs
for chr in {1..29};
do 
	vcftools \
		--vcf Chr$chr.gatk.no-miss.vcf \
		--positions Chr$chr.random_positions.dat \
		--out Chr$chr.Random.SNPs \
		--recode
done

#	Merge all the chromosomes 
vcf-concat \
	Chr$chr.Random.SNPs.recode.vcf | \
	vcf-sort -c | gzip -c > \
	Chr1_29.Random_SNPs.vcf.gz



#	PCA using plink-1.9-rc

plink-1.9-rc \
	--vcf Chr1_29.Random_SNPs.vcf.gz \
	--pca \
	--out Chr1_29.Random_SNPs \
	--cow


