include { RMARKDOWNNOTEBOOK as RMARKDOWNNOTEBOOK_DEFAULT;
          RMARKDOWNNOTEBOOK as RMARKDOWNNOTEBOOK_RLANG   
          } from './modules/nf-core/rmarkdownnotebook'

workflow {
    ch_rmarkdown = Channel.fromPath("${baseDir}/notebook.Rmd").map { notebook ->
            [ [ id: notebook.baseName ], notebook ]
    }
    ch_input_files = Channel.fromPath("${baseDir}/bin/functions.R")
    RMARKDOWNNOTEBOOK_DEFAULT(ch_rmarkdown, [to_error: true, set_rlang_error: false], ch_input_files)
    RMARKDOWNNOTEBOOK_RLANG(ch_rmarkdown, [to_error: true, set_rlang_error: true], ch_input_files)
}