workflow PREPROCESS {
    take:
    read_pairs_ch // Expecting [val(sample_id), [path(read1), path(read2)]]

    main:
    FASTQC(read_pairs_ch)
    TRIMGALORE(read_pairs_ch)

    emit:
    trimmed = TRIMGALORE.out
}
