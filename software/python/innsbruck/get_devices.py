import string
import sequencer


def get_hardware(filename=""):
    try:
        file=open(filename, 'r')
    except IOError:
        print "error while opening hardware settings file:"
        print filename
        print "trying an alternative"
        filename="Hardware settings.txt"
        file=open(filename, 'r')
    dictionary={}
    is_device=False
    content=file.read()
    array=content.split("\n")
    for i in range(len(array)):
        is_PB_device=array[i].find('.Device=PB')
        is_invPB_device=array[i].find('.Device=!PB')
        is_inverted=0
        if (is_invPB_device!=-1):
            is_inverted=1
        if (is_PB_device!=-1) or (is_invPB_device!=-1):

            to_test=[array[i-1],array[i+1]]
            split1=array[i].split(".")
            ch_name=split1[0]
            for item in to_test:
                split2=item.split(".")
                if split2[0]==ch_name:
                    split3=split2[1].split("=")
                    try:
                        dictionary[split1[0]]=[]
                        dictionary[split1[0]].append(int(split3[1]))
                        dictionary[split1[0]].append(is_inverted)
                    except:
                        print("warning: got a non int channel number"+split2[1])

    return dictionary



