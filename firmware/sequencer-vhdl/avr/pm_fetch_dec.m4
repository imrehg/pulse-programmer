dnl-*-VHDL-*-
-- Instruction fetch and decoder
--  PM_FETCH_DEC(internal module) for AVR core
--	Version 2.28
--  Designed by Ruslan Lepetenok 14.11.2001
--	Modified 02.12.2002
--  Modification:
--  Registered ramre/ramwe outputs
--  cpu_busy logic modified(affects RCALL/ICALL/CALL instruction interract with interrupt)

  unit_([pm_fetch_dec], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
use seqlib.avr.all;
],[dnl -- Generics ------------------------------------------------------------

],[dnl -- Ports ---------------------------------------------------------------
  -- EXTERNAL INTERFACES OF THE CORE
  clk      : in  std_logic;
  clk_en   : in  std_logic;
  sclr     : in  std_logic;
  nrst     : in  std_logic;
  cpuwait  : in  std_logic;
  -- PROGRAM MEMORY PORTS
  pc       : out std_logic_vector (15 downto 0);
  inst     : in  std_logic_vector (15 downto 0);
  -- I/O REGISTERS PORTS
  adr      : out std_logic_vector (5 downto 0);
  iore     : out std_logic;
  iowe     : out std_logic;
  -- DATA MEMORY PORTS
  ramadr   : out std_logic_vector (15 downto 0);
  ramre    : out std_logic;
  ramwe    : out std_logic;
  dbusin   : in  std_logic_vector (7 downto 0);
  dbusout  : out std_logic_vector (7 downto 0);
  -- INTERRUPTS PORT
  irqlines : in  std_logic_vector (22 downto 0);
  irqack   : out std_logic;
  irqackad : out std_logic_vector(4 downto 0);
  -- END OF THE CORE INTERFACES

-------------------------------------------------------------------------------
-- INTERFACES TO THE OTHER BLOCKS

-------------------------------------------------------------------------------
  -- INTERFACES TO THE ALU
  alu_data_r_in       : out std_logic_vector(7 downto 0);
  alu_data_d_in       : out std_logic_vector(7 downto 0);

  -- OPERATION SIGNALS INPUTS
  idc_add_out         : out std_logic;
  idc_adc_out         : out std_logic;
  idc_adiw_out        : out std_logic;
  idc_sub_out         : out std_logic;
  idc_subi_out        : out std_logic;
  idc_sbc_out         : out std_logic;
  idc_sbci_out        : out std_logic;
  idc_sbiw_out        : out std_logic;

  adiw_st_out         : out std_logic;
  sbiw_st_out         : out std_logic;

  idc_and_out         : out std_logic;
  idc_andi_out        : out std_logic;
  idc_or_out          : out std_logic;
  idc_ori_out         : out std_logic;
  idc_eor_out         : out std_logic;              
  idc_com_out         : out std_logic;              
  idc_neg_out         : out std_logic;

  idc_inc_out         : out std_logic;
  idc_dec_out         : out std_logic;

  idc_cp_out          : out std_logic;              
  idc_cpc_out         : out std_logic;
  idc_cpi_out         : out std_logic;
  idc_cpse_out        : out std_logic;                            

  idc_lsr_out         : out std_logic;
  idc_ror_out         : out std_logic;
  idc_asr_out         : out std_logic;
  idc_swap_out        : out std_logic;

-- DATA OUTPUT
  alu_data_out        : in std_logic_vector(7 downto 0);

-- FLAGS OUTPUT
  alu_c_flag_out      : in std_logic;
  alu_z_flag_out      : in std_logic;
  alu_n_flag_out      : in std_logic;
  alu_v_flag_out      : in std_logic;
  alu_s_flag_out      : in std_logic;
  alu_h_flag_out      : in std_logic;

-------------------------------------------------------------------------------
-- INTERFACES TO THE GENERAL PURPOSE REGISTER FILE
  reg_rd_in   : out std_logic_vector  (7 downto 0);
  reg_rd_out  : in  std_logic_vector  (7 downto 0);
  reg_rd_adr  : out std_logic_vector  (4 downto 0);
  reg_rr_out  : in  std_logic_vector  (7 downto 0);
  reg_rr_adr  : out std_logic_vector  (4 downto 0);
  reg_rd_wr   : out std_logic;

  post_inc    : out std_logic;
  pre_dec     : out std_logic;
  reg_h_wr    : out std_logic;
  reg_h_out   : in  std_logic_vector (15 downto 0);
  reg_h_adr   : out std_logic_vector (2 downto 0);    -- x,y,z
  -- OUTPUT OF R31:R30 FOR LPM/ELPM/IJMP INSTRUCTIONS
  reg_z_out   : in  std_logic_vector (15 downto 0);

-------------------------------------------------------------------------------
-- INTERFACES TO THE INPUT/OUTPUT REGISTER FILE
  sreg_fl_in    : out std_logic_vector(7 downto 0); -- ????        
  sreg_out      : in  std_logic_vector(7 downto 0);  -- ????       

  --FLAGS WRITE ENABLE SIGNALS       
  sreg_fl_wr_en : out std_logic_vector(7 downto 0);

  spl_out       : in  std_logic_vector(7 downto 0);         
  sph_out       : in  std_logic_vector(7 downto 0);         
  -- DIRECTION OF CHANGING OF STACK POINTER SPH:SPL 0->UP(+) 1->DOWN(-)
  sp_ndown_up   : out std_logic;
  -- WRITE ENABLE(COUNT ENABLE) FOR SPH AND SPL REGISTERS
  sp_en         : out std_logic;
  
  rampz_out     : in std_logic_vector(7 downto 0);

-------------------------------------------------------------------------------
-- INTERFACES TO THE BIT PROCESSOR

  -- BIT NUMBER FOR CBI/SBI/BLD/BST/SBRS/SBRC/SBIC/SBIS INSTRUCTIONS
  bit_num_r_io  : out std_logic_vector (2 downto 0);
  -- SBI/CBI OUT        
  bitpr_io_out  : in std_logic_vector(7 downto 0);
  -- NUMBER (0..7) OF BRANCH CONDITION FOR BRBS/BRBC INSTRUCTION
  branch        : out  std_logic_vector (2 downto 0);
  -- BCLR/BSET/BST(T-FLAG ONLY)             
  bit_pr_sreg_out : in std_logic_vector(7 downto 0);
  -- BIT NUMBER FOR BCLR/BSET INSTRUCTIONS
  sreg_bit_num    : out std_logic_vector(2 downto 0);
  -- BLD OUT (T FLAG)
  bld_op_out      : in std_logic_vector(7 downto 0);
  -- OUTPUT OF SBIC/SBIS/SBRS/SBRC
  bit_test_op_out : in std_logic;

  -- OPERATION SIGNALS INPUTS

  -- INSTRUCTIONS AND STATES

  idc_sbi_out     : out std_logic;
  sbi_st_out      : out std_logic;
  idc_cbi_out     : out std_logic;
  cbi_st_out      : out std_logic;

  idc_bld_out     : out std_logic;
  idc_bst_out     : out std_logic;
  idc_bset_out    : out std_logic;
  idc_bclr_out    : out std_logic;

  idc_sbic_out    : out std_logic;
  idc_sbis_out    : out std_logic;
              
  idc_sbrs_out    : out std_logic;
  idc_sbrc_out    : out std_logic;
              
  idc_brbs_out    : out std_logic;
  idc_brbc_out    : out std_logic;

  idc_reti_out    : out std_logic;

-------------------------------------------------------------------------------
-- END OF INTERFACES TO THE OTHER BLOCKS
],[dnl -- Declarations --------------------------------------------------------
-- COPIES OF OUTPUTS
   -- INPUT OF THE ADDRESS REGISTER
   signal ramadr_reg_in  : std_logic_vector(15 downto 0) :=(others =>'0');
   signal ramadr_reg_en  : std_logic;                     -- ADRESS REGISTER CLOCK ENABLE SIGNAL

   signal irqack_int     : std_logic;
   signal irqackad_int   : std_logic_vector(irqackad'range) :=(others =>'0');

-- ####################################################
-- INTERNAL SIGNALS
-- ####################################################

-- NEW SIGNALS
   -- CALL/JMP/STS/LDS INSTRUCTION INDICATOR
   signal   two_word_inst       : std_logic := '0';

   signal   ram_adr_int         : std_logic_vector (15 downto 0):=(others =>'0');
   -- LD/LDS/LDD/ST/STS/STD ADDRESSING GENERAL PURPOSE REGISTER
   -- (R0-R31) 0x00..0x19
   constant const_ram_to_reg    : std_logic_vector := "00000000000";
   -- LD/LDS/LDD/ST/STS/STD ADDRESSING GENERAL I/O PORT 0x20 0x3F 
   constant const_ram_to_io_a   : std_logic_vector := "00000000001";
   -- LD/LDS/LDD/ST/STS/STD ADDRESSING GENERAL I/O PORT 0x20 0x3F 
   constant const_ram_to_io_b   : std_logic_vector := "00000000010";

-- LD/LDD/ST/STD SIGNALS
   signal adiw_sbiw_encoder_out : std_logic_vector (4 downto 0):=(others =>'0');
   signal adiw_sbiw_encoder_mux_out : std_logic_vector (4 downto 0):=(others =>'0');


-- PROGRAM COUNTER SIGNALS
   signal program_counter_tmp : std_logic_vector (15 downto 0):=(others =>'0'); -- TO STORE PC DURING LPM/ELPM INSTRUCTIONS
   signal program_counter     : std_logic_vector (15 downto 0):=(others =>'0');
   signal program_counter_in  : std_logic_vector (15 downto 0):=(others =>'0');
   signal program_counter_high_fr  : std_logic_vector (7 downto 0):=(others =>'0'); -- TO STORE PC FOR CALL,IRQ,RCALL,ICALL

   signal pc_low       : std_logic_vector (7 downto 0):=(others =>'0');
   signal pc_high      : std_logic_vector (7 downto 0):=(others =>'0');


   signal pc_low_en       : std_logic;
   signal pc_high_en      : std_logic;

   signal offset_brbx     : std_logic_vector (15 downto 0):=(others =>'0');    -- OFFSET FOR BRCS/BRCC   INSTRUCTION  !!CHECKED
   signal offset_rxx      : std_logic_vector (15 downto 0):=(others =>'0');    -- OFFSET FOR RJMP/RCALL  INSTRUCTION  !!CHECKED

   signal pa15_pm         : std_logic; -- ADDRESS LINE 15 FOR LPM/ELPM INSTRUCTIONS ('0' FOR LPM,RAMPZ(0) FOR ELPM) 

   signal alu_reg_wr      : std_logic; -- ALU INSTRUCTIONS PRODUCING WRITE TO THE GENERAL PURPOSE REGISTER FILE	

-- DATA MEMORY,GENERAL PURPOSE REGISTERS AND I/O REGISTERS LOGIC

--! IMPORTANT NOTICE : OPERATIONS WHICH USE STACK POINTER (SPH:SPL) CAN NOT ACCCSESS GENERAL
-- PURPOSE REGISTER FILE AND INPUT/OUTPUT REGISTER FILE !
-- THESE OPERATIONS ARE : RCALL/ICALL/CALL/RET/RETI/PUSH/POP INSTRUCTIONS  AND INTERRUPT 

   signal reg_file_adr_space  : std_logic; -- ACCSESS TO THE REGISTER FILE
   signal io_file_adr_space   : std_logic; -- ACCSESS TO THE I/O FILE

-- STATE MACHINES SIGNALS
   signal irq_start      : std_logic := '0';

   signal nirq_st0       : std_logic := '0';
   signal irq_st1        : std_logic := '0';
   signal irq_st2        : std_logic := '0';
   signal irq_st3        : std_logic := '0';

   signal ncall_st0      : std_logic := '0';
   signal call_st1       : std_logic := '0';
   signal call_st2       : std_logic := '0';
   signal call_st3       : std_logic := '0';

   signal nrcall_st0     : std_logic := '0';
   signal rcall_st1      : std_logic := '0';
   signal rcall_st2      : std_logic := '0';

   signal nicall_st0     : std_logic := '0';
   signal icall_st1      : std_logic := '0';
   signal icall_st2      : std_logic := '0';

   signal njmp_st0       : std_logic := '0';
   signal jmp_st1        : std_logic := '0';
   signal jmp_st2        : std_logic := '0';

   signal ijmp_st        : std_logic := '0';

   signal rjmp_st        : std_logic := '0';

   signal nret_st0       : std_logic := '0';
   signal ret_st1        : std_logic := '0';
   signal ret_st2        : std_logic := '0';
   signal ret_st3        : std_logic := '0';

   signal nreti_st0      : std_logic := '0';
   signal reti_st1       : std_logic := '0';
   signal reti_st2       : std_logic := '0';
   signal reti_st3       : std_logic := '0';

   signal brxx_st        : std_logic := '0';  -- BRANCHES

   signal adiw_st        : std_logic := '0';
   signal sbiw_st        : std_logic := '0';

   signal nskip_inst_st0 : std_logic := '0';
   signal skip_inst_st1  : std_logic := '0';
   signal skip_inst_st2  : std_logic := '0';  -- ALL SKIP INSTRUCTIONS SBRS/SBRC/SBIS/SBIC/CPSE 

   signal skip_inst_start  : std_logic := '0';

   signal nlpm_st0       : std_logic := '0';
   signal lpm_st1        : std_logic := '0';
   signal lpm_st2        : std_logic := '0';

   signal nelpm_st0      : std_logic := '0';
   signal elpm_st1       : std_logic := '0';
   signal elpm_st2       : std_logic := '0';

   signal nsts_st0       : std_logic := '0';
   signal sts_st1        : std_logic := '0';
   signal sts_st2        : std_logic := '0';

   signal nlds_st0       : std_logic := '0';
   signal lds_st1        : std_logic := '0';
   signal lds_st2        : std_logic := '0';

   signal st_st          : std_logic := '0';
   signal ld_st          : std_logic := '0';

   signal sbi_st         : std_logic := '0';
   signal cbi_st         : std_logic := '0';

   signal push_st        : std_logic := '0';
   signal pop_st	      : std_logic := '0';

-- INTERNAL STATE MACHINES
   signal nop_insert_st  : std_logic := '0';
   signal cpu_busy       : std_logic :='0';

-- INTERNAL COPIES OF OUTPUTS
   signal pc_int              : std_logic_vector (15 downto 0):=(others =>'0');
   signal adr_int             : std_logic_vector (5 downto 0):=(others =>'0');
   signal iore_int 		   : std_logic := '0';
   signal iowe_int            : std_logic := '0';
   signal ramadr_int          : std_logic_vector (15 downto 0):=(others =>'0');
   signal ramre_int           : std_logic := '0';
   signal ramwe_int           : std_logic := '0';
   signal dbusout_int         : std_logic_vector (7 downto 0):=(others =>'0');

-- COMMAND REGISTER
   signal instruction_reg      : std_logic_vector (15 downto 0):=(others =>'0'); -- OUTPUT OF THE INSTRUCTION REGISTER
   signal instruction_code_reg : std_logic_vector (15 downto 0):=(others =>'0'); -- OUTPUT OF THE INSTRUCTION REGISTER WITH NOP INSERTION
   signal instruction_reg_ena  : std_logic := '0';                               -- CLOCK ENABLE


-- IRQ INTERNAL LOGIC
   signal irq_int : std_logic;
   signal irq_vector_adr : std_logic_vector(15 downto 0):=(others =>'0');
   signal irq_pr_encoder : std_logic_vector(6 downto 0):=(others =>'0');

-- INTERRUPT RELATING REGISTERS
   signal pc_for_interrupt : std_logic_vector(15 downto 0):=(others =>'0'); 

-- DATA EXTRACTOR SIGNALS
   signal dex_dat8_immed  : std_logic_vector (7 downto 0):=(others =>'0');  -- IMMEDIATE CONSTANT (DATA) -> ANDI,ORI,SUBI,SBCI,CPI,LDI
   signal dex_dat6_immed  : std_logic_vector (5 downto 0):=(others =>'0');  -- IMMEDIATE CONSTANT (DATA) -> ADIW,SBIW
   signal dex_adr12mem_s  : std_logic_vector (11 downto 0):=(others =>'0'); -- RELATIVE ADDRESS (SIGNED) -> RCALL,RJMP
   signal dex_adr6port    : std_logic_vector (5 downto 0):=(others =>'0');  -- I/O PORT ADDRESS -> IN,OUT
   signal dex_adr5port    : std_logic_vector (4 downto 0):=(others =>'0');  -- I/O PORT ADDRESS -> CBI,SBI,SBIC,SBIS
   signal dex_adr_disp    : std_logic_vector (5 downto 0):=(others =>'0');  -- DISPLACEMENT FO ADDDRESS -> STD,LDD
   signal dex_condition   : std_logic_vector (2 downto 0):=(others =>'0');  -- CONDITION -> BRBC,BRBS
   signal dex_bitnum_sreg : std_logic_vector (2 downto 0):=(others =>'0');  -- NUMBER OF BIT IN SREG -> BCLR,BSET
   signal dex_adrreg_r    : std_logic_vector (4 downto 0):=(others =>'0');  -- SOURCE REGISTER ADDRESS -> .......
   signal dex_adrreg_d    : std_logic_vector (4 downto 0):=(others =>'0');  -- DESTINATION REGISTER ADDRESS -> ......
   signal dex_bitop_bitnum : std_logic_vector(2 downto 0):=(others =>'0');  -- NUMBER OF BIT FOR BIT ORIENTEDE OPERATION -> BST/BLD+SBI/CBI+SBIC/SBIS+SBRC/SBRS !! CHECKED
   signal dex_brxx_offset : std_logic_vector (6 downto 0):=(others =>'0');  -- RELATIVE ADDRESS (SIGNED) -> BRBC,BRBS !! CHECKED
   signal dex_adiw_sbiw_reg_adr  : std_logic_vector (1 downto 0):=(others =>'0');  -- ADDRESS OF THE LOW REGISTER FOR ADIW/SBIW INSTRUCTIONS

   signal dex_adrreg_d_latched : std_logic_vector (4 downto 0):=(others =>'0');   --  STORE ADDRESS OF DESTINATION REGISTER FOR LDS/STS/POP INSTRUCTIONS
   signal gp_reg_tmp           : std_logic_vector (7 downto 0):=(others =>'0');   --  STORE DATA FROM THE REGISTERS FOR STS,ST INSTRUCTIONS
   signal cbi_sbi_io_adr_tmp   : std_logic_vector (4 downto 0):=(others =>'0');   --  STORE ADDRESS OF I/O PORT FOR CBI/SBI INSTRUCTION
   signal cbi_sbi_bit_num_tmp  : std_logic_vector (2 downto 0):=(others =>'0');   --  STORE ADDRESS OF I/O PORT FOR CBI/SBI INSTRUCTION

-- INSTRUCTIONS DECODER SIGNALS

   signal idc_adc     : std_logic; -- INSTRUCTION ADC
   signal idc_add     : std_logic; -- INSTRUCTION ADD
   signal idc_adiw    : std_logic; -- INSTRUCTION ADIW
   signal idc_and     : std_logic; -- INSTRUCTION AND
   signal idc_andi    : std_logic; -- INSTRUCTION ANDI
   signal idc_asr     : std_logic; -- INSTRUCTION ASR

   signal idc_bclr    : std_logic; -- INSTRUCTION BCLR
   signal idc_bld     : std_logic; -- INSTRUCTION BLD
   signal idc_brbc    : std_logic; -- INSTRUCTION BRBC
   signal idc_brbs    : std_logic; -- INSTRUCTION BRBS
   signal idc_bset    : std_logic; -- INSTRUCTION BSET
   signal idc_bst     : std_logic; -- INSTRUCTION BST

   signal idc_call    : std_logic; -- INSTRUCTION CALL
   signal idc_cbi     : std_logic; -- INSTRUCTION CBI
   signal idc_com     : std_logic; -- INSTRUCTION COM
   signal idc_cp      : std_logic; -- INSTRUCTION CP
   signal idc_cpc     : std_logic; -- INSTRUCTION CPC
   signal idc_cpi     : std_logic; -- INSTRUCTION CPI
   signal idc_cpse    : std_logic; -- INSTRUCTION CPSE

   signal idc_dec     : std_logic; -- INSTRUCTION DEC

   signal idc_elpm    : std_logic; -- INSTRUCTION ELPM
   signal idc_eor     : std_logic; -- INSTRUCTION EOR

   signal idc_icall   : std_logic; -- INSTRUCTION ICALL
   signal idc_ijmp    : std_logic; -- INSTRUCTION IJMP

   signal idc_in      : std_logic; -- INSTRUCTION IN
   signal idc_inc     : std_logic; -- INSTRUCTION INC

   signal idc_jmp     : std_logic; -- INSTRUCTION JMP

   signal idc_ld_x    : std_logic; -- INSTRUCTION LD Rx,X ; LD Rx,X+ ;LD Rx,-X
   signal idc_ld_y    : std_logic; -- INSTRUCTION LD Rx,Y ; LD Rx,Y+ ;LD Rx,-Y
   signal idc_ldd_y   : std_logic; -- INSTRUCTION LDD Rx,Y+q
   signal idc_ld_z    : std_logic; -- INSTRUCTION LD Rx,Z ; LD Rx,Z+ ;LD Rx,-Z
   signal idc_ldd_z   : std_logic; -- INSTRUCTION LDD Rx,Z+q

   signal idc_ldi     : std_logic; -- INSTRUCTION LDI
   signal idc_lds     : std_logic; -- INSTRUCTION LDS
   signal idc_lpm     : std_logic; -- INSTRUCTION LPM
   signal idc_lsr     : std_logic; -- INSTRUCTION LSR

   signal idc_mov     : std_logic; -- INSTRUCTION MOV
   signal idc_mul     : std_logic; -- INSTRUCTION MUL

   signal idc_neg     : std_logic; -- INSTRUCTION NEG
   signal idc_nop     : std_logic; -- INSTRUCTION NOP

   signal idc_or      : std_logic; -- INSTRUCTION OR
   signal idc_ori     : std_logic; -- INSTRUCTION ORI
   signal idc_out     : std_logic; -- INSTRUCTION OUT

   signal idc_pop     : std_logic; -- INSTRUCTION POP
   signal idc_push    : std_logic; -- INSTRUCTION PUSH

   signal idc_rcall   : std_logic; -- INSTRUCTION RCALL
   signal idc_ret     : std_logic; -- INSTRUCTION RET
   signal idc_reti    : std_logic; -- INSTRUCTION RETI
   signal idc_rjmp    : std_logic; -- INSTRUCTION RJMP
   signal idc_ror     : std_logic; -- INSTRUCTION ROR

   signal idc_sbc     : std_logic; -- INSTRUCTION SBC
   signal idc_sbci    : std_logic; -- INSTRUCTION SBCI
   signal idc_sbi     : std_logic; -- INSTRUCTION SBI
   signal idc_sbic    : std_logic; -- INSTRUCTION SBIC
   signal idc_sbis    : std_logic; -- INSTRUCTION SBIS
   signal idc_sbiw    : std_logic; -- INSTRUCTION SBIW
   signal idc_sbrc    : std_logic; -- INSTRUCTION SBRC
   signal idc_sbrs    : std_logic; -- INSTRUCTION SBRS
   signal idc_sleep   : std_logic; -- INSTRUCTION SLEEP

   signal idc_st_x    : std_logic; -- INSTRUCTION LD X,Rx ; LD X+,Rx ;LD -X,Rx
   signal idc_st_y    : std_logic; -- INSTRUCTION LD Y,Rx ; LD Y+,Rx ;LD -Y,Rx
   signal idc_std_y   : std_logic; -- INSTRUCTION LDD Y+q,Rx
   signal idc_st_z    : std_logic; -- INSTRUCTION LD Z,Rx ; LD Z+,Rx ;LD -Z,Rx
   signal idc_std_z   : std_logic; -- INSTRUCTION LDD Z+q,Rx

   signal idc_sts     : std_logic; -- INSTRUCTION STS
   signal idc_sub     : std_logic; -- INSTRUCTION SUB
   signal idc_subi    : std_logic; -- INSTRUCTION SUBI
   signal idc_swap    : std_logic; -- INSTRUCTION SWAP

   signal idc_wdr     : std_logic; -- INSTRUCTION WDR


-- ADDITIONAL SIGNALS
   signal idc_psinc   :  std_logic; -- POST INCREMENT FLAG FOR LD,ST INSTRUCTIONS
   signal idc_prdec   :  std_logic; -- PRE DECREMENT  FLAG FOR LD,ST INSTRUCTIONS

-- ##################################################

-- SREG FLAGS WRITE ENABLE SIGNALS

   alias sreg_c_wr_en  : std_logic is sreg_fl_wr_en(0);
   alias sreg_z_wr_en  : std_logic is sreg_fl_wr_en(1);
   alias sreg_n_wr_en  : std_logic is sreg_fl_wr_en(2);
   alias sreg_v_wr_en  : std_logic is sreg_fl_wr_en(3);
   alias sreg_s_wr_en  : std_logic is sreg_fl_wr_en(4);
   alias sreg_h_wr_en  : std_logic is sreg_fl_wr_en(5);
   alias sreg_t_wr_en  : std_logic is sreg_fl_wr_en(6);
   alias sreg_i_wr_en  : std_logic is sreg_fl_wr_en(7);

   signal sreg_bop_wr_en : std_logic_vector (7 downto 0);                

   signal sreg_adr_eq  : std_logic;
],[dnl -- Body ----------------------------------------------------------------


   -- INSTRUCTION FETCH
   instruction_reg_ena <= '1'; -- FOR TEST

   instruction_fetch : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       instruction_reg <= (others => '0');
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         instruction_reg <= (others => '0');
       elsif (clk_en = '1') then
         if instruction_reg_ena='1' then
           instruction_reg <= inst;
         end if;
       end if;
     end if;
   end process;

-- TWO WORDS INSTRUCTION DETECTOR (CONNECTED DIRECTLY TO THE INSTRUCTION REGISTER)
   two_word_inst <= '1' when 
   ((instruction_reg(15 downto 9)&instruction_reg(3 downto 1)="1001010111") or    -- CALL
    (instruction_reg(15 downto 9)&instruction_reg(3 downto 1)="1001010110")) or   -- JMP
   (instruction_reg(15 downto 9)&instruction_reg(3 downto 0) = "10010000000") or -- LDS
   (instruction_reg(15 downto 9)&instruction_reg(3 downto 0) = "10010010000")    -- STS
   else '0';  -- TO DETECT CALL/JMP/LDS/STS INSTRUCTIONS FOR SBRS/SBRC/SBIS/SBIC/CPSE
   
-- DATA EXTRACTOR (CONNECTED DIRECTLY TO THE INSTRUCTION REGISTER)
   dex_dat8_immed <= instruction_reg(11 downto 8) & instruction_reg(3 downto 0);
   dex_dat6_immed <= instruction_reg(7 downto 6) & instruction_reg(3 downto 0);
   dex_adr12mem_s <= instruction_reg(11 downto 0); 
   dex_adr6port <= instruction_reg(10 downto 9) & instruction_reg(3 downto 0);    
   dex_adr5port <= instruction_reg(7 downto 3);  
   dex_adr_disp <= instruction_reg(13) & instruction_reg(11 downto 10) & instruction_reg(2 downto 0);      
   dex_condition <= instruction_reg(2 downto 0);   
   dex_bitop_bitnum <= instruction_reg(2 downto 0);      -- NUMBER(POSITION) OF TESTING BIT IN SBRC/SBRS/SBIC/SBIS INSTRUCTION
   dex_bitnum_sreg <= instruction_reg(6 downto 4);    
   dex_adrreg_r  <=  instruction_reg(9) & instruction_reg(3 downto 0);
   dex_adrreg_d  <= instruction_reg(8 downto 4);     
   dex_brxx_offset <= instruction_reg(9 downto 3);       -- OFFSET FOR BRBC/BRBS     
   dex_adiw_sbiw_reg_adr <= instruction_reg(5 downto 4); -- ADDRESS OF THE LOW REGISTER FOR ADIW/SBIW INSTRUCTIONS
--dex_adrindreg <= instruction_reg(3 downto 2);     

-- LATCH Rd ADDDRESS FOR LDS/STS/POP INSTRUCTIONS
   latcht_rd_adr : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       dex_adrreg_d_latched <= (others => '0');
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         dex_adrreg_d_latched <= (others => '0');
       elsif (clk_en = '1') then
         if ((idc_ld_x or idc_ld_y or idc_ldd_y or idc_ld_z or idc_ldd_z) or
             idc_sts or 
             (idc_st_x  or idc_st_y or idc_std_y or idc_st_z or idc_std_z) or
             idc_lds or idc_pop) = '1' then
           dex_adrreg_d_latched <= dex_adrreg_d;
         end if;
       end if;
     end if;
   end process;
-- +++++++++++++++++++++++++++++++++++++++++++++++++


-- R24:R25/R26:R27/R28:R29/R30:R31 ADIW/SBIW  ADDRESS CONTROL LOGIC
   adiw_sbiw_encoder_out <= "11"&dex_adiw_sbiw_reg_adr&'0';

   adiw_sbiw_high_reg_adr : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       adiw_sbiw_encoder_mux_out <= (others => '0');
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         adiw_sbiw_encoder_mux_out <= (others => '0');
       elsif (clk_en = '1') then
         adiw_sbiw_encoder_mux_out <= adiw_sbiw_encoder_out +1;
       end if;
     end if;
   end process;
   
-- ##########################

-- NOP INSERT STATE MACHINE
   instruction_code_reg <= instruction_reg when nop_insert_st='0' else (others => '0');
   
--nop_insertion:process(clk,nrst, clk_en)
--begin
--if nrst='0' then                       -- RESET
--nop_insert_st <='0';
--elsif (clk='1' and clk'event) then       -- CLOCK
--end if;
--end process;


   nop_insert_st <= adiw_st or sbiw_st or cbi_st or sbi_st or rjmp_st or
   ijmp_st or pop_st or push_st or brxx_st or ld_st or st_st or
   ncall_st0 or nirq_st0 or nret_st0 or nreti_st0 or
   nlpm_st0 or njmp_st0 or nrcall_st0 or nicall_st0 or
   nsts_st0 or nlds_st0 or nskip_inst_st0;
   
-- INSTRUCTION DECODER (CONNECTED AFTER NOP INSERTION LOGIC)

   -- 000111XXXXXXXXXX
   idc_adc  <= '1' when instruction_code_reg(15 downto 10) = "000111" else '0';
   -- 000011XXXXXXXXXX
   idc_add  <= '1' when instruction_code_reg(15 downto 10) = "000011" else '0';

   -- 10010110XXXXXXXX
   idc_adiw <= '1' when instruction_code_reg(15 downto 8) = "10010110" else '0';

   -- 001000XXXXXXXXXX
   idc_and  <= '1' when instruction_code_reg(15 downto 10) = "001000" else '0';

   -- 0111XXXXXXXXXXXX
   idc_andi <= '1' when instruction_code_reg(15 downto 12) = "0111" else '0';

   -- 1001010XXXXX0101
   idc_asr  <= '1' when instruction_code_reg(15 downto 9) &
   instruction_code_reg(3 downto 0) = "10010100101"
   else '0';

   -- 100101001XXX1000
   idc_bclr <= '1' when instruction_code_reg(15 downto 7) &
   instruction_code_reg(3 downto 0) = "1001010011000"
   else '0';

   -- 1111100XXXXX0XXX
   idc_bld  <= '1' when instruction_code_reg(15 downto 9) &
   instruction_code_reg(3) = "11111000" else '0';

   idc_brbc <= '1' when instruction_code_reg(15 downto 10) = "111101" else '0'; -- 111101XXXXXXXXXX
   idc_brbs <= '1' when instruction_code_reg(15 downto 10) = "111100" else '0'; -- 111100XXXXXXXXXX

   idc_bset <= '1' when instruction_code_reg(15 downto 7)&instruction_code_reg(3 downto 0) = "1001010001000" else '0'; -- 100101000XXX1000

   idc_bst  <= '1' when instruction_code_reg(15 downto 9) = "1111101" else '0'; -- 1111101XXXXXXXXX

   idc_call <= '1' when instruction_code_reg(15 downto 9) & instruction_code_reg(3 downto 1) = "1001010111" else '0'; -- 1001010XXXXX111X

   idc_cbi  <= '1' when instruction_code_reg(15 downto 8) = "10011000" else '0'; -- 10011000XXXXXXXX

   idc_com  <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010100000" else '0'; -- 1001010XXXXX0000

   idc_cp   <= '1' when instruction_code_reg(15 downto 10) = "000101" else '0'; -- 000101XXXXXXXXXX

   idc_cpc  <= '1' when instruction_code_reg(15 downto 10) = "000001" else '0'; -- 000001XXXXXXXXXX

   idc_cpi  <= '1' when instruction_code_reg(15 downto 12) = "0011" else '0'; -- 0011XXXXXXXXXXXX

   idc_cpse <= '1' when instruction_code_reg(15 downto 10) = "000100" else '0'; -- 000100XXXXXXXXXX

   idc_dec  <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010101010" else '0'; -- 1001010XXXXX1010

   idc_elpm <= '1' when instruction_code_reg = "1001010111011000" else '0'; -- 1001010111011000

   idc_eor  <= '1' when instruction_code_reg(15 downto 10) = "001001" else '0'; -- 001001XXXXXXXXXX

   idc_icall<= '1' when instruction_code_reg(15 downto 8)&instruction_code_reg(3 downto 0) = "100101011001" else '0'; -- 10010101XXXX1001

   idc_ijmp <= '1' when instruction_code_reg(15 downto 8)&instruction_code_reg(3 downto 0) = "100101001001" else '0'; -- 10010100XXXX1001

   idc_in   <= '1' when instruction_code_reg(15 downto 11) = "10110" else '0'; -- 10110XXXXXXXXXXX

   idc_inc  <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010100011" else '0'; -- 1001010XXXXX0011

   idc_jmp  <= '1' when instruction_code_reg(15 downto 9) & instruction_code_reg(3 downto 1) = "1001010110" else '0'; -- 1001010XXXXX110X


-- LD,LDD 
   idc_ld_x <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010001100" or 
   instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010001101"	or
   instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010001110" else '0';
   
   idc_ld_y <= '1' when (instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0)="10010001001" or 
                         instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0)="10010001010") else '0'; 

   idc_ldd_y<= '1' when instruction_code_reg(15 downto 14)&instruction_code_reg(12)&instruction_code_reg(9)&instruction_code_reg(3) = "10001" else '0'; -- 10X0XX0XXXXX1XXX    

   idc_ld_z <= '1' when (instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0)="10010000001" or 
                         instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0)="10010000010") else '0'; 

   idc_ldd_z<= '1' when instruction_code_reg(15 downto 14)&instruction_code_reg(12)&instruction_code_reg(9)&instruction_code_reg(3) = "10000" else '0'; -- 10X0XX0XXXXX0XXX       
