process FEATURECOUNTS {
  input:
  path bam_files
  path annotation

  output:
  path "gene_counts.txt"

  script:
  """
  featureCounts \
    -a ${annotation} \
    -o gene_counts.txt \
    -T ${task.cpus} \
    -g ID \
    -t gene \
    ${bam_files}
  """
}