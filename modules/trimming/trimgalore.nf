process TRIMGALORE {
    tag "$sample_id"
    label 'process_medium'
    container 'biocontainers/trim-galore:0.6.6--0'
    publishDir "${params.outdir}/trimming", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("*_val_*.fq.gz"), emit: reads
    path "*.txt",                                emit: report

    script:
    // Trim Galore automatically detects adapter sequences
    """
    trim_galore \\
        --paired \\
        ${reads[0]} \\
        ${reads[1]} \\
        --cores ${task.cpus} \\
        --gzip
    """
}
