/*
 * Copyright (C) 2017 Jelmer Ypma. All Rights Reserved.
 * This code is published under the L-GPL.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published 
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *   
 * File:   nloptrApi.h
 * Author: Jelmer Ypma
 * Date:   3 October 2017
 *
 * This file provides an API for calling internal NLopt code from C within
 * R packages. The C functions that are registered in init_nloptr.c can be
 * accessed by external R packages.
 * 
 * 03/10/2017: Initial version.
 */


#ifndef __NLOPTRAPI_H__
#define __NLOPTRAPI_H__

#include <R_ext/Rdynload.h>
#include <R.h>
#include <Rinternals.h>

#include "nlopt.h"

NLOPT_EXTERN(void) nlopt_version(int *major, int *minor, int *bugfix)
{
  static void(*fun)(int *, int *, int *) = NULL;
  if (fun == NULL) fun = (void(*)(int *, int *, int *)) R_GetCCallable("nloptr","nlopt_version");
  fun(major, minor, major);
}

#endif /* __NLOPTRAPI_H__ */
