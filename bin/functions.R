throw_error <- function(to_error) {
    func(to_error)
}
func <- function(to_error) {
    if (to_error) stop('ERROR')
}