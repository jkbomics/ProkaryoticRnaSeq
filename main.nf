nextflow.enable.dsl = 2

include { FASTQC }        from './modules/qc/fastqc'
include { MULTIQC }       from './modules/qc/multiqc'
include { TRIMGALORE }    from './modules/trimming/trimgalore'
include { BOWTIE2_ALIGN } from './modules/alignment/bowtie2'
include { SAMTOOLS_STATS }from './modules/stats/samtools'
include { FEATURECOUNTS } from './modules/counting/featurecounts'

workflow {
    // This is the part that was failing. 
    // We take the raw list and manually assign the ID and the Reads sub-list.
    read_pairs = Channel
        .fromFilePairs(params.reads, flat: true)
        .map { it -> 
            def sample_id = it[0]
            def reads = [it[1], it[2]]
            return tuple(sample_id, reads)
        }

    // QC and Trimming
    fastqc_out    = FASTQC(read_pairs)
    trimmed_out   = TRIMGALORE(read_pairs)

    // Alignment - TRIMGALORE outputs a tuple [id, [r1, r2]]
    aligned_out   = BOWTIE2_ALIGN(trimmed_out, params.genome)

    // Stats
    stats_out     = SAMTOOLS_STATS(aligned_out)

    // Quantification - Extract just the BAM paths and collect into one list
    bams_ch = aligned_out.map{ it -> it[1] }.collect()
    feature_counts = FEATURECOUNTS(bams_ch, params.annotation)

    // MultiQC - Collect all relevant report files
    multiqc_input = Channel.empty()
        .mix(fastqc_out.collect())
        .mix(stats_out.collect())
        .mix(feature_counts.collect())

    MULTIQC(multiqc_input.collect())
}
