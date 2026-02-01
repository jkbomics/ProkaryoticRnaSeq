process MULTIQC {
    tag "MultiQC"
    container 'biocontainers/multiqc:v1.21--pyhdfd78af_0'
    publishDir "${params.outdir}/qc/multiqc", mode: 'copy'

    input:
    path '*' // Takes all files collected from the workflow

    output:
    path "multiqc_report.html"
    path "multiqc_data"

    script:
    """
    multiqc .
    """
}
