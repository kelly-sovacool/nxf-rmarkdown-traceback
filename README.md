## Demo of improving the trace back message when rendering R Markdown notebooks

```sh
nextflow run main.nf -profile docker
```

`.command.out` & `.command.err` files from the work dir of failed job can be improved by adding the following code to the Rscript just before calling `rmarkdown::render`:

```r
options(rlang_trace_top_env = rlang::current_env())
options(error = function() {
  sink()
  print(rlang::trace_back(bottom = sys.frame(-1)), simplify = "none")
})
```

(source: [Advanced R chapter on debugging](https://adv-r.hadley.nz/debugging.html#rmarkdown))

## original stdout/err files

### `.command.err`

```
processing file: notebook.parameterised.Rmd
to_error: TRUE ( logical )
Quitting from lines 21-23 (notebook.parameterised.Rmd) 
Error in func(to_error) : ERROR
Calls: <Anonymous> ... withCallingHandlers -> withVisible -> eval -> eval -> throw_error -> func
Execution halted
```

### `.command.out`

```r
  |                                                                            
  |                                                                      |   0%
  |                                                                            
  |..................                                                    |  25%
  ordinary text without R code
  |                                                                            
  |...................................                                   |  50%
label: setup
  |                                                                            
  |....................................................                  |  75%
  ordinary text without R code
  |                                                                            
  |......................................................................| 100%
label: error

```

## traceback with improved error option

### `.command.err`

```
processing file: notebook.parameterised.Rmd
to_error: TRUE ( logical )
Quitting from lines 21-23 (notebook.parameterised.Rmd) 
Error in func(to_error) : ERROR
Calls: <Anonymous> ... withCallingHandlers -> withVisible -> eval -> eval -> throw_error -> func
Warning message:
In sink() : no sink to remove
```

### `.command.out`

```
  |                                                                            
  |                                                                      |   0%
  |                                                                            
  |..................                                                    |  25%
  ordinary text without R code
  |                                                                            
  |...................................                                   |  50%
label: setup
  |                                                                            
  |....................................................                  |  75%
  ordinary text without R code
  |                                                                            
  |......................................................................| 100%
label: error
     █
  1. └─rmarkdown::render(...)
  2.   └─knitr::knit(knit_input, knit_output, envir = envir, quiet = quiet)
  3.     └─knitr:::process_file(text, output)
  4.       ├─base::withCallingHandlers(...)
  5.       ├─knitr:::process_group(group)
  6.       └─knitr:::process_group.block(group)
  7.         └─knitr:::call_block(x)
  8.           └─knitr:::block_exec(params)
  9.             └─knitr:::eng_r(options)
 10.               ├─knitr:::in_dir(...)
 11.               └─knitr:::evaluate(...)
 12.                 └─evaluate::evaluate(...)
 13.                   └─evaluate:::evaluate_call(...)
 14.                     ├─evaluate:::timing_fn(...)
 15.                     ├─base:::handle(...)
 16.                     ├─base::withCallingHandlers(...)
 17.                     ├─base::withVisible(eval(expr, envir, enclos))
 18.                     └─base::eval(expr, envir, enclos)
 19.                       └─base::eval(expr, envir, enclos)
 20.                         └─global::throw_error(params$to_error)
 21.                           └─global::func(to_error)
 22.                             └─base::stop("ERROR")
```