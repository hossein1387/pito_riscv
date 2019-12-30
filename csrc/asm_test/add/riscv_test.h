#ifndef _ENV_PICORV32_TEST_H
#define _ENV_PICORV32_TEST_H

#ifndef TEST_FUNC_NAME
#  define TEST_FUNC_NAME mytest
#  define TEST_FUNC_TXT "mytest"
#  define TEST_FUNC_RET mytest_ret
#endif

#define RVTEST_RV32U
#define TESTNUM x28

#define RVTEST_CODE_BEGIN		\
	.text;				\
	.global TEST_FUNC_NAME;		\
	.global TEST_FUNC_RET;		\
TEST_FUNC_NAME:				\
	lui	a0,%hi(.test_name);	\
	TEST_INSERT_NOPS_5;\
	addi	a0,a0,%lo(.test_name);	\
	TEST_INSERT_NOPS_5;\
	lui	a2,0x10000000>>12;	\
	TEST_INSERT_NOPS_5;\
.prname_next:				\
	lb	a1,0(a0);		\
	TEST_INSERT_NOPS_5;\
	beq	a1,zero,.prname_done;	\
	TEST_INSERT_NOPS_5;\
	sw	a1,0(a2);		\
	TEST_INSERT_NOPS_5;\
	addi	a0,a0,1;		\
	TEST_INSERT_NOPS_5;\
	jal	zero,.prname_next;	\
	TEST_INSERT_NOPS_5;\
.test_name:				\
	.ascii TEST_FUNC_TXT;		\
	.byte 0x00;			\
	.balign 8, 0;			\
	TEST_INSERT_NOPS_5;\
.prname_done:				\
	addi	a1,zero,'.';		\
	TEST_INSERT_NOPS_5;\
	sw	a1,0(a2);		\
	TEST_INSERT_NOPS_5;\
	sw	a1,0(a2);\
	TEST_INSERT_NOPS_5;

#define RVTEST_PASS			\
	lui	a0,0x10000000>>12;	\
	TEST_INSERT_NOPS_5;\
	addi	a1,zero,'O';		\
	TEST_INSERT_NOPS_5;\
	addi	a2,zero,'K';		\
	TEST_INSERT_NOPS_5;\
	addi	a3,zero,'\n';		\
	TEST_INSERT_NOPS_5;\
	sw	a1,0(a0);		\
	TEST_INSERT_NOPS_5;\
	sw	a2,0(a0);		\
	TEST_INSERT_NOPS_5;\
	sw	a3,0(a0);		\
	TEST_INSERT_NOPS_5;\
	ebreak;\
	jal	zero,TEST_FUNC_RET;

#define RVTEST_FAIL			\
	lui	a0,0x10000000>>12;	\
	TEST_INSERT_NOPS_5;\
	addi	a1,zero,'E';		\
	TEST_INSERT_NOPS_5;\
	addi	a2,zero,'R';		\
	TEST_INSERT_NOPS_5;\
	addi	a3,zero,'O';		\
	TEST_INSERT_NOPS_5;\
	addi	a4,zero,'\n';		\
	TEST_INSERT_NOPS_5;\
	sw	a1,0(a0);		\
	TEST_INSERT_NOPS_5;\
	sw	a2,0(a0);		\
	TEST_INSERT_NOPS_5;\
	sw	a2,0(a0);		\
	TEST_INSERT_NOPS_5;\
	sw	a3,0(a0);		\
	TEST_INSERT_NOPS_5;\
	sw	a2,0(a0);		\
	TEST_INSERT_NOPS_5;\
	sw	a4,0(a0);		\
	TEST_INSERT_NOPS_5;\
	ebreak;\

#define RVTEST_CODE_END
#define RVTEST_DATA_BEGIN .balign 4;
#define RVTEST_DATA_END

#endif
