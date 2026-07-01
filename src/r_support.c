#include <R.h>
#include <Rinternals.h>
#include <stdio.h>
#include <stdarg.h>

void nlopt_abort(void) {
    error("NLopt internal error (abort called)");
}

void nlopt_exit(int status) {
    error("NLopt internal error (exit called with status %d)", status);
}

int nlopt_printf(const char *format, ...) {
    va_list ap;
    va_start(ap, format);
    Rvprintf(format, ap);
    va_end(ap);
    return 0;
}

int nlopt_fprintf(void *stream, const char *format, ...) {
    va_list ap;
    int ret = 0;
    va_start(ap, format);
    if (stream == (void*)2) { // stderr
        REvprintf(format, ap);
    } else if (stream == (void*)1) { // stdout
        Rvprintf(format, ap);
    } else {
        ret = vfprintf((FILE*)stream, format, ap);
    }
    va_end(ap);
    return ret;
}

int nlopt_putchar(int c) {
    Rprintf("%c", c);
    return c;
}

int nlopt_puts(const char *s) {
    Rprintf("%s\n", s);
    return 0;
}