-- ######


   idc_ldi <= '1' when instruction_code_reg(15 downto 12) = "1110" else '0'; -- 1110XXXXXXXXXXXX

   idc_lds <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010000000" else '0'; -- 1001000XXXXX0000

   idc_lpm <= '1' when instruction_code_reg = "1001010111001000" else '0'; -- 1001010111001000

   idc_lsr <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010100110" else '0'; -- 1001010XXXXX0110

   idc_mov <= '1' when instruction_code_reg(15 downto 10) = "001011" else '0'; -- 001011XXXXXXXXXX

   idc_mul <= '1' when instruction_code_reg(15 downto 10) = "100111" else '0'; -- 100111XXXXXXXXXX

   idc_neg <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010100001" else '0'; -- 1001010XXXXX0001

   idc_nop <= '1' when instruction_code_reg = "0000000000000000" else '0'; -- 0000000000000000

   idc_or  <= '1' when instruction_code_reg(15 downto 10) = "001010" else '0'; -- 001010XXXXXXXXXX

   idc_ori <= '1' when instruction_code_reg(15 downto 12) = "0110" else '0'; -- 0110XXXXXXXXXXXX 

   idc_out <= '1' when instruction_code_reg(15 downto 11) = "10111" else '0'; -- 10111XXXXXXXXXXX

   idc_pop <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010001111" else '0'; -- 1001000XXXXX1111

   idc_push<= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010011111" else '0'; -- 1001001XXXXX1111

   idc_rcall<= '1' when instruction_code_reg(15 downto 12) = "1101" else '0'; -- 1101XXXXXXXXXXXX

   idc_ret  <= '1' when instruction_code_reg(15 downto 7)&instruction_code_reg(4 downto 0) = "10010101001000" else '0'; -- 100101010XX01000

   idc_reti <= '1' when instruction_code_reg(15 downto 7)&instruction_code_reg(4 downto 0) = "10010101011000" else '0'; -- 100101010XX11000

   idc_rjmp <= '1' when instruction_code_reg(15 downto 12) = "1100" else '0'; -- 1100XXXXXXXXXXXX

   idc_ror  <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010100111" else '0'; -- 1001010XXXXX0111

   idc_sbc  <= '1' when instruction_code_reg(15 downto 10) = "000010" else '0'; -- 000010XXXXXXXXXX

   idc_sbci <= '1' when instruction_code_reg(15 downto 12) = "0100" else '0'; -- 0100XXXXXXXXXXXX

   idc_sbi  <= '1' when instruction_code_reg(15 downto 8) = "10011010" else '0'; -- 10011010XXXXXXXX

   idc_sbic <= '1' when instruction_code_reg(15 downto 8) = "10011001" else '0'; -- 10011001XXXXXXXX

   idc_sbis <= '1' when instruction_code_reg(15 downto 8) = "10011011" else '0'; -- 10011011XXXXXXXX

   idc_sbiw <= '1' when instruction_code_reg(15 downto 8) = "10010111" else '0'; -- 10010111XXXXXXXX

   idc_sbrc <= '1' when instruction_code_reg(15 downto 9) = "1111110" else '0'; -- 1111110XXXXXXXXX

   idc_sbrs <= '1' when instruction_code_reg(15 downto 9) = "1111111" else '0'; -- 1111111XXXXXXXXX

   idc_sleep<= '1' when instruction_code_reg(15 downto 5)&instruction_code_reg(3 downto 0) = "100101011001000" else '0'; -- 10010101100X1000


