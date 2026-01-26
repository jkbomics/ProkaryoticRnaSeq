nextflow.enable.dsl = 2

include { FASTQC }        from './modules/qc/fastqc'
include { MULTIQC }       from './modules/qc/multiqc'
include { TRIMGALORE }    from './modules/trimming/trimgalore'
include { BOWTIE2_ALIGN } from './modules/alignment/bowtie2'
include { SAMTOOLS_STATS }from './modules/stats/samtools'
include { FEATURECOUNTS } from './modules/counting/featurecounts'

workflow {

    Channel
        .fromFilePairs(params.reads, flat: true)
        .map { sample_id, reads -> tuple(sample_id, reads) }
        .set { read_pairs }

    FASTQC(read_pairs)

    trimmed = TRIMGALORE(read_pairs)

    aligned = BOWTIE2_ALIGN(trimmed, params.genome)

    SAMTOOLS_STATS(aligned)

    FEATURECOUNTS(aligned.collect(), params.annotation)

    /*
     * 🔑 Ensure results directory exists
     */
    file(params.outdir).mkdirs()

    /*
     * Run MultiQC once at the end
     */
    MULTIQC(true)
}
