nextflow.enable.dsl = 2

include { FASTQC }        from './modules/qc/fastqc'
include { MULTIQC }       from './modules/qc/multiqc'
include { TRIMGALORE }    from './modules/trimming/trimgalore'
include { BOWTIE2_ALIGN } from './modules/alignment/bowtie2'
include { SAMTOOLS_STATS }from './modules/stats/samtools'
include { FEATURECOUNTS } from './modules/counting/featurecounts'

workflow {
    // FIX: Manually group the files so Nextflow doesn't get confused
    read_pairs_ch = Channel
        .fromFilePairs(params.reads, flat: true)
        .map { it -> [ it[0], [it[1], it[2]] ] }

    // Now pass this fixed channel to your processes
    fastqc_out    = FASTQC(read_pairs_ch)
    trimmed_out   = TRIMGALORE(read_pairs_ch)

    // Alignment: Note that TRIMGALORE also returns a tuple [id, [files]]
    aligned_out   = BOWTIE2_ALIGN(trimmed_out, params.genome)

    // Stats
    stats_out     = SAMTOOLS_STATS(aligned_out)

    // Quantification: Collect only the BAM files (index 1 of the tuple)
    feature_counts = FEATURECOUNTS(aligned_out.map{ it[1] }.collect(), params.annotation)

    // MultiQC: Aggregate all logs
    multiqc_files = Channel.empty()
        .mix(fastqc_out.collect())
        .mix(stats_out.collect())
        .mix(feature_counts.collect())

    MULTIQC(multiqc_files.collect())
}