-- ST,STD
   idc_st_x <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010011100" or 
   instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010011101" or 
   instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010011110" else '0';
   
   idc_st_y <= '1' when (instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0)="10010011001" or 
                         instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0)="10010011010") else '0'; 

   idc_std_y<= '1' when instruction_code_reg(15 downto 14)&instruction_code_reg(12)&instruction_code_reg(9)&instruction_code_reg(3) = "10011" else '0'; -- 10X0XX1XXXXX1XXX    

   idc_st_z <= '1' when (instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0)="10010010001" or 
                         instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0)="10010010010") else '0'; 

   idc_std_z<= '1' when instruction_code_reg(15 downto 14)&instruction_code_reg(12)&instruction_code_reg(9)&instruction_code_reg(3) = "10010" else '0'; -- 10X0XX1XXXXX0XXX 
-- ######

   idc_sts  <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010010000" else '0'; -- 1001001XXXXX0000

   idc_sub  <= '1' when instruction_code_reg(15 downto 10) = "000110" else '0'; -- 000110XXXXXXXXXX

   idc_subi <= '1' when instruction_code_reg(15 downto 12) = "0101" else '0'; -- 0101XXXXXXXXXXXX

   idc_swap <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010100010" else '0'; -- 1001010XXXXX0010

   idc_wdr  <= '1' when instruction_code_reg(15 downto 5)&instruction_code_reg(3 downto 0) = "100101011011000" else '0'; -- 10010101101X1000

