process FASTQC {
  tag "$sample_id"

  input:
  tuple val(sample_id), path(reads)

  output:
  path "*.html"
  path "*.zip"

  script:
  """
  fastqc ${reads} --threads ${task.cpus}
  """
}