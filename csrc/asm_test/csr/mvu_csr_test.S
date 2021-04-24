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


# TEST_MVU_CSR( 0, mhartid, 0);
# TEST_MVU_CSR( 1, misa, 0);
# csrr t1, mstatus
# csrr t2, misa
# csrr t3, mhartid

TEST_MVU_CSR(2 , mvuwbaseptr , 10);
TEST_MVU_CSR(5 , mvuibaseptr , 10);
TEST_MVU_CSR(6 , mvusbaseptr , 10);
TEST_MVU_CSR(7 , mvubbaseptr , 10);
TEST_MVU_CSR(8 , mvuobaseptr , 10);
TEST_MVU_CSR(9 , mvuwjump_0  , 10);
TEST_MVU_CSR(10, mvuwjump_1  , 10);
TEST_MVU_CSR(11, mvuwjump_2  , 10);
TEST_MVU_CSR(12, mvuwjump_3  , 10);
TEST_MVU_CSR(13, mvuwjump_4  , 10);
TEST_MVU_CSR(14, mvuijump_0  , 10);
TEST_MVU_CSR(15, mvuijump_1  , 10);
TEST_MVU_CSR(16, mvuijump_2  , 10);
TEST_MVU_CSR(17, mvuijump_3  , 10);
TEST_MVU_CSR(18, mvuijump_4  , 10);
TEST_MVU_CSR(19, mvusjump_0  , 10);
TEST_MVU_CSR(20, mvusjump_1  , 10);
TEST_MVU_CSR(21, mvubjump_0  , 10);
TEST_MVU_CSR(22, mvubjump_1  , 10);
TEST_MVU_CSR(23, mvuojump_0  , 10);
TEST_MVU_CSR(24, mvuojump_1  , 10);
TEST_MVU_CSR(25, mvuojump_2  , 10);
TEST_MVU_CSR(26, mvuojump_3  , 10);
TEST_MVU_CSR(27, mvuojump_4  , 10);
TEST_MVU_CSR(28, mvuwlength_1, 10);
TEST_MVU_CSR(29, mvuwlength_2, 10);
TEST_MVU_CSR(30, mvuwlength_3, 10);
TEST_MVU_CSR(31, mvuwlength_4, 10);
TEST_MVU_CSR(32, mvuilength_1, 10);
TEST_MVU_CSR(33, mvuilength_2, 10);
TEST_MVU_CSR(34, mvuilength_3, 10);
TEST_MVU_CSR(35, mvuilength_4, 10);
TEST_MVU_CSR(36, mvuslength_1, 10);
TEST_MVU_CSR(37, mvublength_1, 10);
TEST_MVU_CSR(38, mvuolength_1, 10);
TEST_MVU_CSR(39, mvuolength_2, 10);
TEST_MVU_CSR(40, mvuolength_3, 10);
TEST_MVU_CSR(41, mvuolength_4, 10);
TEST_MVU_CSR(42, mvuprecision, 10);
TEST_MVU_CSR(43, mvustatus   , 10);
TEST_MVU_CSR(44, mvucommand  , 10);
TEST_MVU_CSR(45, mvuquant    , 10);
TEST_MVU_CSR(46, mvuscaler   , 10);
TEST_MVU_CSR(47, mvuconfig1  , 10);

  TEST_PASSFAIL
mvu_csr_test_ret:
    ebreak
    ret

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END


