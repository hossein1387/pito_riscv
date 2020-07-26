# See LICENSE for license details.

#*****************************************************************************
# mvu_csr.S
#-----------------------------------------------------------------------------
#
# Test csr instruction.
#

#include "pito_def.h"
#include "riscv_test.h"
#include "test_macros.h"

# RVTEST_RV32U
# RVTEST_CODE_BEGIN

	TEST_PASSFAIL

matmul_ret:
	ebreak
	ret

# RVTEST_CODE_END

#   .data
# RVTEST_DATA_BEGIN

#   TEST_DATA

# RVTEST_DATA_END

