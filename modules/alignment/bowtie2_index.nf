process BOWTIE2_INDEX {

    tag "bowtie2-index"
    container 'quay.io/biocontainers/bowtie2:2.5.1--py310h8d7afc0_0'

    publishDir "${params.outdir}/index", mode: 'copy'

    input:
    path genome_fasta

    output:
    tuple val("ecoli_index"), path("ecoli_index*.bt2")

    script:
    """
    bowtie2-build ${genome_fasta} ecoli_index
    """
}
