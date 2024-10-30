## Demo of improving the trace back message when rendering R Markdown notebooks

```sh
nextflow run main.nf -profile docker
```

`.command.out` & `.command.err` files from the work dir of failed job can be improved by adding the following code at the top of the R Markdown file:

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
 1. └─global::throw_error(params$to_error)
 2.   └─global::func(to_error)
 3.     └─base::stop("ERROR")
```