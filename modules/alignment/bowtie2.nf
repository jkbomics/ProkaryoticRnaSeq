process BOWTIE2_ALIGN {

    tag "$sample_id"

    publishDir "${params.outdir}/alignment", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)
    path genome_index

    output:
    tuple val(sample_id), path("${sample_id}.bam")

    script:
    """
    bowtie2 -x ${genome_index} \
            -1 ${reads[0]} -2 ${reads[1]} |
    samtools sort -o ${sample_id}.bam
    """
}
