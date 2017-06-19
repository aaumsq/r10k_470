/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  sys_defs.vh                                         //
//                                                                     //
//  Description :  This file has the macro-defines for macros used in  //
//                 the pipeline design.                                //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`ifndef __SYS_DEFS_VH__
`define __SYS_DEFS_VH__

/* Synthesis testing definition, used in DUT module instantiation */

`ifdef  SYNTH_TEST
`define DUT(mod) mod``_svsim
`else
`define DUT(mod) mod
`endif

//////////////////////////////////////////////
//
// Memory/testbench attribute definitions
//
//////////////////////////////////////////////


`define NUM_MEM_TAGS           15

`define MEM_SIZE_IN_BYTES      (64*1024)
`define MEM_64BIT_LINES        (`MEM_SIZE_IN_BYTES/8)

// probably not a good idea to change this second one
`define VIRTUAL_CLOCK_PERIOD   13.0 // Clock period from dc_shell
`define VERILOG_CLOCK_PERIOD   10.0 // Clock period from test bench

`define MEM_LATENCY_IN_CYCLES  (100.0/`VIRTUAL_CLOCK_PERIOD+0.49999)   //TODO:MAY NEED TO FIX
// the 0.49999 is to force ceiling(100/period).  The default behavior for
// float to integer conversion is rounding to nearest

//////////////////////////////////////////////
//
// Error codes
//
//////////////////////////////////////////////

`define NO_ERROR 4'h0
`define HALTED_ON_MEMORY_ERROR 4'h1
`define HALTED_ON_HALT 4'h2
`define HALTED_ON_ILLEGAL 4'h3

//////////////////////////////////////////////
//
// Register Types
//
//////////////////////////////////////////////
typedef logic [4:0] ARCH_REG;
typedef logic [5:0] PHYS_REG;
typedef struct packed {
  PHYS_REG  register;
  logic     ready;
} PHYS_WITH_READY;

typedef logic [63:0]  DATA;
typedef logic [3:0]   B_MASK;
typedef logic [15:0]  PC;
typedef logic [7:0]   IMMEDIATE;
typedef logic [31:0]  INSTRUCTION;
typedef logic [4:0]   ROB_PTR;
typedef logic [2:0]   RS_PTR;
typedef logic [4:0]   FL_PTR;
typedef logic [2:0]   IB_PTR;
typedef logic [1:0]   BS_PTR;
typedef logic [2:0]   SQ_PTR;
typedef logic [2:0]   LQ_PTR;
typedef logic [15:0]  ADDR;


//////////////////////////////////////////////
//
// Datapath control signals
//
//////////////////////////////////////////////

typedef struct packed {
  logic cond_branch, uncond_branch, branch, wr_mem, halt;
} FD_control_t;

`define BTB_SIZE 256
`define BTB_TAG_SIZE 8
typedef logic [`BTB_TAG_SIZE-1:0]  BTB_TAG;
typedef struct packed { 
  logic  valid;
  //BTB_TAG btb_tag;  //not needed for direct mapped
  PC taken_NPC;
} BTBEntry_t;

`define BHT_SIZE 256
`define BHT_TAG_SIZE 8
typedef logic [`BHT_TAG_SIZE-1:0]  BHT_TAG;
typedef struct packed { 
  logic [1:0] counter;
} BHTEntry_t;

typedef struct packed { 
  INSTRUCTION instruction;
  FD_control_t fd_control;
  PC pred_NPC;
  PC not_taken_NPC;
  logic bp_pred_taken;
} IBEntry_t;

typedef struct packed {
  logic [1:0]  opa_select, opb_select, dest_reg; // mux selects
  logic [4:0]  alu_func;
  logic        rd_mem;
  logic        halt;
  logic        noop;
  logic        illegal;
  logic        valid_inst;
  IBEntry_t    ib_data;
} DE_control_t;

typedef struct packed {
  logic	          valid;
  logic[1:0]      fuType;
  DE_control_t    control;
  PHYS_REG        tag;
  PHYS_WITH_READY tagA;
  PHYS_WITH_READY tagB; 
  SQ_PTR          sq_index;
  logic           sq_index_empty;
  
  B_MASK          bmask;
  BS_PTR          bs_ptr;
} RSEntry_t;

typedef enum logic [1:0] {
	FUT_ALU 	= 2'h0,
	FUT_MULT 	= 2'h1,
	FUT_LDST	= 2'h2,
	FUT_BR		= 2'h3
} FU_TYPE;

typedef struct packed {
  DATA      result;
  logic     valid;
  PHYS_REG  tagDest;
  B_MASK    bmask;
} FUBIBREntry_t;

typedef struct packed {
  logic       halt;
  logic       is_store;
  logic       complete;
  PHYS_REG    tag;
  PHYS_REG    tagOld;
} ROBEntry_t;

