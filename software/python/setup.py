# distutils setup.py script to generate distributions

from distutils.core import setup

setup(name='pulse-sequencer',
      version='0.22',
      packages=['sequencer',
                'sequencer.devices',
                'sequencer.ptp',
                'sequencer.pcp',
                'sequencer.pcp.events',
                'sequencer.pcp.instructions',
                'sequencer.pcp.machines',
                ],
      description="""
      Software control interface for the MIT-NIST-ARDA pulse sequencer.
      """,
      long_description="""
      The pulse-sequencer packages are a high-level control interface
      for the MIT-NIST-ARDA pulse sequencer device. The pulse sequencer
      device supplies time synchronization and programmability in
      radiofrequency signal generation systems. These systems are mainly
      usely in quantum information processing and other physics settings
      where precise and accurate timing control is necessary.
      """,
      author='Paul T. Pham',
      url='http://pulse-sequencer.sf.net/python'
      )
