process FASTQC {

    tag "$sample_id"

    publishDir "${params.outdir}/qc/fastqc", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    path "*.html"
    path "*.zip"

    script:
    """
    fastqc ${reads} --threads ${task.cpus}
    """
}
