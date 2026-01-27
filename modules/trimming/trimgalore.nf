process TRIMGALORE {

    tag "$sample_id"

    publishDir "${params.outdir}/trimmed", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("*_val_*.fq.gz")

    script:
    """
    trim_galore --paired ${reads[0]} ${reads[1]}
    """
}
