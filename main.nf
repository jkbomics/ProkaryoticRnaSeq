workflow {
    read_pairs = Channel
        .fromFilePairs(params.reads, flat: true)
        .map { it -> [ it[0], [it[1], it[2]] ] } 

    FASTQC(read_pairs)
    trimmed = TRIMGALORE(read_pairs)
    aligned = BOWTIE2_ALIGN(trimmed, params.genome)
    SAMTOOLS_STATS(aligned)

    FEATURECOUNTS(aligned.collect(), params.annotation)

    MULTIQC(true)
}


