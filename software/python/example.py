from sequencer import *
from innsbruck import *

parse_params(
  ("param1", "string"),
  ("param2", "int"),
  ("param3", "float"),
  ("param4", "boolean")
  )

begin_infinite_loop()
amplitude_gain(0.8)
amplitude_gain(1)
amplitude_gain(2)
amplitude_gain(5)
amplitude_gain(10)
amplitude_gain(15)
amplitude_gain(20)
amplitude_gain(25)
amplitude_gain(30)
amplitude_gain(35)
amplitude_gain(40)
amplitude_gain(45)
amplitude_gain(50)
amplitude_gain(55)
amplitude_gain(60)
amplitude_gain(65)
amplitude_gain(70)
amplitude_gain(75)
amplitude_gain(80)
amplitude_gain(85)
amplitude_gain(90)
amplitude_gain(95)
amplitude_gain(100)
amplitude_gain(105)
amplitude_gain(110)
amplitude_gain(115)
amplitude_gain(120)
amplitude_gain(125)
amplitude_gain(130)
end_infinite_loop()

load_and_wait(Start_Trigger)
