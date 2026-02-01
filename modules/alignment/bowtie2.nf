process BOWTIE2_ALIGN {
    tag "$sample_id"
    publishDir "${params.outdir}/alignment", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)
    path index

    output:
    tuple val(sample_id), path("${sample_id}.bam")

    script:
    """
    bowtie2 -x ${index} \\
            -1 ${reads[0]} -2 ${reads[1]} \\
            --threads ${task.cpus} | \\
    samtools sort -@ ${task.cpus} -o ${sample_id}.bam
    """
}