-- ADDITIONAL SIGNALS
   idc_psinc <= '1' when (instruction_code_reg(1 downto 0) = "01" and 
                          (idc_st_x or idc_st_y or idc_st_z or idc_ld_x or idc_ld_y or idc_ld_z)='1') else '0';  -- POST INCREMENT FOR LD/ST INSTRUCTIONS

   idc_prdec <= '1' when (instruction_code_reg(1 downto 0)	= "10" and
                          (idc_st_x or idc_st_y or idc_st_z or idc_ld_x or idc_ld_y or idc_ld_z)='1') else '0';  -- PRE DECREMENT FOR LD/ST INSTRUCTIONS 
   
-------------------------------------------------------------------------------
   -- WRITE ENABLE SIGNALS FOR ramadr_reg
   ramadr_reg_en <= idc_ld_x or idc_ld_y or idc_ldd_y or idc_ld_z or
   idc_ldd_z or lds_st1 or    -- LD/LDD/LDS 
   idc_st_x or idc_st_y or idc_std_y or idc_st_z or
   idc_std_z or sts_st1 or    -- ST/STS/STS
   idc_push or idc_pop or idc_rcall or
   (rcall_st1 and not cpuwait) or idc_icall or
   (icall_st1 and not cpuwait) or -- RCALL/ICALL
   -- CALL/IRQ
   call_st1 or  (call_st2 and not cpuwait) or irq_st1 or
   (irq_st2 and not cpuwait) or
   idc_ret or (ret_st1 and not cpuwait ) or idc_reti or
   (reti_st1 and not cpuwait);		  -- RET/RETI  -- ??

   -- RAMADR MUX
   ramadr_reg_in <= sph_out & spl_out when 
   (idc_rcall or (rcall_st1 and not cpuwait) or idc_icall or (icall_st1 and not cpuwait)or  -- RCALL/ICALL
    call_st1  or (call_st2 and not cpuwait) or irq_st1   or (irq_st2 and not cpuwait)  or  -- CALL/IRQ
    idc_push )='1' else 	                                                                  -- PUSH

   (sph_out&spl_out)+1 when (idc_ret or (ret_st1 and not cpuwait)  or idc_reti  or (reti_st1 and not cpuwait) or idc_pop)='1' else  -- RET/RETI/POP

   instruction_reg when (lds_st1 or sts_st1) ='1' else                                             -- LDS/STS
   reg_h_out when (idc_ld_x or idc_ld_y or idc_ld_z or idc_st_x or idc_st_y or idc_st_z)='1' else  -- LD/ST	  
   (reg_h_out + ("000000000"&dex_adr_disp));                                                       -- LDD/STD  
   
   
   -- ADDRESS REGISTER
   ramadr_reg : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then 
       ramadr_int <= (others => '0'); 
    elsif (rising_edge(clk)) then
       if (sclr = '1') then
         ramadr_int <= (others => '0');
       elsif (clk_en = '1') then
         if (ramadr_reg_en='1') then                            -- CLOCK ENABLE
           ramadr_int <= ramadr_reg_in;
         end if;
       end if;
     end if;
   end process;

   ramadr <= ramadr_int;

