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

### original err

`.command.err`
```
processing file: notebook.parameterised.Rmd
to_error: TRUE ( logical )
Quitting from lines 21-23 (notebook.parameterised.Rmd) 
Error in func(to_error) : ERROR
Calls: <Anonymous> ... withCallingHandlers -> withVisible -> eval -> eval -> throw_error -> func
Execution halted
```

### original out

`.command.out`
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

### improved err

`.command.err`
```
processing file: notebook.parameterised.Rmd
to_error: TRUE ( logical )
Quitting from lines 21-23 (notebook.parameterised.Rmd) 
Error in func(to_error) : ERROR
Calls: <Anonymous> ... withCallingHandlers -> withVisible -> eval -> eval -> throw_error -> func
Warning message:
In sink() : no sink to remove
```

### improved out

`.command.out`
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

## versions matter??

The [desired helpful traceback](#improved-out) is shown when using the default container from nf-core rmarkdownnotebook, which has the following versions:

```
R: 4.1.0
rmarkdown: 2.9
knitr: 1.33
rlang: 0.4.11
```

However, when using newer versions of these packages:
```
R: 4.4.1
rmarkdown: 2.28
knitr: 1.48
rlang: 1.1.4
```

a more verbose and unhelpful message is shown:

### verbose out

`.command.out`
```
1/4        
2/4 [setup]
3/4        
4/4 [error]
     ▆
  1. ├─rmarkdown::render(...)
  2. │ └─knitr::knit(knit_input, knit_output, envir = envir, quiet = quiet)
  3. │   └─knitr:::process_file(text, output)
  4. │     ├─xfun:::handle_error(...)
  5. │     ├─base::withCallingHandlers(...)
  6. │     └─knitr:::process_group(group)
  7. │       └─knitr:::call_block(x)
  8. │         └─knitr:::block_exec(params)
  9. │           └─knitr:::eng_r(options)
 10. │             ├─knitr:::in_input_dir(...)
 11. │             │ └─knitr:::in_dir(input_dir(), expr)
 12. │             └─knitr (local) evaluate(...)
 13. │               └─evaluate::evaluate(...)
 14. │                 └─base::withRestarts(...)
 15. │                   └─base (local) withRestartList(expr, restarts)
 16. │                     └─base (local) withOneRestart(withRestartList(expr, restarts[-nr]), restarts[[nr]])
 17. │                       └─base (local) docall(restart$handler, restartArgs)
 18. │                         ├─base::do.call("fun", lapply(args, enquote))
 19. │                         └─evaluate (local) fun(base::quote(`<smplErrr>`))
 20. │                           └─base::signalCondition(cnd)
 21. └─knitr (local) `<fn>`(`<smplErrr>`)
 22.   └─rlang::entrace(e)
 23.     └─rlang::cnd_signal(entraced)
 24.       └─rlang:::signal_abort(cnd)
 25.         └─base::stop(fallback)
```

This also occurs without nextflow as long as the newer versions are installed, just calling rmarkdown from a terminal:

`R -e 'rmarkdown::render("notebook.Rmd")'`
```
R version 4.4.1 (2024-06-14) -- "Race for Your Life"
Copyright (C) 2024 The R Foundation for Statistical Computing
Platform: aarch64-apple-darwin20.0.0

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

  Natural language support but running in an English locale

R is a collaborative project with many contributors.
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.

> rmarkdown::render("notebook.Rmd")


processing file: notebook.Rmd
  |..............................................................| 100% [error]Error in `func()`:
! ERROR
Backtrace:
  1. rmarkdown::render("notebook.Rmd")
  2. knitr::knit(knit_input, knit_output, envir = envir, quiet = quiet)
  3. knitr:::process_file(text, output)
  6. knitr:::process_group(group)
  7. knitr:::call_block(x)
     ...
 14. base::withRestarts(...)
 15. base (local) withRestartList(expr, restarts)
 16. base (local) withOneRestart(withRestartList(expr, restarts[-nr]), restarts[[nr]])
 17. base (local) docall(restart$handler, restartArgs)
 19. evaluate (local) fun(base::quote(`<smplErrr>`))
     ▆
  1. ├─rmarkdown::render("notebook.Rmd")
  2. │ └─knitr::knit(knit_input, knit_output, envir = envir, quiet = quiet)
  3. │   └─knitr:::process_file(text, output)
  4. │     ├─xfun:::handle_error(...)
  5. │     ├─base::withCallingHandlers(...)
  6. │     └─knitr:::process_group(group)
  7. │       └─knitr:::call_block(x)
  8. │         └─knitr:::block_exec(params)
  9. │           └─knitr:::eng_r(options)
 10. │             ├─knitr:::in_input_dir(...)
 11. │             │ └─knitr:::in_dir(input_dir(), expr)
 12. │             └─knitr (local) evaluate(...)
 13. │               └─evaluate::evaluate(...)
 14. │                 └─base::withRestarts(...)
 15. │                   └─base (local) withRestartList(expr, restarts)
 16. │                     └─base (local) withOneRestart(withRestartList(expr, restarts[-nr]), restarts[[nr]])
 17. │                       └─base (local) docall(restart$handler, restartArgs)
 18. │                         ├─base::do.call("fun", lapply(args, enquote))
 19. │                         └─evaluate (local) fun(base::quote(`<smplErrr>`))
 20. │                           └─base::signalCondition(cnd)
 21. └─knitr (local) `<fn>`(`<smplErrr>`)
 22.   └─rlang::entrace(e)
 23.     └─rlang::cnd_signal(entraced)
 24.       └─rlang:::signal_abort(cnd)
 25.         └─base::stop(fallback)

Quitting from lines 21-23 [error] (notebook.Rmd)
                                                                                                  
> 
> 
```

## see also

- stack overflow question: <https://stackoverflow.com/questions/79143394/improving-the-r-traceback-when-rendering-r-markdown-non-interactively>
- issue in Adv R: <https://github.com/hadley/adv-r/issues/1792>
- bsky thread: <https://bsky.app/profile/kelly.sova.cool/post/3l7sqn6y4xm2y>
