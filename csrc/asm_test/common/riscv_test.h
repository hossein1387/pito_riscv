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
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	lui	a0,%hi(.test_name);	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	addi	a0,a0,%lo(.test_name);	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	lui	a2,0x10000000>>12;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
.prname_next:				\
	lb	a1,0(a0);		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	beq	a1,zero,.prname_done;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	sw	a1,0(a2);		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	addi	a0,a0,1;		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	jal	zero,.prname_next;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
.test_name:				\
	.ascii TEST_FUNC_TXT;		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	.byte 0x00;			\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	.balign 4, 0;			\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
.prname_done:				\
	addi	a1,zero,'.';		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	sw	a1,0(a2);		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	sw	a1,0(a2); \
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\

#define RVTEST_PASS			\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	lui	a0,0x10000000>>12;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	addi	a1,zero,'O';		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	addi	a2,zero,'K';		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	addi	a3,zero,'\n';		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	sw	a1,0(a0);		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	sw	a2,0(a0);		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	sw	a3,0(a0);		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	jal	zero,TEST_FUNC_RET; \
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\

#define RVTEST_FAIL			\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	lui	a0,0x10000000>>12;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	addi	a1,zero,'E';		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	addi	a2,zero,'R';		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	addi	a3,zero,'O';		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	addi	a4,zero,'\n';		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	sw	a1,0(a0);		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	sw	a2,0(a0);		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	sw	a2,0(a0);		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	sw	a3,0(a0);		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	sw	a2,0(a0);		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	sw	a4,0(a0);		\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	ebreak; \
	nop;	\
	nop;	\
	nop;	\
	nop;	\
	nop;	\

#define RVTEST_CODE_END
#define RVTEST_DATA_BEGIN .balign 4;
#define RVTEST_DATA_END

#endif
