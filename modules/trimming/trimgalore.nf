process TRIMGALORE {
  tag "$sample_id"

  input:
  tuple val(sample_id), path(reads)

  output:
  tuple val(sample_id), path("*_val_*.fq.gz")

  script:
  """
  trim_galore --paired ${reads[0]} ${reads[1]} --cores ${task.cpus}
  """
}