typedef struct packed { 
  logic valid;
  FL_PTR fl_head;
  ROB_PTR rob_tail;
  SQ_PTR sq_tail;
  logic sq_empty;
  PHYS_WITH_READY[30:0] map; // only 31 big because reg 31 is always mapped to 31
  B_MASK  bmask;
} BSEntry_t;

// 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
// tg tg tg tg tg tg tg tg id id id id OB BO BO BO
//                               OI  0  0    
// 0   0  0  0  0  1  0  0  0  0  0  0  0 (128) = PC
// 0   0  0  0  0  0  1  1  1  1  0  0  0   
//Address = 13 bits
//BO = 3 Bits
//Full idx = 5 Bits (or 1 even/odd, 4 bits for banked idx)
//Tag = 13-3-5 = 5 bits

typedef logic[3:0] MEM_TAG;

typedef logic[7:0] ICACHE_TAG;
typedef logic[4:0] ICACHE_FULL_IDX;
typedef logic[3:0] ICACHE_BANK_IDX;

//12 11 10  9  8  7  6  5  4  3  2  1  0
//tg tg tg tg tg id id id id id BO BO BO
typedef logic[7:0] DCACHE_TAG;
typedef logic[4:0] DCACHE_IDX;
typedef struct packed {
  logic valid, is_load;
  B_MASK bmask;
  ADDR addr;
  MEM_TAG memTag;
  PHYS_REG destTag;
} MSHR_t;

typedef struct packed{
  ADDR addr;
  DATA data;
  logic retired;
} SQEntry_t;

typedef struct packed{
  ADDR addr;
  PHYS_REG tagDest;
  B_MASK bmask;
} LQEntry_t;

//
// Mult Definitions
//

