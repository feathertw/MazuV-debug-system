import sys
file = sys.argv[1]
fpIn= open(file,"r")

print "#define r_type_insn(_f7, _rs2, _rs1, _f3, _rd, _opc) \\"
print ".word (((_f7) << 25) | ((_rs2) << 20) | ((_rs1) << 15) | ((_f3) << 12) | ((_rd) << 7) | ((_opc) << 0))"
print ""
print "#define picorv32_getq_insn(_rd, _qs) \\"
print "r_type_insn(0b0000000, 0, _qs, 0b100, _rd, 0b0001011)"
print ""
print "#define picorv32_setq_insn(_qd, _rs) \\"
print "r_type_insn(0b0000001, 0, _rs, 0b010, _qd, 0b0001011)"
print ""
print "#define picorv32_retirq_insn() \\"
print "r_type_insn(0b0000010, 0, 0, 0b000, 0, 0b0001011)"
print ""

orignal = fpIn.readline()
while orignal:
        new = orignal.replace(' ','')
        if False: pass
        elif "csrw0x7b2,s0" in new:   print  "        picorv32_setq_insn(2, 8)"
        elif "csrw0x7b2,s1" in new:   print  "        picorv32_setq_insn(2, 9)"
        elif "csrw0x7b3,s1" in new:   print  "        picorv32_setq_insn(3, 9)"

        elif "csrrs0,0x7b2" in new:   print  "        picorv32_getq_insn(8, 2)"
        elif "csrrs1,0x7b2" in new:   print  "        picorv32_getq_insn(9, 2)"
        elif "csrrs1,0x7b3" in new:   print  "        picorv32_getq_insn(9, 3)"

        elif "csrwdpc,s1" in new:     print  "        picorv32_setq_insn(0, 9)"
        elif "csrrs1,dpc" in new:     print  "        picorv32_getq_insn(9, 0)"

        elif "csrw0x000,s1" in new:   print  "        nop"
        elif "csrrs1,0x000" in new:   print  "        addi    s1, x0, 0"

        elif "dret" in new:           print  "        picorv32_retirq_insn()"
        elif "csrrs1,mhartid" in new: print  "        addi    s1, x0, 0"
        else: print orignal[:-1]

        orignal = fpIn.readline()

fpIn.close()

