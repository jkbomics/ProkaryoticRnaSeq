process SAMTOOLS_STATS {
  input:
  tuple val(sample_id), path(bam)

  output:
  path "${sample_id}.stats"

  script:
  """
  samtools stats ${bam} > ${sample_id}.stats
  """
}