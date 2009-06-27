#Frequency initialization is missing
# Do that in the transition define
#sequencer.main_program.sequence_list=[]
#sequencer.main_program.time=0

<VARIABLES>
#Define the Variables which we get from labview:
Pause=self.set_variable("float","Pause",0,2e4)
Tomomode=self.set_variable("float","Tomomode",0,1e3)
AnalysisMode=self.set_variable("int","AnalysisMode",0,15e3)
Echo3Phase=self.set_variable("float","Echo3Phase",0,2)
Spinechopause=self.set_variable("float","Spinechopause",0,1e3)


CameraOn=self.set_variable("Bool","CameraOn",0)
Hide=self.set_variable("Bool","Hide",0)
SpinEcho1=self.set_variable("Bool","SpinEcho1",0)
SpinEcho3=self.set_variable("Bool","SpinEcho3",0)
UseMotion=self.set_variable("Bool","UseMotion",1)
</VARIABLES>


<SEQUENCE>
freq1=10
t_carr={1 : 14.27, 2: 13.96, 3 : 13.97}
t_carr3={1 :50, 2: 50, 3: 50.11}
t_blue={1:256.3, 2:248.7, 3: 252.8}

ion_blue={1:101, 2:102 ,3: 103}

Carrier=transition(transition_name="Carrier",t_rabi=t_carr,
                 frequency=freq1,amplitude=-1,slope_type="blackman",
                 slope_duration=2,amplitude2=-1,frequency2=0)


Carrier3=transition(transition_name="Carrier3",t_rabi=t_carr3,
                 frequency=freq1,amplitude=-20,slope_type="blackman",
                 slope_duration=1,amplitude2=-1,frequency2=0)

Blue=transition(transition_name="Blue",t_rabi=t_blue,
                 frequency=freq1,amplitude=-10,slope_type="blackman",
                 slope_duration=1,ion_list=ion_blue,amplitude2=-1,frequency2=0)

SweepFreq(100,1,2,-3,30)

#DopplerPreparation()
#SidebandCool()

#Coherent manipulation

#R729(1,1,0.5,"carrier")
R729(3,0.5,1.5,Blue) #entangle ion3 with motional qubit
#R729(2,1,0.5,"carrier")

#if not UseMotion:
#  R729(2,1,0.5,Blue)

#seq_wait(Pause)

#TTL(["854 sw","866 sw"],3.2)

#if Hide:
#  R729(3,1,0,Carrier3) #hide target ion

#number=AnalysisMode % 6
#if number==0 :
#  seq_wait(10)
#elif number == 1:
#  R729(1,1,0,Carrier)
#elif number == 2:
#  R729(1,0.5,0,Carrier)
#elif number == 3:
#  R729(1,0.5,0.5,Carrier)
#elif number == 4:
#  R729(1,0.5,1,Carrier)
#elif number == 5:
#  R729(1,0.5,1.5,Carrier)



#if not UseMotion:
#  R729(2,1.5,2,Blue)

#R729(1,1/sqrt(2),0.5,Blue)
#R729(1,1,0,Blue)
#R729(1,1/sqrt(2),0.5,Blue)
R729(1,1,0,Blue)

#if SpinEcho1:
#  R729(1,0.5,1.5)

#if SpinEcho3:
#  if Hide:
#    R729(3+100,1,1,Carrier3)
#  R729(3,1,0.5,Carrier)
#  if Hide:
#    R729(3+100,1,1,Carrier3)

#R729(2,0.5,1.5,Blue)

#if SpinEcho1:
#  R729(1,0.5,1.5,Carrier)
#else:
#  R729(1,0.5,0.5,Carrier)

R729(2,0.5,0.5,Carrier)

#PMTDetection(3.1,CameraOn)
#end_sequential()
#end_infinite_loop()
</SEQUENCE>
