/*
 * Subworkflow: PREPROCESS
 * Purpose   : Raw FASTQ QC + Adapter trimming + Post-trim QC
 * Tools     : FastQC, Trim Galore
 * Input     : Paired-end FASTQ files
 * Output    : Trimmed FASTQ + QC reports
 */

workflow PREPROCESS {

    take:
        reads_ch   // Channel: tuple(sample_id, [R1, R2])

    main:

        /*
         * Step 1: FastQC on raw reads
         */
        raw_fastqc = FASTQC(reads_ch)

        /*
         * Step 2: Trim adapters and low-quality bases
         */
        trimmed_reads = TRIMGALORE(reads_ch)

        /*
         * Step 3: FastQC on trimmed reads
         */
        trimmed_fastqc = FASTQC(trimmed_reads)

    emit:
        trimmed_reads
        raw_fastqc
        trimmed_fastqc
}