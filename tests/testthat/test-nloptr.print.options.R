# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-nloptr.print.options
# Author: Avraham Adler
# Date:   7 February 2023
#
# Test code in "nloptr.print.options" function that is not tested elsewhere.
#
# Changelog:
#

# Classic case where snapshot is warranted so long as function does not change.
test_that("Complicated message output from nloptr.print.options.", {
  expect_snapshot(nloptr.print.options())
  expect_snapshot(nloptr.print.options(opts.show = "check_derivatives"))
})
