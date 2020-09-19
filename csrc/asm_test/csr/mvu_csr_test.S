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

RVTEST_RV32U
RVTEST_CODE_BEGIN


TEST_MVU_CSR( 0, mhartid, 0);
TEST_MVU_CSR( 1, misa, 0);
# csrr t1, mstatus
# csrr t2, misa
# csrr t3, mhartid

TEST_MVU_CSR(2 , mvu_precision ,  2 );
TEST_MVU_CSR(5 , mvu_wstride_0 , -4 );
TEST_MVU_CSR(6 , mvu_wstride_1 ,  2 );
TEST_MVU_CSR(7 , mvu_wstride_2 ,  0 );
TEST_MVU_CSR(8 , mvu_istride_0 , -4 );
TEST_MVU_CSR(9 , mvu_istride_1 ,  0 );
TEST_MVU_CSR(10, mvu_istride_2 , -4 );
TEST_MVU_CSR(11, mvu_ostride_0 ,  0 );
TEST_MVU_CSR(12, mvu_ostride_1 ,  0 );
TEST_MVU_CSR(13, mvu_ostride_2 ,  0 );
TEST_MVU_CSR(14, mvu_wlength_0 ,  2 );
TEST_MVU_CSR(15, mvu_wlength_1 ,  3 );
TEST_MVU_CSR(16, mvu_wlength_2 ,  2 );
TEST_MVU_CSR(17, mvu_ilength_0 ,  2 );
TEST_MVU_CSR(18, mvu_ilength_1 ,  0 );
TEST_MVU_CSR(19, mvu_ilength_2 ,  0 );
TEST_MVU_CSR(20, mvu_olength_0 ,  2 );
TEST_MVU_CSR(21, mvu_olength_1 ,  0 );
TEST_MVU_CSR(22, mvu_olength_2 ,  0 );
TEST_MVU_CSR(23, mvu_command   , 36 );

  TEST_PASSFAIL
mvu_csr_test_ret:
    ebreak
    ret

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END


