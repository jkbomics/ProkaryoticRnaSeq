nextflow.enable.dsl = 2

// Import modules
include { FASTQC }        from './modules/qc/fastqc'
include { MULTIQC }       from './modules/qc/multiqc'
include { TRIMGALORE }    from './modules/trimming/trimgalore'
include { BOWTIE2_ALIGN } from './modules/alignment/bowtie2'
include { SAMTOOLS_STATS }from './modules/stats/samtools'
include { FEATURECOUNTS } from './modules/counting/featurecounts'

workflow {
    // We use 'it' to represent the whole bundle [ID, R1, R2]
    // Then we manually pick them: it[0] is ID, it[1] and it[2] are the reads
    read_pairs_ch = Channel
        .fromFilePairs(params.reads, flat: true)
        .map { it -> [ it[0], [it[1], it[2]] ] }

    // QC and Trimming
    // These now receive a tuple: [sample_id, [file1, file2]]
    fastqc_out    = FASTQC(read_pairs_ch)
    trimmed_out   = TRIMGALORE(read_pairs_ch)

    // Alignment
    // trimgalore outputs a tuple [id, [trimmed_f1, trimmed_f2]]
    aligned_out   = BOWTIE2_ALIGN(trimmed_out, params.genome)

    // Post-alignment stats
    stats_out     = SAMTOOLS_STATS(aligned_out)

    // Quantification
    // We grab only the BAM files (it[1]) and collect them into one list
    feature_counts = FEATURECOUNTS(aligned_out.map{ it[1] }.collect(), params.annotation)

    // MultiQC - Aggregate all output files
    multiqc_files = Channel.empty()
        .mix(fastqc_out.collect())
        .mix(trimmed_out.collect())
        .mix(stats_out.collect())
        .mix(feature_counts.collect())

    MULTIQC(multiqc_files.collect())
}