-- GENERAL PURPOSE REGISTERS ADDRESSING FLAG FOR ST/STD/STS INSTRUCTIONS
   gp_reg_adr : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then 
       reg_file_adr_space <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         reg_file_adr_space <= '0';
       elsif (clk_en = '1') then
         if (ramadr_reg_en='1') then
           if (ramadr_reg_in(15 downto 5)=const_ram_to_reg) then 
             -- ADRESS RANGE 0x0000-0x001F -> REGISTERS (R0-R31)
             reg_file_adr_space <= '1';
           else 
             reg_file_adr_space <= '0';
           end if;
         end if;
       end if;
     end if;
   end process;

-- I/O REGISTERS ADDRESSING FLAG FOR ST/STD/STS INSTRUCTIONS
   io_reg_adr : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       io_file_adr_space <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         io_file_adr_space <= '0';
       elsif (clk_en = '1') then
         if (ramadr_reg_en='1') then                           -- CLOCK ENABLE
           if (ramadr_reg_in(15 downto 5)=const_ram_to_io_a or ramadr_reg_in(15 downto 5)=const_ram_to_io_b) then 
             io_file_adr_space <= '1';                             -- ADRESS RANGE 0x0020-0x005F -> I/O PORTS (0x00-0x3F)
           else 
             io_file_adr_space <= '0';
           end if;
         end if;
       end if;
     end if;
   end process;



-- ##########################################################################################################


-- REGRE/REGWE LOGIC (5 BIT ADDSRESS BUS (INTERNAL ONLY) 32 LOCATIONS (R0-R31))

-- WRITE ENABLE FOR Rd REGISTERS 
   alu_reg_wr <= idc_adc or idc_add or idc_adiw or adiw_st or idc_sub or idc_subi or idc_sbc or idc_sbci or
   idc_sbiw or  sbiw_st or idc_and or idc_andi or idc_or or idc_ori or idc_eor or idc_com or
   idc_neg or idc_inc or idc_dec or idc_lsr or idc_ror or idc_asr or idc_swap;
   

   reg_rd_wr <= idc_in or alu_reg_wr or idc_bld or             -- ALU INSTRUCTIONS + IN/BLD INSRTRUCTION                
   (pop_st or ld_st or lds_st2)or			                    -- POP/LD/LDD/LDS INSTRUCTIONS
   ((st_st or sts_st2) and reg_file_adr_space)or              -- ST/STD/STS INSTRUCTION 	      
   lpm_st2 or idc_ldi or idc_mov;                            -- LPM/LDI/MOV INSTRUCTION
   
   
   reg_rd_adr <= '1'&dex_adrreg_d(3 downto 0) when (idc_subi or idc_sbci or idc_andi or idc_ori or idc_cpi or idc_ldi)='1' else
   "00000" when lpm_st2='1' else 
   adiw_sbiw_encoder_out     when (idc_adiw or idc_sbiw)='1' else
   adiw_sbiw_encoder_mux_out when (adiw_st or sbiw_st)='1' else
   dex_adrreg_d_latched      when (((st_st or sts_st2) and not reg_file_adr_space) or ld_st or lds_st2 or pop_st)='1' else
   ramadr_int(4 downto 0)    when ((st_st or sts_st2) and reg_file_adr_space)='1'else --!!??
   dex_adrreg_d;

   reg_rr_adr <= ramadr_int(4 downto 0) when ((ld_st or lds_st2) and reg_file_adr_space)='1'else --!!??
   dex_adrreg_d_latched   when ((st_st or sts_st2) and reg_file_adr_space)='1'else --!!??
   dex_adrreg_r;		   
   
-- MULTIPLEXER FOR REGISTER FILE Rd INPUT
   reg_rd_in <= dbusin when (idc_in or ((lds_st2 or ld_st)and not reg_file_adr_space) or pop_st)='1' else -- FROM INPUT DATA BUS
   reg_rr_out when ((lds_st2 or ld_st)  and reg_file_adr_space)='1' else
   gp_reg_tmp when ((st_st or sts_st2)  and reg_file_adr_space)='1' else -- ST/STD/STS &  ADDRESS FROM 0 TO 31 (REGISTER FILE)
   bld_op_out when (idc_bld='1')else                                     -- FROM BIT PROCESSOR BLD COMMAND
   reg_rr_out when (idc_mov='1')else                                     -- FOR MOV INSTRUCTION 
   instruction_reg(15 downto 8) when (lpm_st2='1' and reg_z_out(0)='1') else -- LPM/ELPM
   instruction_reg(7 downto 0) when  (lpm_st2='1' and reg_z_out(0)='0') else -- LPM/ELPM
   dex_dat8_immed when idc_ldi='1' else
   alu_data_out;                                               -- FROM ALU DATA OUT

-- IORE/IOWE LOGIC (6 BIT ADDRESS adr[5..0] FOR I/O PORTS(64 LOCATIONS))
   iore_int <= idc_in or idc_sbi or idc_cbi or idc_sbic or idc_sbis or ((ld_st or lds_st2) and io_file_adr_space);   -- IN/SBI/CBI 
   iowe_int <= '1' when ((idc_out or sbi_st or cbi_st) or 
                         ((st_st or sts_st2) and io_file_adr_space))='1' else '0'; -- OUT/SBI/CBI + !! ST/STS/STD


-- adr[5..0] BUS MULTIPLEXER
   adr_int <= dex_adr6port when (idc_in or idc_out) = '1' else                          -- IN/OUT INSTRUCTIONS  
   '0'&dex_adr5port when (idc_cbi or idc_sbi or idc_sbic or idc_sbis) ='1'    else  -- CBI/SBI (READ PHASE) + SBIS/SBIC
   '0'&cbi_sbi_io_adr_tmp when (cbi_st or sbi_st)='1' else	-- CBI/SBI (WRITE PHASE)
   ramadr_int(6)&ramadr_int(4 downto 0);                                                   -- LD/LDS/LDD/ST/STS/STD

-- ramre LOGIC (16 BIT ADDRESS ramadr[15..0] FOR DATA RAM (64*1024-64-32 LOCATIONS))
--ramre_int <= not(reg_file_adr_space or io_file_adr_space) and 
--            (ld_st or lds_st2 or pop_st or                    -- LD/LDD/LDS/POP/
--             ret_st1 or ret_st2 or reti_st1 or reti_st2);     -- RET/RETI

   DataMemoryRead : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       ramre_int <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         ramre_int <= '0';
       elsif (clk_en = '1') then
         
         case ramre_int is
           when '0' =>	
             if  ramadr_reg_in(15 downto 5)/=const_ram_to_io_a and 
               ramadr_reg_in(15 downto 5)/=const_ram_to_io_b and   
               ramadr_reg_in(15 downto 5)/=const_ram_to_reg  and  
               (idc_ld_x or idc_ld_y or idc_ldd_y or idc_ld_z or idc_ldd_z or  -- LD/LDD instruction	
                lds_st1 or                                                     -- LDS instruction	
                idc_pop or                                                     -- POP instruction
                idc_ret or 	                                                -- RET instruction 
                idc_reti)='1' 												    -- RETI instruction 
             then ramre_int <='1';
             end if;
           when '1' =>	
             if ((ld_st or lds_st2 or pop_st or ret_st2 or reti_st2) and
                 (not cpuwait)) = '1' then 
               ramre_int <='0';
             end if;
           when others  =>	null;
         end case;
       end if;
     end if;
   end process;			 
   
