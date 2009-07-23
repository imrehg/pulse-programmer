dnl-*-VHDL-*-
-- AVR core

--  Top entity for AVR core
--  Version 1.11
--  Designed by Ruslan Lepetenok 
--  Modified 03.11.2002

-- 1863 devices
-- 1756 logic cells

unit_([avr_core], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
use seqlib.avr.all;
],[dnl -- Generics ------------------------------------------------------------

],[dnl -- Ports ---------------------------------------------------------------
  cp2           : in  std_logic;
  clk_en        : in  std_logic;
  sclr          : in  std_logic;
  ireset        : in  std_logic;
  cpuwait       : in  std_logic;
  -- PROGRAM MEMORY PORTS
  pc            : out std_logic_vector (15 downto 0);
  inst          : in  std_logic_vector (15 downto 0);
  -- I/O REGISTERS PORTS
  adr           : out std_logic_vector (5 downto 0);
  iore          : out std_logic;
  iowe          : out std_logic;
  -- DATA MEMORY PORTS
  ramadr        : out std_logic_vector (15 downto 0);
  ramre         : out std_logic;
  ramwe         : out std_logic;
  dbusin        : in  std_logic_vector (7 downto 0);
  dbusout       : out std_logic_vector (7 downto 0);
  -- INTERRUPTS PORT
  irqlines      : in  std_logic_vector (22 downto 0);
  irqack        : out std_logic;
  irqackad      : out std_logic_vector(4 downto 0);
  debug_led_out : out byte;
],[dnl -- Declarations --------------------------------------------------------
pm_fetch_dec_component_
alu_avr_component_
reg_file_component_
io_reg_file_component_
bit_processor_component_
io_adr_dec_component_

   signal sg_dbusin  : std_logic_vector (7 downto 0);
   signal sg_dbusout : std_logic_vector (7 downto 0);
   signal sg_adr     : std_logic_vector (5 downto 0);
   signal sg_iowe    : std_logic;
   signal sg_iore    : std_logic;

-- SIGNALS FOR INSTRUCTION AND STATES

signal sg_idc_add,sg_idc_adc,sg_idc_adiw,sg_idc_sub,sg_idc_subi,sg_idc_sbc,sg_idc_sbci,sg_idc_sbiw,
       sg_adiw_st,sg_sbiw_st,sg_idc_and,sg_idc_andi,sg_idc_or,sg_idc_ori,sg_idc_eor,sg_idc_com,
       sg_idc_neg,sg_idc_inc,sg_idc_dec,sg_idc_cp,sg_idc_cpc,sg_idc_cpi,sg_idc_cpse,
       sg_idc_lsr,sg_idc_ror,sg_idc_asr,sg_idc_swap,sg_idc_sbi,sg_sbi_st,sg_idc_cbi,sg_cbi_st,
       sg_idc_bld,sg_idc_bst,sg_idc_bset,sg_idc_bclr,sg_idc_sbic,sg_idc_sbis,sg_idc_sbrs,sg_idc_sbrc,
       sg_idc_brbs,sg_idc_brbc,sg_idc_reti  : std_logic := '0';

signal sg_alu_data_r_in,sg_alu_data_d_in,sg_alu_data_out : std_logic_vector(7 downto 0) := (others =>'0');

signal sg_reg_rd_in,sg_reg_rd_out,sg_reg_rr_out : std_logic_vector  (7 downto 0) := (others =>'0');
signal sg_reg_rd_adr,sg_reg_rr_adr              : std_logic_vector  (4 downto 0) := (others =>'0');
signal sg_reg_h_out,sg_reg_z_out                : std_logic_vector (15 downto 0) := (others =>'0');
signal sg_reg_h_adr                             : std_logic_vector (2 downto 0) := (others =>'0');
signal sg_reg_rd_wr,sg_post_inc,
                       sg_pre_dec,sg_reg_h_wr   : std_logic  := '0';

signal sg_sreg_fl_in,sg_sreg_out,sg_sreg_fl_wr_en,
       sg_spl_out,sg_sph_out,sg_rampz_out                  : std_logic_vector(7 downto 0) := (others =>'0');

signal sg_sp_ndown_up,sg_sp_en : std_logic  := '0';


signal sg_bit_num_r_io,sg_branch,sg_sreg_bit_num  : std_logic_vector (2 downto 0) := (others =>'0');
signal sg_bitpr_io_out,sg_bit_pr_sreg_out,sg_sreg_flags,
       sg_bld_op_out,sg_reg_file_rd_in : std_logic_vector(7 downto 0) := (others =>'0');


signal sg_bit_test_op_out : std_logic  := '0';

signal sg_alu_c_flag_out,sg_alu_z_flag_out,sg_alu_n_flag_out,sg_alu_v_flag_out,
       sg_alu_s_flag_out,sg_alu_h_flag_out  : std_logic  := '0';
],[dnl -- Body ----------------------------------------------------------------

--   debug_led_out <= sg_dbusout;
   debug_led_out(4 downto 0) <= sg_reg_rr_adr(4 downto 0);
--   debug_led_out(6) <= sg_reg_rr_wr;
--   debug_led_out(7) <= sg_reg_rd_wr;

  main : component pm_fetch_dec
    port map (
      -- EXTERNAL INTERFACES OF THE CORE
      clk      => cp2,
      clk_en   => clk_en,
      sclr     => sclr,
      nrst     => ireset,
      cpuwait  => cpuwait,

      -- PROGRAM MEMORY PORTS
      pc       => pc,    
      inst     => inst,

      -- I/O REGISTERS PORTS
      adr      => sg_adr,
      iore     => sg_iore,
      iowe     => sg_iowe,

      -- DATA MEMORY PORTS
      ramadr   => ramadr,
      ramre    => ramre,
      ramwe    => ramwe,

      dbusin   => sg_dbusin,
      dbusout  => sg_dbusout,

      -- INTERRUPTS PORT
      irqlines => irqlines,
      irqack   => irqack,
      irqackad => irqackad,

      -- END OF THE CORE INTERFACES

      -------------------------------------------------------------------------
      -- INTERFACES TO THE OTHER BLOCKS

      -------------------------------------------------------------------------
      -- INTERFACES TO THE ALU
      alu_data_r_in   => sg_alu_data_r_in,
      alu_data_d_in   => sg_alu_data_d_in,

      -- OPERATION SIGNALS INPUTS
      idc_add_out  => sg_idc_add,
      idc_adc_out  => sg_idc_adc,
      idc_adiw_out => sg_idc_adiw,
      idc_sub_out  => sg_idc_sub,
      idc_subi_out => sg_idc_subi,
      idc_sbc_out  => sg_idc_sbc,
      idc_sbci_out => sg_idc_sbci,
      idc_sbiw_out => sg_idc_sbiw,

      adiw_st_out  => sg_adiw_st,
      sbiw_st_out  => sg_sbiw_st,

      idc_and_out  => sg_idc_and,
      idc_andi_out => sg_idc_andi,
      idc_or_out   => sg_idc_or,
      idc_ori_out  => sg_idc_ori,
      idc_eor_out  => sg_idc_eor,
      idc_com_out  => sg_idc_com,
      idc_neg_out  => sg_idc_neg,

      idc_inc_out  => sg_idc_inc,
      idc_dec_out  => sg_idc_dec,

      idc_cp_out   => sg_idc_cp,
      idc_cpc_out  => sg_idc_cpc,
      idc_cpi_out  => sg_idc_cpi,
      idc_cpse_out => sg_idc_cpse,

      idc_lsr_out  => sg_idc_lsr,
      idc_ror_out  => sg_idc_ror,
      idc_asr_out  => sg_idc_asr,
      idc_swap_out => sg_idc_swap,

      -- DATA OUTPUT
      alu_data_out => sg_alu_data_out,

      -- FLAGS OUTPUT
      alu_c_flag_out => sg_alu_c_flag_out,
      alu_z_flag_out => sg_alu_z_flag_out,
      alu_n_flag_out => sg_alu_n_flag_out,
      alu_v_flag_out => sg_alu_v_flag_out,
      alu_s_flag_out => sg_alu_s_flag_out,
      alu_h_flag_out => sg_alu_h_flag_out,

      -------------------------------------------------------------------------
      -- INTERFACES TO THE GENERAL PURPOSE REGISTER FILE
      reg_rd_in   => sg_reg_rd_in,
      reg_rd_out  => sg_reg_rd_out,
      reg_rd_adr  => sg_reg_rd_adr,
      reg_rr_out  => sg_reg_rr_out,
      reg_rr_adr  => sg_reg_rr_adr,
      reg_rd_wr   => sg_reg_rd_wr,

      post_inc    => sg_post_inc,
      pre_dec     => sg_pre_dec,
      reg_h_wr    => sg_reg_h_wr,
      reg_h_out   => sg_reg_h_out,
      reg_h_adr   => sg_reg_h_adr,
      reg_z_out   => sg_reg_z_out,

     --------------------------------------------------------------------------
     -- INTERFACES TO THE INPUT/OUTPUT REGISTER FILE

      sreg_fl_in    => sg_sreg_fl_in, --??   
      sreg_out      => sg_sreg_out,    

      sreg_fl_wr_en => sg_sreg_fl_wr_en,

      spl_out       => sg_spl_out,       
      sph_out       => sg_sph_out,       
      sp_ndown_up   => sg_sp_ndown_up,
      sp_en         => sg_sp_en,
      
      rampz_out     => sg_rampz_out,

      -------------------------------------------------------------------------
      -- INTERFACES TO THE BIT PROCESSOR
      bit_num_r_io    => sg_bit_num_r_io,  
      bitpr_io_out    => sg_bitpr_io_out, 

      branch     => sg_branch, 

      bit_pr_sreg_out => sg_bit_pr_sreg_out,

      sreg_bit_num    => sg_sreg_bit_num, 

      bld_op_out      => sg_bld_op_out, 

      bit_test_op_out => sg_bit_test_op_out,

      -------------------------------------------------------------------------
      -- OPERATION SIGNALS INPUTS

      -- INSTRUCTUIONS AND STATES

      idc_sbi_out  => sg_idc_sbi,
      sbi_st_out   => sg_sbi_st,
      idc_cbi_out  => sg_idc_cbi,
      cbi_st_out   => sg_cbi_st,

      idc_bld_out  => sg_idc_bld,
      idc_bst_out  => sg_idc_bst,
      idc_bset_out => sg_idc_bset,
      idc_bclr_out => sg_idc_bclr,

      idc_sbic_out => sg_idc_sbic,
      idc_sbis_out => sg_idc_sbis,
      
      idc_sbrs_out => sg_idc_sbrs,
      idc_sbrc_out => sg_idc_sbrc,
      
      idc_brbs_out => sg_idc_brbs,
      idc_brbc_out => sg_idc_brbc,

      idc_reti_out => sg_idc_reti
      );

  general_purpose_register_file: component reg_file 
    generic map(
      ResetRegFile => TRUE
      )
    port map (
      reg_rd_in   => sg_reg_rd_in,
      reg_rd_out  => sg_reg_rd_out,
      reg_rd_adr  => sg_reg_rd_adr,
      reg_rr_out  => sg_reg_rr_out,
      reg_rr_adr  => sg_reg_rr_adr,
      reg_rd_wr   => sg_reg_rd_wr,

      post_inc    => sg_post_inc,
      pre_dec     => sg_pre_dec,
      reg_h_wr    => sg_reg_h_wr,
      reg_h_out   => sg_reg_h_out,
      reg_h_adr   => sg_reg_h_adr,
      reg_z_out   => sg_reg_z_out,

      clk         => cp2,
      clk_en      => clk_en,
      sclr        => sclr,
      nrst        => ireset      
      );

  bit_proc: component bit_processor
    port map (
      clk             => cp2,
      clk_en          => clk_en,
      sclr            => sclr,
      nrst            => ireset,                  
              
      bit_num_r_io    => sg_bit_num_r_io,  
      dbusin          => sg_dbusin,   
      bitpr_io_out    => sg_bitpr_io_out,   

      sreg_out        => sg_sreg_out,   
      branch          => sg_branch,  

      bit_pr_sreg_out => sg_bit_pr_sreg_out,

      sreg_bit_num    => sg_sreg_bit_num,

      bld_op_out      => sg_bld_op_out,
      reg_rd_out      => sg_reg_rd_out,

      bit_test_op_out => sg_bit_test_op_out,

      -- OPERATION SIGNALS INPUTS

      -- INSTRUCTIONS AND STATES
      idc_sbi  => sg_idc_sbi,        
      sbi_st   => sg_sbi_st,       
      idc_cbi  => sg_idc_cbi,       
      cbi_st   => sg_cbi_st,       

      idc_bld  => sg_idc_bld,       
      idc_bst  => sg_idc_bst,       
      idc_bset => sg_idc_bset,       
      idc_bclr => sg_idc_bclr,       

      idc_sbic => sg_idc_sbic,       
      idc_sbis => sg_idc_sbis,       
              
      idc_sbrs => sg_idc_sbrs,        
      idc_sbrc => sg_idc_sbrc,        
              
      idc_brbs => sg_idc_brbs,        
      idc_brbc => sg_idc_brbc,        

      idc_reti => sg_idc_reti
      );                      

  io_dec : component io_adr_dec
    port map (
      adr          => sg_adr,
      iore         => sg_iore,
      dbusin_int   => sg_dbusin, -- LOCAL DATA BUS OUTPUT
      dbusin_ext   => dbusin,    -- EXTERNAL DATA BUS INPUT
                   
      spl_out      => sg_spl_out,
      sph_out      => sg_sph_out,
      sreg_out     => sg_sreg_out,
      rampz_out    => sg_rampz_out
      );

  io_registers : component io_reg_file
    port map (
      clk        => cp2,
      clk_en     => clk_en,
      sclr       => sclr,
      nrst       => ireset,     

      adr        => sg_adr,       
      iowe       => sg_iowe,
      dbusout    => sg_dbusout,     

      sreg_fl_in => sg_sreg_fl_in,
      sreg_out   => sg_sreg_out,

      sreg_fl_wr_en => sg_sreg_fl_wr_en,

      spl_out  => sg_spl_out,    
      sph_out  => sg_sph_out,    
      sp_ndown_up => sg_sp_ndown_up, 
      sp_en     => sg_sp_en,   
      
      rampz_out => sg_rampz_out   
      );

  alu : component alu_avr
    port map (
      alu_data_r_in => sg_alu_data_r_in,
      alu_data_d_in => sg_alu_data_d_in,
              
      alu_c_flag_in => sg_sreg_out(0),
      alu_z_flag_in => sg_sreg_out(1),

      -- OPERATION SIGNALS INPUTS
      idc_add  => sg_idc_add,
      idc_adc  => sg_idc_adc,      
      idc_adiw => sg_idc_adiw,     
      idc_sub  => sg_idc_sub,     
      idc_subi => sg_idc_subi,     
      idc_sbc  => sg_idc_sbc,     
      idc_sbci => sg_idc_sbci,     
      idc_sbiw => sg_idc_sbiw,     

      adiw_st  => sg_adiw_st,     
      sbiw_st  => sg_sbiw_st,     

      idc_and  => sg_idc_and,     
      idc_andi => sg_idc_andi,     
      idc_or   => sg_idc_or,     
      idc_ori  => sg_idc_ori,     
      idc_eor  => sg_idc_eor,     
      idc_com  => sg_idc_com,     
      idc_neg  => sg_idc_neg,     

      idc_inc  => sg_idc_inc,     
      idc_dec  => sg_idc_dec,     

      idc_cp   => sg_idc_cp,     
      idc_cpc  => sg_idc_cpc,     
      idc_cpi  => sg_idc_cpi,    
      idc_cpse => sg_idc_cpse,     

      idc_lsr  => sg_idc_lsr,     
      idc_ror  => sg_idc_ror,      
      idc_asr  => sg_idc_asr,      
      idc_swap => sg_idc_swap,      

      -- DATA OUTPUT
      alu_data_out => sg_alu_data_out,  

      -- FLAGS OUTPUT
      alu_c_flag_out => sg_alu_c_flag_out,
      alu_z_flag_out => sg_alu_z_flag_out,
      alu_n_flag_out => sg_alu_n_flag_out,
      alu_v_flag_out => sg_alu_v_flag_out,
      alu_s_flag_out => sg_alu_s_flag_out,
      alu_h_flag_out => sg_alu_h_flag_out
      );

  adr      <= sg_adr;     
  iowe     <= sg_iowe;
  iore     <= sg_iore;
  dbusout  <= sg_dbusout;

])
