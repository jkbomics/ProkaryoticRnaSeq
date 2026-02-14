process SAMTOOLS_SORT {

    tag "$sample_id"
    container 'quay.io/biocontainers/samtools:1.18--h50ea8bc_1'

    publishDir "${params.outdir}/bam", mode: 'copy'

    input:
    tuple val(sample_id), path(sam)

    output:
    tuple val(sample_id), path("${sample_id}.bam")

    script:
    """
    samtools sort -@ ${task.cpus} -o ${sample_id}.bam ${sam}
    """
}
