debug_vector_entry:
        j debug_main
        j debug_exception

debug_exception:
        nop

debug_main:
        csrw    0x7b2, s0
        csrw    0x7b3, s1
        la      s0, core_halt
        csrr    s1, mhartid
        sw      s1, 0(s0)

check_valid:
        la      s0, dm_request
        lw      s0, 0(s0)
        bgez    s0, check_valid

check_hart:
        li      s1, 0xfffff
        and     s0, s0, s1
        csrr    s1, mhartid
        bne     s0, s1, check_valid

check_request:
        la      s0, dm_request
        lw      s0, 0(s0)
        srli    s0, s0, 20
        andi    s0, s0, 0x7ff

        beqz    s0, request_resume
        addi    s0, s0, -1
        beqz    s0, request_set_s0
        addi    s0, s0, -1
        beqz    s0, request_set_s1
        addi    s0, s0, -1
        beqz    s0, request_set_gpr
        addi    s0, s0, -1
        beqz    s0, request_get_s0
        addi    s0, s0, -1
        beqz    s0, request_get_s1
        addi    s0, s0, -1
        beqz    s0, request_get_gpr
        addi    s0, s0, -1
        beqz    s0, request_set_csr
        addi    s0, s0, -1
        beqz    s0, request_get_csr
loop:   j       loop

request_resume:
        csrr    s1, mhartid
        la      s0, core_resume
        sw      s1, 0(s0)
        la      s0, dm_request
        sw      s1, 0(s0)
        csrr    s0, 0x7b2
        csrr    s1, 0x7b3
        dret

request_set_s0:
        la      s0, dm_data0
        lw      s1, 0(s0)
        csrw    0x7b2, s1
        j       request_complete
request_set_s1:
        la      s0, dm_data0
        lw      s1, 0(s0)
        csrw    0x7b3, s1
        j       request_complete
request_set_gpr:
        la      s0, dm_data0
        lw      x0, 0(s0) ###
        j       request_complete
request_get_s0:
        la      s0, dm_data0
        csrr    s1, 0x7b2
        sw      s1, 0(s0)
        j       request_complete
request_get_s1:
        la      s0, dm_data0
        csrr    s1, 0x7b3
        sw      s1, 0(s0)
        j       request_complete
request_get_gpr:
        la      s0, dm_data0
        sw      x0, 0(s0) ###
        j       request_complete

request_set_csr:
        la      s0, dm_data0
        lw      s1, 0(s0)
        csrw    0x000, s1 ###
        j       request_complete
request_get_csr:
        la      s0, dm_data0
        csrr    s1, 0x000 ###
        sw      s1, 0(s0)
        j       request_complete

request_complete:
        la      s0, dm_request
        csrr    s1, mhartid
        sw      s1, 0(s0)
        j       check_valid
finish_rom:

.align 10
core_halt:      .word 1
core_resume:    .word 1
core_exception: .word 1
.align 5
dm_request:     .word 1
.align 5
dm_data0:       .word 1
dm_data1:       .word 1
dm_data2:       .word 1
dm_data3:       .word 1
dm_data4:       .word 1
dm_data5:       .word 1
dm_data6:       .word 1
dm_data7:       .word 1
dm_data8:       .word 1
dm_data9:       .word 1
dm_data10:      .word 1
dm_data11:      .word 1

dm_progbuf0:    .word 1
dm_progbuf1:    .word 1
dm_progbuf2:    .word 1
dm_progbuf3:    .word 1
dm_progbuf4:    .word 1
dm_progbuf5:    .word 1
dm_progbuf6:    .word 1
dm_progbuf7:    .word 1
dm_progbuf8:    .word 1
dm_progbuf9:    .word 1
dm_progbuf10:   .word 1
dm_progbuf11:   .word 1
dm_progbuf12:   .word 1
dm_progbuf13:   .word 1
dm_progbuf14:   .word 1
dm_progbuf15:   .word 1
