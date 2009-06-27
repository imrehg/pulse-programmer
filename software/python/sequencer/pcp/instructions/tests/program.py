import unittest
from sequencer.pcp.instructions.program import *
from sequencer.pcp.instructions.insn    import *
from sequencer.pcp.instructions.btr     import *
from sequencer.pcp.instructions.j       import *
from sequencer.pcp.instructions.halt    import *
from sequencer.pcp.instructions.ld64i   import *

#------------------------------------------------------------------------------
class Test_PulseProgram(unittest.TestCase):

  def setUp(self):
    self.p = PulseProgram(64, 4)
    Word.set_masks(word_width = 64, address_width = 11)
    InstructionWord.set_opcode_mask(opcode_width = 6)
    TargetInstruction.set_address_mask()
    self.d = DataWord(0x12345678)
    self.l = Load64Immed_Instr(target=self.d, register=0x7)
    self.b = BranchTrigger_Instr(target=self.l, trigger=0x9)
    self.j = Jump_Instr(target=self.b)
    self.h = Halt_Instr()
    
    self.p.add_word(self.d)
    self.p.add_word(self.l)
    self.p.add_word(self.b)
    self.p.add_word(self.j)

  def test_init(self):
    p = PulseProgram(32, 10)
    self.assertEquals(0, p.get_size())
    self.assertEquals(32, p.width)
    self.assertEquals(10, p.size_limit)
    self.assertRaises(WidthError, PulseProgram, -1, 10)
    self.assertRaises(WidthError, PulseProgram, 10, 0)

  def test_add_word(self):
    self.assertRaises(RuntimeError, self.p.add_word, self.h)
    self.assertRaises(RuntimeError, self.p.add_word, self.b)

  def test_binary_generator(self):
#    self.p.validate()
    charlist = []
    for byte in self.p.binary_generator():
      charlist.append(byte)
    expected = ['\x00', '\x00', '\x00', '\x00', '\x12', '\x34', '\x56', '\x78',
                '\x10', '\x38', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00',
                '\x50', '\x00', '\x00', '\x09', '\x00', '\x00', '\x00', '\x01',
                '\x5c', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x02']
    self.assertEquals(expected, charlist)

  def tearDown(self):
    del self.p

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_PulseProgram)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
