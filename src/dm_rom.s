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
        la      s0, dm_command
        lw      s0, 0(s0)
        bgez    s0, check_valid

check_hart:
        li      s1, 0xfffff
        and     s0, s0, s1
        csrr    s1, mhartid
        bne     s0, s1, check_valid

check_command:
        la      s0, dm_command
        lw      s0, 0(s0)
        srli    s0, s0, 20
        andi    s0, s0, 0x7ff

        beqz    s0, command_resume
        addi    s0, s0, -1
        beqz    s0, command_set_register
        addi    s0, s0, -1
        beqz    s0, command_get_register
loop:   j       loop

command_resume:
        la      s0, dm_command
        csrr    s1, mhartid
        sw      s1, 0(s0)
        csrr    s0, 0x7b2
        csrr    s1, 0x7b3
        dret

command_set_register:
        j       command_complete
command_get_register:
        j       command_complete
command_complete:
        la      s0, dm_command
        csrr    s1, mhartid
        sw      s1, 0(s0)
        j       debug_main
finish_rom:

.align 9
dm_command: 
        .word 1
core_halt:
        .word 1
