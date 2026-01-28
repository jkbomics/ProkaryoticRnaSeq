process MULTIQC {

    tag "MultiQC"

    container 'biocontainers/multiqc:v1.21--pyhdfd78af_0'

    publishDir "${params.outdir}/qc/multiqc", mode: 'copy'

    input:
    val trigger

    output:
    path "multiqc_report.html"
    path "multiqc_data"
process MULTIQC {
    tag "MultiQC"
    container 'biocontainers/multiqc:v1.21--pyhdfd78af_0'
    publishDir "${params.outdir}/qc/multiqc", mode: 'copy'

    input:
    path files // Takes all collected files as input to the working directory

    output:
    path "multiqc_report.html"
    path "multiqc_data"

    script:
    """
    multiqc . -o .
    """
}
    script:
    """
    mkdir -p ${params.outdir}
    multiqc ${params.outdir} -o .
    """
}

