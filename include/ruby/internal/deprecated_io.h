#ifndef RBIMPL_DEPRECATED_IO_H                           /*-*-C++-*-vi:se ft=cpp:*/
#define RBIMPL_DEPRECATED_IO_H
/**
 * @file
 * @author     Ruby developers <ruby-core@ruby-lang.org>
 * @copyright  This  file  is   a  part  of  the   programming  language  Ruby.
 *             Permission  is hereby  granted,  to  either redistribute  and/or
 *             modify this file, provided that  the conditions mentioned in the
 *             file COPYING are met.  Consult the file for details.
 * @warning    Symbols   prefixed  with   either  `RBIMPL`   or  `rbimpl`   are
 *             implementation details.   Don't take  them as canon.  They could
 *             rapidly appear then vanish.  The name (path) of this header file
 *             is also an  implementation detail.  Do not expect  it to persist
 *             at the place it is now.  Developers are free to move it anywhere
 *             anytime at will.
 * @note       To  ruby-core:  remember  that   this  header  can  be  possibly
 *             recursively included  from extension  libraries written  in C++.
 *             Do not  expect for  instance `__VA_ARGS__` is  always available.
 *             We assume C99  for ruby itself but we don't  assume languages of
 *             extension libraries. They could be written in C++98.
 * @brief      Deprecated functions related to IO, with separate file used to
 *             avoid circular dependencies.
 */

RBIMPL_SYMBOL_EXPORT_BEGIN()

//RBIMPL_ATTR_DEPRECATED(("use rb_io_maybe_wait_readable"))
int rb_io_wait_readable(int fd);

//RBIMPL_ATTR_DEPRECATED(("use rb_io_maybe_wait_writable"))
int rb_io_wait_writable(int fd);

//RBIMPL_ATTR_DEPRECATED(("use rb_io_wait"))
int rb_wait_for_single_fd(int fd, int events, struct timeval *tv);

RBIMPL_SYMBOL_EXPORT_END()

#endif /* RBIMPL_DEPRECATED_IO_H */
