include { RMARKDOWNNOTEBOOK as RMARKDOWNNOTEBOOK_ERROR;
          RMARKDOWNNOTEBOOK as RMARKDOWNNOTEBOOK_PASS   
          } from './modules/nf-core/rmarkdownnotebook/main'

workflow {
    ch_rmarkdown = Channel.fromPath("${baseDir}/notebook.Rmd").map { notebook ->
            [ [ id: notebook.baseName ], notebook ]
    }
    ch_input_files = Channel.fromPath("${baseDir}/bin/functions.R")
    RMARKDOWNNOTEBOOK_PASS(ch_rmarkdown, [to_error: false], ch_input_files)
    RMARKDOWNNOTEBOOK_ERROR(ch_rmarkdown, [to_error: true], ch_input_files)
}