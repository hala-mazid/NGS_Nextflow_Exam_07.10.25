// Default reference accession
params.accession = "M21012"
params.out = "${projectDir}/results"
params.storeDir = "${projectDir}/cache"
params.combined_fasta = "hepatitis_combined"

// Download the reference: 
process DOWNLOAD_REF {
    publishDir "${params.out}/reference", mode: 'copy', overwrite: true
    storeDir params.storeDir

    output:
    path "${params.accession}.fasta"

    script:
    """
    wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${params.accession}&rettype=fasta&retmode=text" -O ${params.accession}.fasta
    """
}


process DOWNLOAD_COMBINED_FASTA {
    publishDir "${params.out}/genomes_combined", mode: 'copy', overwrite: true
    storeDir params.storeDir

    output:
    path "${params.combined_fasta}.fasta"

    script:
    """
    wget "https://gitlab.com/dabrowskiw/cq-examples/-/raw/master/data/hepatitis_combined.fasta?inline=false" -O ${params.combined_fasta}.fasta
    """

}

// Combine both FASTA files (Reference and Combined sample data) into a single FASTA file
process CONCAT_ALL_FASTA {
    publishDir "${params.out}/combined_Fasta", mode: 'copy', overwrite: true
    storeDir params.storeDir

    input:
    path ref
    path combined

    output:
    path "all_genomes_combined.fasta"

    script:
    """
    cat $ref $combined > all_genomes_combined.fasta
    """
}

process ALIGN_GENOMES {
    publishDir "${params.out}/alignment", mode: 'copy', overwrite: true
    storeDir params.storeDir

    input:
    path all_combined

    output:
    path "aligned.fasta"

    script:
    """
    mafft --auto $all_combined > aligned.fasta
    """
}

process TRIMAL_CLEANUP {
    publishDir "${params.out}/alignment_cleaned", mode: 'copy', overwrite: true
    conda 'bioconda::trimal'

    input:
    path aligned_file

    output:
    path "${aligned_file.getSimpleName()}_trimmed.fasta"
    path "${aligned_file.getSimpleName()}_report.html"

    script:
    """
    trimal -in ${aligned_file} \
           -out ${aligned_file.getSimpleName()}_trimmed.fasta \
           -automated1 \
           -htmlout ${aligned_file.getSimpleName()}_report.html
    """
}


workflow {
    ref_file = DOWNLOAD_REF()
    combined_file = DOWNLOAD_COMBINED_FASTA()

    all_combined = CONCAT_ALL_FASTA(ref_file, combined_file)

    aligned = ALIGN_GENOMES(all_combined)

    TRIMAL_CLEANUP(aligned)
    }
