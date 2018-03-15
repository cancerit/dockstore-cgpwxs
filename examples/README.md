# Example parameters

An example json file exists for the various combinations of sequence input file (and index).

For each `examples/<tool>/<params>.json` file there is a corresponding folder named
`expected/<tool>/<params>/` containing the expected file listing for the result archive.

e.g.

* JSON: `examples/cgpwxs/bam_bai.json`
  * Generates archive: `result_WXS_bam_bai.tar.gz`
* Unpacked archive can be compared to: `expected/cgpwxs/bam_bai`

See [`expected/README.md`](../expected/README.md) for content of that area.
