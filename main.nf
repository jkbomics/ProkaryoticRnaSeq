workflow {

    Channel
        .fromFilePairs(params.reads, flat: true)
        .map { sample_id, r1, r2 -> tuple(sample_id, [r1, r2]) }
        .set { read_pairs }

    FASTQC(read_pairs)

    trimmed = TRIMGALORE(read_pairs)

    aligned = BOWTIE2_ALIGN(trimmed, params.genome)

    SAMTOOLS_STATS(aligned)

    FEATURECOUNTS(aligned.collect(), params.annotation)

    MULTIQC(true)
}

