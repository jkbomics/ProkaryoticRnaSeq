nextflow.enable.dsl = 2

// Import modules
include { FASTQC }        from './modules/qc/fastqc'
include { MULTIQC }       from './modules/qc/multiqc'
include { TRIMGALORE }    from './modules/trimming/trimgalore'
include { BOWTIE2_ALIGN } from './modules/alignment/bowtie2'
include { SAMTOOLS_STATS }from './modules/stats/samtools'
include { FEATURECOUNTS } from './modules/counting/featurecounts'

workflow {
    // FIX: Restructure the flat [id, r1, r2] into [id, [r1, r2]]
    read_pairs_ch = Channel
        .fromFilePairs(params.reads, flat: true)
        .map { it -> [ it[0], [it[1], it[2]] ] }

    // QC and Trimming
    fastqc_out    = FASTQC(read_pairs_ch)
    trimmed_out   = TRIMGALORE(read_pairs_ch)

    // Alignment
    aligned_out   = BOWTIE2_ALIGN(trimmed_out, params.genome)

    // Post-alignment stats
    stats_out     = SAMTOOLS_STATS(aligned_out)

    // Quantification - Collect all BAM files into a single list
    // We use .map{ it[1] } to get the file path, ignoring the sample_id
    feature_counts = FEATURECOUNTS(aligned_out.map{ it[1] }.collect(), params.annotation)

    // MultiQC - Aggregate all logs
    // We collect() every channel to ensure MultiQC waits for all samples to finish
    multiqc_files = Channel.empty()
        .mix(fastqc_out.collect())
        .mix(trimmed_out.collect())
        .mix(stats_out.collect())
        .mix(feature_counts.collect())

    MULTIQC(multiqc_files.collect())
}