-- ramwe LOGIC (16 BIT ADDRESS ramadr[15..0] FOR DATA RAM (64*1024-64-32 LOCATIONS))
--ramwe_int <= not(reg_file_adr_space or io_file_adr_space) and 
--            (st_st or sts_st2 or push_st or rcall_st1 or rcall_st2 or -- ST/STD/STS/PUSH/RCALL
--			                                icall_st1 or icall_st2 or -- ICALL
--			                                call_st2 or call_st3 or   -- CALL
--											irq_st2 or irq_st3);      -- INTERRUPT

   DataMemoryWrite : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       ramwe_int <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         ramwe_int <= '0';
       elsif (clk_en = '1') then
         case ramwe_int is
           when '0' =>	
             if (ramadr_reg_in(15 downto 5) /= const_ram_to_io_a and 
                 ramadr_reg_in(15 downto 5) /= const_ram_to_io_b and   
                 ramadr_reg_in(15 downto 5) /= const_ram_to_reg  and  
                 -- ST/STD instruction	
                 (idc_st_x or idc_st_y or idc_std_y or idc_st_z or idc_std_z or
                  -- STS instruction	
                  sts_st1 or
                  -- PUSH instruction
                  idc_push or
                  -- RCALL instruction
                  idc_rcall or
                  -- ICALL instruction
                  idc_icall or
                  -- CALL instruction
                  call_st1 or
                  -- Interrupt  
                  irq_st1) = '1') then
               ramwe_int <='1';
             end if;
           when '1' =>	
             if (((st_st or sts_st2 or push_st or rcall_st2 or 
                  icall_st2 or call_st3 or irq_st3) and (not cpuwait)) = '1') then
               ramwe_int <='0';
             end if;
           when others  =>	null;
         end case;
       end if;
     end if;
   end process;

-- DBUSOUT MULTIPLEXER
   dbusout_mux_logic: for i in dbusout_int'range generate
     dbusout_int(i) <=
       -- PUSH/ST/STD/STS INSTRUCTIONS
       (reg_rd_out(i) and (idc_push or (idc_st_x or idc_st_y or idc_std_y or
                                        idc_st_z or idc_std_z))) or
       -- NEW
       (gp_reg_tmp(i) and (st_st or sts_st1 or sts_st2)) or
       -- CBI/SBI  INSTRUCTIONS
       (bitpr_io_out(i) and (cbi_st or sbi_st)) or
       -- LOW  PART OF PC
       (program_counter(i) and
        (idc_rcall or idc_icall or call_st1)) or
       -- HIGH PART OF PC
       (program_counter_high_fr(i) and (rcall_st1 or icall_st1 or call_st2)) or
       (pc_for_interrupt(i) and irq_st1) or
       (pc_for_interrupt(i+8) and irq_st2) or
       (reg_rd_out(i) and idc_out); -- OUT
   end generate;

-- ALU CONNECTION

-- ALU Rr INPUT MUX
   alu_data_r_in <= dex_dat8_immed       when (idc_subi or idc_sbci or idc_andi or idc_ori or idc_cpi)='1' else
   "00"&dex_dat6_immed  when (idc_adiw or idc_sbiw) ='1' else
   "00000000"           when (adiw_st or sbiw_st) ='1' else
   reg_rr_out;

-- ALU Rd INPUT
   alu_data_d_in <= reg_rd_out;


-- gp_reg_tmp STORES TEMPREOARY THE VALUE OF SOURCE REGISTER DURING ST/STD/STS INSTRUCTION
   gp_registers_trig : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       gp_reg_tmp <= (others => '0');
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         gp_reg_tmp <= (others => '0');
       elsif (clk_en = '1') then
-- if ((idc_st_x or idc_st_y or idc_std_y or idc_st_z or idc_std_z) or sts_st1)='1' then  -- CLOCK ENABLE
         if ((idc_st_x or idc_st_y or idc_std_y or idc_st_z or idc_std_z) or idc_sts)='1' then  -- CLOCK ENABLE
           gp_reg_tmp <= reg_rd_out;
         end if;
       end if;
     end if;
   end process;

-------------------------------------------------------------------------------
-- PROGRAM COUNTER

   program_counter_high_store : process(clk, nrst, clk_en, sclr)

   begin
     if (nrst = '0') then
       program_counter_high_fr <= (others => '0');
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         program_counter_high_fr <= (others => '0');
       elsif (clk_en = '1') then
         if (idc_rcall or idc_icall or call_st1 or irq_st1) ='1' then
           program_counter_high_fr <= program_counter(15 downto 8);
           -- STORE HIGH BYTE OF THE PROGRAMM COUNTER FOR RCALL/ICALL/CALL
           -- INSTRUCTIONS AND INTERRUPTS   
         end if;
       end if;
     end if;
   end process;

   program_counter_for_lpm_elpm : process(clk, nrst, clk_en, sclr)

   begin
     if (nrst = '0') then
       program_counter_tmp <= (others => '0');
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         program_counter_tmp <= (others => '0');
       elsif (clk_en = '1') then
         if (idc_lpm or idc_elpm) ='1' then
           program_counter_tmp <= program_counter;               
         end if;
       end if;
     end if;
   end process;

   -- '0' WHEN LPM INSTRUCTIONS  RAMPZ(0) WHEN ELPM INSTRUCTION
   pa15_pm <= rampz_out(0) and idc_elpm;

-- OFFSET FOR BRBC/BRBS INSTRUCTIONS +63/-64
   offset_brbx <= "0000000000"&dex_brxx_offset(5 downto 0) when (dex_brxx_offset(6)='0') else -- +
   "1111111111"&dex_brxx_offset(5 downto 0);                                   -- - 

-- OFFSET FOR RJMP/RCALL INSTRUCTIONS +2047/-2048
   offset_rxx <= "00000"&dex_adr12mem_s(10 downto 0) when (dex_adr12mem_s(11)='0') else       -- +
   "11111"&dex_adr12mem_s(10 downto 0);                                          -- -

   program_counter <= pc_high & pc_low;

   program_counter_in <=
     -- BRBC/BRBS                  
     program_counter + offset_brbx when ((idc_brbc or idc_brbs) and
                                         bit_test_op_out) ='1' else
     -- RJMP/RCALL
     program_counter + offset_rxx when (idc_rjmp or idc_rcall)='1' else
     -- IJMP/ICALL
     reg_z_out when (idc_ijmp or idc_icall)='1' else
     -- LPM/ELPM
     pa15_pm&reg_z_out(15 downto 1) when (idc_lpm or idc_elpm) ='1' else
     -- JMP/CALL
     instruction_reg when ((jmp_st1 or call_st1) ='1') else
     -- INTERRUPT      
     "0000000000" & irqackad_int & '0' when irq_st1 ='1' else
   
     -- RET/RETI -> PC HIGH BYTE                  
     dbusin&"00000000"  when (ret_st1 or reti_st1)='1' else
     -- RET/RETI -> PC LOW BYTE                       
     "00000000"&dbusin  when (ret_st2 or reti_st2)='1' else
     -- AFTER LPM/ELPM INSTRUCTION   
     program_counter_tmp when (lpm_st1)='1' else
     program_counter+1;      -- THE MOST USUAL CASE

   pc_low_en <= not (idc_ld_x or idc_ld_y or idc_ld_z or idc_ldd_y or
                     idc_ldd_z or idc_st_x or idc_st_y or idc_st_z or
                     idc_std_y or idc_std_z or
                     sts_st1 or lds_st1 or 
                     idc_adiw or idc_sbiw or
                     idc_push or idc_pop or
                     idc_cbi or idc_sbi or
                     rcall_st1 or icall_st1 or call_st2 or irq_st2 or
                     cpuwait or ret_st1 or reti_st1);

   pc_high_en <= not (idc_ld_x or idc_ld_y or idc_ld_z or idc_ldd_y or idc_ldd_z or
                      idc_st_x or idc_st_y or idc_st_z or idc_std_y or idc_std_z or
                      sts_st1 or lds_st1 or 
                      idc_adiw or idc_sbiw or
                      idc_push or idc_pop or
                      idc_cbi or idc_sbi or
                      rcall_st1 or icall_st1 or call_st2 or irq_st2 or cpuwait or
                      ret_st2 or reti_st2);
   
   program_counter_low : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       pc_low <= (others => '0');
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         pc_low <= (others => '0');
       elsif (clk_en = '1') then
         if (pc_low_en = '1') then
           pc_low <= program_counter_in(7 downto 0);
         end if;
       end if;
     end if;
   end process;

   program_counter_high : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       pc_high <= (others => '0');
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         pc_high <= (others => '0');
       elsif (clk_en = '1') then
         if (pc_high_en ='1') then
           pc_high <= program_counter_in(15 downto 8);
         end if;
       end if;
     end if;
   end process;

   pc <= program_counter;

   program_counter_for_interrupt : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then                                 -- RESET
       pc_for_interrupt <= (others => '0');
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         pc_for_interrupt <= (others => '0');
       elsif (clk_en = '1') then -- CLOCK
         if (irq_start ='1') then                           -- CLOCK ENABLE
           pc_for_interrupt <= program_counter;
         end if;
       end if;
     end if;
   end process;

-- END OF PROGRAM COUNTER 

