import sys
file = sys.argv[1]
fpIn= open(file,"r")

orignal = fpIn.readline()
while orignal:
        new = orignal.replace(' ','')
        if False: pass
        elif "csrw0x7b2,s0" in new:   print  "        .word 0x0204210b"
        elif "csrw0x7b3,s1" in new:   print  "        .word 0x0204a18b"
        elif "csrrs0,0x7b2" in new:   print  "        .word 0x0001440b"
        elif "csrrs1,0x7b3" in new:   print  "        .word 0x0001c48b"
        elif "dret" in new:           print  "        .word 0x0400000b"
        elif "csrrs1,mhartid" in new: print  "        addi    s1, x0, 0"
        else: print orignal[:-1]

        orignal = fpIn.readline()

fpIn.close()