//defines how many stages for the multiplication
`define NUM_STAGE 4
`define BIT_SHIFT (64 / `NUM_STAGE)


//
// ALU opA input mux selects
//
`define ALU_OPA_IS_REGA         2'h0
`define ALU_OPA_IS_MEM_DISP     2'h1
`define ALU_OPA_IS_NPC          2'h2
`define ALU_OPA_IS_NOT3         2'h3

//
// ALU opB input mux selects
//
`define ALU_OPB_IS_REGB         2'h0
`define ALU_OPB_IS_ALU_IMM      2'h1
`define ALU_OPB_IS_BR_DISP      2'h2

//
// Destination register select
//
`define DEST_IS_REGC    2'h0
`define DEST_IS_REGA    2'h1
`define DEST_NONE       2'h2


//
// ALU function code input
// probably want to leave these alone
//
`define ALU_ADDQ        5'h00
`define ALU_SUBQ        5'h01
`define ALU_AND         5'h02
`define ALU_BIC         5'h03
`define ALU_BIS         5'h04
`define ALU_ORNOT       5'h05
`define ALU_XOR         5'h06
`define ALU_EQV         5'h07
`define ALU_SRL         5'h08
`define ALU_SLL         5'h09
`define ALU_SRA         5'h0a
`define ALU_MULQ        5'h0b
`define ALU_CMPEQ       5'h0c
`define ALU_CMPLT       5'h0d
`define ALU_CMPLE       5'h0e
`define ALU_CMPULT      5'h0f
`define ALU_CMPULE      5'h10

//////////////////////////////////////////////
//
// Assorted things it is not wise to change
//
//////////////////////////////////////////////

//
// actually, you might have to change this if you change VERILOG_CLOCK_PERIOD
//
`define SD #1


// the Alpha register file zero register, any read of this register always
// returns a zero value, and any write to this register is thrown away
//
`define ZERO_REG        5'd31
`define PHYS_ZERO_REG   6'd31

//
// Memory bus commands control signals
//
`define BUS_NONE       2'h0
`define BUS_LOAD       2'h1
`define BUS_STORE      2'h2

//
// useful boolean single-bit definitions
//
`define FALSE	1'h0
`define TRUE	1'h1

//
// Basic NOOP instruction.  Allows pipline registers to clearly be reset with
// an instruction that does nothing instead of Zero which is really a PAL_INST
//
`define NOOP_INST 32'h47ff041f

//
// top level opcodes, used by the IF stage to decode Alpha instructions
//
`define PAL_INST	6'h00
`define LDA_INST	6'h08
`define LDAH_INST	6'h09
`define LDBU_INST	6'h0a
`define LDQ_U_INST	6'h0b
`define LDWU_INST	6'h0c
`define STW_INST	6'h0d
`define STB_INST	6'h0e
`define STQ_U_INST	6'h0f
`define INTA_GRP	6'h10
`define INTL_GRP	6'h11
`define INTS_GRP	6'h12
`define INTM_GRP	6'h13
`define ITFP_GRP	6'h14	// unimplemented
`define FLTV_GRP	6'h15	// unimplemented
`define FLTI_GRP	6'h16	// unimplemented
`define FLTL_GRP	6'h17	// unimplemented
`define MISC_GRP	6'h18
`define JSR_GRP		6'h1a
`define FTPI_GRP	6'h1c
`define LDF_INST	6'h20
`define LDG_INST	6'h21
`define LDS_INST	6'h22
`define LDT_INST	6'h23
`define STF_INST	6'h24
`define STG_INST	6'h25
`define STS_INST	6'h26
`define STT_INST	6'h27
`define LDL_INST	6'h28
`define LDQ_INST	6'h29
`define LDL_L_INST	6'h2a
`define LDQ_L_INST	6'h2b
`define STL_INST	6'h2c
`define STQ_INST	6'h2d
`define STL_C_INST	6'h2e
`define STQ_C_INST	6'h2f
`define BR_INST		6'h30
`define FBEQ_INST	6'h31
`define FBLT_INST	6'h32
`define FBLE_INST	6'h33
`define BSR_INST	6'h34
`define FBNE_INST	6'h35
`define FBGE_INST	6'h36
`define FBGT_INST	6'h37
`define BLBC_INST	6'h38
`define BEQ_INST	6'h39
`define BLT_INST	6'h3a
`define BLE_INST	6'h3b
`define BLBS_INST	6'h3c
`define BNE_INST	6'h3d
`define BGE_INST	6'h3e
`define BGT_INST	6'h3f

// PALcode opcodes
`define PAL_HALT  26'h555
`define PAL_WHAMI 26'h3c

// INTA (10.xx) opcodes
`define ADDL_INST	7'h00
`define S4ADDL_INST	7'h02
`define SUBL_INST	7'h09
`define S4SUBL_INST	7'h0b
`define CMPBGE_INST	7'h0f
`define S8ADDL_INST	7'h12
`define S8SUBL_INST	7'h1b
`define CMPULT_INST	7'h1d
`define ADDQ_INST	7'h20
`define S4ADDQ_INST	7'h22
`define SUBQ_INST	7'h29
`define S4SUBQ_INST	7'h2b
`define CMPEQ_INST	7'h2d
`define S8ADDQ_INST	7'h32
`define S8SUBQ_INST	7'h3b
`define CMPULE_INST	7'h3d
`define ADDLV_INST	7'h40
`define SUBLV_INST	7'h49
`define CMPLT_INST	7'h4d
`define ADDQV_INST	7'h60
`define SUBQV_INST	7'h69
`define CMPLE_INST	7'h6d

// INTL (11.xx) opcodes
`define AND_INST	7'h00
`define BIC_INST	7'h08
`define CMOVLBS_INST	7'h14
`define CMOVLBC_INST	7'h16
`define BIS_INST	7'h20
`define CMOVEQ_INST	7'h24
`define CMOVNE_INST	7'h26
`define ORNOT_INST	7'h28
`define XOR_INST	7'h40
`define CMOVLT_INST	7'h44
`define CMOVGE_INST	7'h46
`define EQV_INST	7'h48
`define AMASK_INST	7'h61
`define CMOVLE_INST	7'h64
`define CMOVGT_INST	7'h66
`define IMPLVER_INST	7'h6c

// INTS (12.xx) opcodes
`define MSKBL_INST	7'h02
`define EXTBL_INST	7'h06
`define INSBL_INST	7'h0b
`define MSKWL_INST	7'h12
`define EXTWL_INST	7'h16
`define INSWL_INST	7'h1b
`define MSKLL_INST	7'h22
`define EXTLL_INST	7'h26
`define INSLL_INST	7'h2b
`define ZAP_INST	7'h30
`define ZAPNOT_INST	7'h31
`define MSKQL_INST	7'h32
`define SRL_INST	7'h34
`define EXTQL_INST	7'h36
`define SLL_INST	7'h39
`define INSQL_INST	7'h3b
`define SRA_INST	7'h3c
`define MSKWH_INST	7'h52
`define INSWH_INST	7'h57
`define EXTWH_INST	7'h5a
`define MSKLH_INST	7'h62
`define INSLH_INST	7'h67
`define EXTLH_INST	7'h6a
`define MSKQH_INST	7'h72
`define INSQH_INST	7'h77
`define EXTQH_INST	7'h7a

// INTM (13.xx) opcodes
`define MULL_INST	7'h00
`define MULQ_INST	7'h20
`define UMULH_INST	7'h30
`define MULLV_INST	7'h40
`define MULQV_INST	7'h60

// MISC (18.xx) opcodes
`define TRAPB_INST	16'h0000
`define EXCB_INST	16'h0400
`define MB_INST		16'h4000
`define WMB_INST	16'h4400
`define FETCH_INST	16'h8000
`define FETCH_M_INST	16'ha000
`define RPCC_INST	16'hc000
`define RC_INST		16'he000
`define ECB_INST	16'he800
`define RS_INST		16'hf000
`define WH64_INST	16'hf800

// JSR (1a.xx) opcodes
`define JMP_INST	2'h0
`define JSR_INST	2'h1
`define RET_INST	2'h2
`define JSR_CO_INST	2'h3

`endif