-- STATE MACHINES

   skip_inst_start <= ((idc_sbrc or idc_sbrs or idc_sbic or idc_sbis) and bit_test_op_out)or
   (idc_cpse and alu_z_flag_out);

   skip_instruction_sm : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       nskip_inst_st0 <= '0';
       skip_inst_st1  <= '0';
       skip_inst_st2  <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         nskip_inst_st0 <= '0';
         skip_inst_st1  <= '0';
         skip_inst_st2  <= '0';
       elsif (clk_en = '1') then
         nskip_inst_st0 <= (not nskip_inst_st0 and skip_inst_start) or 
                           (nskip_inst_st0 and not((skip_inst_st1 and not two_word_inst) or skip_inst_st2));
         skip_inst_st1  <= (not skip_inst_st1 and not nskip_inst_st0 and skip_inst_start);
         skip_inst_st2  <=  not skip_inst_st2 and skip_inst_st1 and two_word_inst;
       end if;
     end if;
   end process;

   alu_state_machines : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       adiw_st <= '0';
       sbiw_st <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         adiw_st <= '0';
         sbiw_st <= '0';
       elsif (clk_en='1') then
         adiw_st <= not adiw_st and idc_adiw;
         sbiw_st <= not sbiw_st and idc_sbiw;
       end if;
     end if;
   end process;


   lpm_state_machine : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       nlpm_st0 <= '0';
       lpm_st1 <= '0';
       lpm_st2 <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         nlpm_st0 <= '0';
         lpm_st1 <= '0';
         lpm_st2 <= '0';
       elsif (clk_en = '1') then       -- CLOCK
         nlpm_st0 <= (not nlpm_st0 and (idc_lpm or idc_elpm)) or (nlpm_st0 and not lpm_st2);
         lpm_st1  <= (not lpm_st1 and not nlpm_st0 and (idc_lpm or idc_elpm)); -- ?? 
         lpm_st2  <=  not lpm_st2 and lpm_st1;
       end if;
     end if;
   end process;

   lds_state_machine : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       nlds_st0 <= '0';
       lds_st1 <= '0';
       lds_st2 <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         nlds_st0 <= '0';
         lds_st1 <= '0';
         lds_st2 <= '0';
       elsif (clk_en = '1') then
         nlds_st0 <= (not nlds_st0 and idc_lds) or (nlds_st0 and not (lds_st2 and not cpuwait));
         lds_st1  <= not lds_st1 and not nlds_st0 and idc_lds;
         lds_st2  <= (not lds_st2 and lds_st1) or (lds_st2 and cpuwait);
       end if;
     end if;
   end process;

   sts_state_machine : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       nsts_st0 <= '0';
       sts_st1 <= '0';
       sts_st2 <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         nsts_st0 <= '0';
         sts_st1 <= '0';
         sts_st2 <= '0';
       elsif (clk_en = '1') then
         nsts_st0 <= (not nsts_st0 and idc_sts) or (nsts_st0 and not (sts_st2 and not cpuwait));
         sts_st1  <=  not sts_st1 and not nsts_st0 and idc_sts;
         sts_st2  <= (not sts_st2 and sts_st1) or (sts_st2 and cpuwait);
       end if;
     end if;
   end process;

   jmp_state_machine : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       njmp_st0 <= '0';
       jmp_st1 <= '0';
       jmp_st2 <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         njmp_st0 <= '0';
         jmp_st1 <= '0';
         jmp_st2 <= '0';
       elsif (clk_en = '1') then
         njmp_st0 <= (not njmp_st0 and idc_jmp) or (njmp_st0 and not jmp_st2);
         jmp_st1  <= not jmp_st1 and not njmp_st0 and idc_jmp; -- ?? 
         jmp_st2  <= not jmp_st2 and jmp_st1;
       end if;
     end if;
   end process;

   rcall_state_machine : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       nrcall_st0 <= '0';
       rcall_st1 <= '0';
       rcall_st2 <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         nrcall_st0 <= '0';
         rcall_st1 <= '0';
         rcall_st2 <= '0';
       elsif (clk_en = '1') then
         nrcall_st0 <= (not nrcall_st0 and idc_rcall) or (nrcall_st0 and not (rcall_st2 and not cpuwait));
         rcall_st1  <= (not rcall_st1 and not nrcall_st0 and idc_rcall) or (rcall_st1 and cpuwait);
         rcall_st2  <= (not rcall_st2 and rcall_st1 and not cpuwait) or (rcall_st2 and cpuwait);
       end if;
     end if;
   end process;

   icall_state_machine : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       nicall_st0 <= '0';
       icall_st1  <= '0';
       icall_st2  <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         nicall_st0 <= '0';
         icall_st1  <= '0';
         icall_st2  <= '0';
       elsif (clk_en = '1') then
         nicall_st0 <= (not nicall_st0 and idc_icall) or (nicall_st0 and not (icall_st2 and not cpuwait));
         icall_st1  <= (not icall_st1 and not nicall_st0 and idc_icall) or (icall_st1 and cpuwait);
         icall_st2  <= (not icall_st2 and icall_st1 and not cpuwait) or (icall_st2 and cpuwait);
       end if;
     end if;
   end process;

   call_state_machine : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       ncall_st0 <= '0';
       call_st1 <= '0';
       call_st2 <= '0';
       call_st3  <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         ncall_st0 <= '0';
         call_st1 <= '0';
         call_st2 <= '0';
         call_st3  <= '0';
       elsif (clk_en = '1') then
         ncall_st0 <= (not ncall_st0 and idc_call) or (ncall_st0 and not( call_st3 and not cpuwait));
         call_st1  <= (not call_st1) and (not ncall_st0) and idc_call;
         call_st2  <= (not call_st2 and call_st1) or (call_st2 and cpuwait);
         call_st3  <= (not call_st3 and call_st2 and not cpuwait) or (call_st3 and cpuwait);
       end if;
     end if;
   end process;

   ret_state_machine : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       nret_st0 <= '0';
       ret_st1 <= '0';
       ret_st2 <= '0';
       ret_st3  <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         nret_st0 <= '0';
         ret_st1 <= '0';
         ret_st2 <= '0';
         ret_st3  <= '0';
       elsif (clk_en = '1') then
         nret_st0 <= (not nret_st0 and idc_ret) or (nret_st0 and not ret_st3);
         ret_st1  <= (not ret_st1 and not nret_st0 and idc_ret) or (ret_st1 and cpuwait);
         ret_st2  <= (not ret_st2 and ret_st1 and not cpuwait) or (ret_st2 and cpuwait) ;
         ret_st3  <= not ret_st3 and ret_st2 and not cpuwait; 
       end if;
     end if;
   end process;

   reti_state_machine : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       nreti_st0 <= '0';
       reti_st1 <= '0';
       reti_st2 <= '0';
       reti_st3  <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         nreti_st0 <= '0';
         reti_st1 <= '0';
         reti_st2 <= '0';
       elsif (clk_en = '1') then
         nreti_st0 <= (not nreti_st0 and idc_reti) or (nreti_st0 and not reti_st3);
         reti_st1  <= (not reti_st1 and not nreti_st0 and idc_reti) or (reti_st1 and cpuwait);
         reti_st2  <= (not reti_st2 and reti_st1 and not cpuwait) or (reti_st2 and cpuwait) ;
         reti_st3  <= not reti_st3 and reti_st2 and not cpuwait; 
       end if;
     end if;
   end process;


-- INTERRUPT LOGIC AND STATE MACHINE 

   irq_int <= '0' when	irqlines="00000000000000000000000" else '1';
   
   irq_vector_adr(15 downto 6)<=(others => '0');
   irq_vector_adr(0) <= '0';
-- PRIORITY ENCODER
   irq_vector_adr(5 downto 1) <= "00001" when irqlines(0)='1'  else -- 0x0002
   "00010" when irqlines(1)='1'  else -- 0x0004  
   "00011" when irqlines(2)='1'  else -- 0x0006  
   "00100" when irqlines(3)='1'  else -- 0x0008  
   "00101" when irqlines(4)='1'  else -- 0x000A  
   "00110" when irqlines(5)='1'  else -- 0x000C  
   "00111" when irqlines(6)='1'  else -- 0x000E  
   "01000" when irqlines(7)='1'  else -- 0x0010  
   "01001" when irqlines(8)='1'  else -- 0x0012  
   "01010" when irqlines(9)='1'  else -- 0x0014
   "01011" when irqlines(10)='1' else -- 0x0016
   "01100" when irqlines(11)='1' else -- 0x0018
   "01101" when irqlines(12)='1' else -- 0x001A
   "01110" when irqlines(13)='1' else -- 0x001C
   "01111" when irqlines(14)='1' else -- 0x001E
   "10000" when irqlines(15)='1' else -- 0x0020
   "10001" when irqlines(16)='1' else -- 0x0022
   "10010" when irqlines(17)='1' else -- 0x0024
   "10011" when irqlines(18)='1' else -- 0x0026
   "10100" when irqlines(19)='1' else -- 0x0028
   "10101" when irqlines(20)='1' else -- 0x002A
   "10110" when irqlines(21)='1' else -- 0x002C
   "10111" when irqlines(22)='1' else -- 0x002E  								  
   "00000";	  

-- MULTI CYCLE INSTRUCTION FLAG FOR IRQ
   cpu_busy <= idc_adiw or idc_sbiw or idc_cbi or idc_sbi or
   idc_rjmp or idc_ijmp or
   idc_jmp or jmp_st1 or
   idc_brbs or idc_brbc or
   idc_lpm or lpm_st1 or
   skip_inst_start or (skip_inst_st1 and two_word_inst) or
   idc_ld_x or idc_ld_y or idc_ldd_y or idc_ld_z or idc_ldd_z or (ld_st and cpuwait) or
   idc_st_x or idc_st_y or idc_std_y or idc_st_z or idc_std_z or (st_st and cpuwait) or
   idc_lds or lds_st1 or (lds_st2 and cpuwait) or 
   idc_sts or sts_st1 or (sts_st2 and cpuwait) or
   idc_rcall or rcall_st1 or (rcall_st2 and cpuwait) or           -- RCALL
   idc_icall or icall_st1 or (icall_st2 and cpuwait) or		   -- ICALL
   idc_call or call_st1 or call_st2 or (call_st3 and cpuwait) or  -- CALL
   (idc_bclr and sreg_bop_wr_en(7)) or                 -- ??? CLI
   (iowe_int and sreg_adr_eq and not dbusout_int(7))or -- ??? Writing '0' to I flag (OUT/STD/ST/STD)
   nirq_st0 or
--			idc_ret  or nret_st0 or                             -- Old variant 
   idc_ret or ret_st1 or ret_st2 or
