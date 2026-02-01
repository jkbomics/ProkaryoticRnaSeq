process SAMTOOLS_STATS {
    tag "$sample_id"
    
    input:
    tuple val(sample_id), path(bam) // Must match the output of BOWTIE2_ALIGN

    output:
    path "*.stats"

    script:
    """
    samtools stats ${bam} > ${sample_id}.stats
    """
}
