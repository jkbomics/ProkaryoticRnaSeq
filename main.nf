workflow {

    Channel
        .fromFilePairs(params.reads)
        .set { read_pairs }

    FASTQC(read_pairs)

    trimmed = TRIMGALORE(read_pairs)

    aligned = BOWTIE2_ALIGN(trimmed, params.genome)

    SAMTOOLS_STATS(aligned)

    FEATURECOUNTS(aligned.collect(), params.annotation)

    MULTIQC(true)
}