--			idc_reti or nreti_st0;                              -- At least one instruction must be executed after RETI and before the new interrupt.
   idc_reti or reti_st1 or reti_st2;
   
   sreg_adr_eq <= '1' when adr_int=SREG_Address else '0';			
   irq_start <= irq_int and not cpu_busy and sreg_out(7);

   irq_state_machine : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       nirq_st0 <= '0';
       irq_st1 <= '0';
       irq_st2 <= '0';
       irq_st3 <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         nirq_st0 <= '0';
         irq_st1 <= '0';
         irq_st2 <= '0';
         irq_st3 <= '0';
       elsif (clk_en = '1') then

         nirq_st0 <= (not nirq_st0 and irq_start) or (nirq_st0 and not (irq_st3 and not cpuwait));
         irq_st1  <= (not irq_st1 and not nirq_st0 and irq_start);
         irq_st2  <= (not irq_st2 and irq_st1) or (irq_st2 and cpuwait);
         irq_st3  <= (not irq_st3 and irq_st2 and not cpuwait) or (irq_st3 and cpuwait);
       end if;
     end if;
   end process;

   irqack_reg : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       irqack_int <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         irqack_int <= '0';
       elsif (clk_en = '1') then
         irqack_int<= not irqack_int and irq_start;
       end if;
     end if;
   end process;

   irqack <= irqack_int;

   irqackad_reg : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       irqackad_int <= (others => '0');
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         irqackad_int <= (others => '0');
       elsif (clk_en = '1') then
         irqackad_int<=irq_vector_adr(5 downto 1);
       end if;
     end if;
   end process;

   irqackad <= irqackad_int;

-- *******************************************************************************************

   rjmp_push_pop_ijmp_state_brxx_machine : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       rjmp_st <= '0';
       ijmp_st <= '0';
       push_st <= '0';
       pop_st <= '0';
       brxx_st <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         rjmp_st <= '0';
         ijmp_st <= '0';
         push_st <= '0';
         pop_st <= '0';
         brxx_st <= '0';
       elsif (clk_en = '1') then
         rjmp_st <= idc_rjmp;    -- ??
         ijmp_st <= idc_ijmp;
         push_st <= (not push_st and idc_push) or (push_st and cpuwait);
         pop_st  <= (not pop_st  and idc_pop) or (pop_st and cpuwait);
         brxx_st <= not brxx_st and (idc_brbc or idc_brbs) and bit_test_op_out;
       end if;
     end if;
   end process;

-- LD/LDD/ST/STD
   ld_st_state_machine : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       ld_st <= '0';
       st_st <= '0';
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         ld_st <= '0';
         st_st <= '0';
       elsif (clk_en = '1') then
         ld_st <= (not ld_st and (idc_ld_x or idc_ld_y or idc_ldd_y or idc_ld_z or idc_ldd_z)) or (ld_st and cpuwait);
         st_st <= (not st_st and (idc_st_x or idc_st_y or idc_std_y or idc_st_z or idc_std_z)) or (st_st and cpuwait);
       end if;
     end if;
   end process;

-- SBI/CBI
   sbi_cbi_machine : process(clk, nrst, clk_en, sclr)
   begin
     if (nrst = '0') then
       sbi_st <= '0';
       cbi_st <= '0';
       cbi_sbi_io_adr_tmp  <= (others => '0');
       cbi_sbi_bit_num_tmp	<= (others => '0');
     elsif (rising_edge(clk)) then
       if (sclr = '1') then
         sbi_st <= '0';
         cbi_st <= '0';
         cbi_sbi_io_adr_tmp  <= (others => '0');
         cbi_sbi_bit_num_tmp	<= (others => '0');
       elsif (clk_en = '1') then       -- CLOCK
         sbi_st <= not sbi_st and idc_sbi;
         cbi_st <= not cbi_st and idc_cbi;
         cbi_sbi_io_adr_tmp <= dex_adr5port;
         cbi_sbi_bit_num_tmp <= dex_bitop_bitnum;
       end if;
     end if;
   end process;

-- ########################################################################################

-- SREG FLAGS WRITE ENABLE LOGIC

   bclr_bset_op_en_logic:for i in sreg_bop_wr_en'range generate
     sreg_bop_wr_en(i) <= '1' when (dex_bitnum_sreg=i and (idc_bclr or idc_bset)='1') else '0';
   end generate;

   sreg_c_wr_en <= idc_add or idc_adc or (idc_adiw or adiw_st) or idc_sub  or idc_subi or 
   idc_sbc or idc_sbci or (idc_sbiw or sbiw_st) or idc_com or idc_neg or
   idc_cp or idc_cpc or idc_cpi or
   idc_lsr or idc_ror or idc_asr or sreg_bop_wr_en(0);

   sreg_z_wr_en <= idc_add or idc_adc or (idc_adiw or adiw_st) or idc_sub  or idc_subi or 
   idc_sbc or idc_sbci or (idc_sbiw or sbiw_st) or
   idc_cp or idc_cpc or idc_cpi or
   idc_and or idc_andi or idc_or or idc_ori or idc_eor or idc_com or idc_neg or
   idc_inc or idc_dec or idc_lsr or idc_ror or idc_asr or sreg_bop_wr_en(1);
   

   sreg_n_wr_en <= idc_add or idc_adc or adiw_st or idc_sub  or idc_subi or 
   idc_sbc or idc_sbci or sbiw_st or
   idc_cp or idc_cpc or idc_cpi or
   idc_and or idc_andi or idc_or or idc_ori or idc_eor or idc_com or idc_neg or
   idc_inc or idc_dec or idc_lsr or idc_ror or idc_asr or sreg_bop_wr_en(2);

   sreg_v_wr_en <= idc_add or idc_adc or idc_adiw or idc_sub  or idc_subi or 
   idc_sbc or idc_sbci or idc_sbiw or idc_neg or idc_inc or idc_dec or
   idc_cp or idc_cpc or idc_cpi or
   idc_lsr or idc_ror or idc_asr or sreg_bop_wr_en(3);

   sreg_s_wr_en <= idc_add or idc_adc or adiw_st or idc_sub or idc_subi or 
   idc_sbc or idc_sbci or sbiw_st or 
   idc_cp or idc_cpc or idc_cpi or				
   idc_and or idc_andi or idc_or or idc_ori or idc_eor or idc_com or idc_neg or
   idc_inc or idc_dec or idc_lsr or idc_ror or idc_asr or sreg_bop_wr_en(4);

   sreg_h_wr_en <= idc_add or idc_adc or idc_sub  or idc_subi or
   idc_cp or idc_cpc or idc_cpi or
   idc_sbc or idc_sbci or idc_neg or sreg_bop_wr_en(5);

   sreg_t_wr_en <=  idc_bst or sreg_bop_wr_en(6);

   sreg_i_wr_en <= irq_st1 or reti_st3 or sreg_bop_wr_en(7); -- WAS "irq_start"

   sreg_fl_in <=  bit_pr_sreg_out when (idc_bst or idc_bclr or idc_bset)='1' else		           -- TO THE SREG
   reti_st3&'0'&alu_h_flag_out&alu_s_flag_out&alu_v_flag_out&alu_n_flag_out&alu_z_flag_out&alu_c_flag_out;      
----------------------------------------------------------------------------
-- INSTRUCTION DECODER OUTPUTS FOR THE OTHER BLOCKS

-- FOR ALU

   idc_add_out   <= idc_add;
   idc_adc_out   <= idc_adc;
   idc_adiw_out  <= idc_adiw;
   idc_sub_out   <= idc_sub;
   idc_subi_out  <= idc_subi;
   idc_sbc_out   <= idc_sbc;
   idc_sbci_out  <= idc_sbci;
   idc_sbiw_out  <= idc_sbiw;
   adiw_st_out   <= adiw_st;
   sbiw_st_out   <= sbiw_st;
   idc_and_out   <= idc_and;
   idc_andi_out  <= idc_andi;
   idc_or_out    <= idc_or;
   idc_ori_out   <= idc_ori;
   idc_eor_out   <= idc_eor;              
   idc_com_out   <= idc_com;              
   idc_neg_out   <= idc_neg;
   idc_inc_out   <= idc_inc;
   idc_dec_out   <= idc_dec;
   idc_cp_out    <= idc_cp;              
   idc_cpc_out   <= idc_cpc;
   idc_cpi_out   <= idc_cpi;
   idc_cpse_out  <= idc_cpse;                            
   idc_lsr_out   <= idc_lsr;
   idc_ror_out   <= idc_ror;
   idc_asr_out   <= idc_asr;
   idc_swap_out  <= idc_swap;

-- FOR THE BIT PROCESSOR

   idc_sbi_out  <= idc_sbi;
   sbi_st_out   <= sbi_st;
   idc_cbi_out  <= idc_cbi;
   cbi_st_out   <= cbi_st;
   idc_bld_out  <= idc_bld;
   idc_bst_out  <= idc_bst;
   idc_bset_out <= idc_bset;
   idc_bclr_out <= idc_bclr;
   idc_sbic_out <= idc_sbic;
   idc_sbis_out <= idc_sbis;
   idc_sbrs_out <= idc_sbrs;
   idc_sbrc_out <= idc_sbrc;
   idc_brbs_out <= idc_brbs;
   idc_brbc_out <= idc_brbc;
   idc_reti_out <= idc_reti;

-- POST INCREMENT/PRE DECREMENT FOR THE X,Y,Z REGISTERS
   post_inc <= idc_psinc;
   pre_dec  <= idc_prdec;
   reg_h_wr <= (idc_st_x or idc_st_y or idc_st_z or idc_ld_x or idc_ld_y or idc_ld_z) and (idc_psinc or idc_prdec);

   reg_h_adr(0)<= idc_st_x or idc_ld_x;
   reg_h_adr(1)<= idc_st_y or idc_std_y or idc_ld_y or idc_ldd_y;
   reg_h_adr(2)<= idc_st_z or idc_std_z or idc_ld_z or idc_ldd_z;

-- STACK POINTER CONTROL
   sp_ndown_up <= idc_pop or idc_ret or (ret_st1 and not cpuwait) or idc_reti or (reti_st1 and not cpuwait); -- ?????????
   sp_en <= idc_push or idc_pop or idc_rcall or (rcall_st1 and not cpuwait) or idc_icall or (icall_st1 and not cpuwait) or 
   idc_ret or (ret_st1 and not cpuwait) or idc_reti or (reti_st1 and not cpuwait) or
   call_st1 or (call_st2 and not cpuwait) or irq_st1 or (irq_st2 and not cpuwait); --????????

-- 

   branch  <= dex_condition;
   sreg_bit_num <= dex_bitnum_sreg;
   bit_num_r_io <= cbi_sbi_bit_num_tmp when (cbi_st or sbi_st)='1' else dex_bitop_bitnum;

   adr <= adr_int;

   ramre <= ramre_int;
   ramwe <= ramwe_int;

   iore <= iore_int;
   iowe <= iowe_int;

   dbusout <= dbusout_int;
])
