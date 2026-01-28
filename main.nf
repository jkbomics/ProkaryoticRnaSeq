nextflow.enable.dsl = 2

include { FASTQC }        from './modules/qc/fastqc'
include { MULTIQC }       from './modules/qc/multiqc'
include { TRIMGALORE }    from './modules/trimming/trimgalore'
include { BOWTIE2_ALIGN } from './modules/alignment/bowtie2'
include { SAMTOOLS_STATS }from './modules/stats/samtools'
include { FEATURECOUNTS } from './modules/counting/featurecounts'

workflow {

    // Correctly group the flat output into [sample_id, [read1, read2]]
    read_pairs = Channel
        .fromFilePairs(params.reads, flat: true)
        .map { it -> [ it[0], [it[1], it[2]] ] }

    // Run Quality Control
    fastqc_results = FASTQC(read_pairs)

    // Run Trimming
    trimmed_results = TRIMGALORE(read_pairs)

    // Run Alignment - Ensure params.genome is a valid bowtie2 index prefix
    aligned_results = BOWTIE2_ALIGN(trimmed_results, params.genome)

    // Run Stats
    stats_results = SAMTOOLS_STATS(aligned_results)

    // Run Counting
    feature_counts = FEATURECOUNTS(aligned_results.collect { it[1] }, params.annotation)

    /*
     * Collect all report-generating outputs to trigger MultiQC
     */
    ch_multiqc_files = Channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(
        fastqc_results.collect(),
        trimmed_results.collect { it[1] },
        stats_results.collect(),
        feature_counts.collect()
    )

    MULTIQC(ch_multiqc_files.collect())
}
