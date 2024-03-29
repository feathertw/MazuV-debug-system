parameter BUS_ADDR_CORE_HALT      =  'h400;
parameter BUS_ADDR_CORE_RESUME    =  'h404;
parameter BUS_ADDR_CORE_EXCEPTION =  'h408;
parameter BUS_ADDR_DM_REQUEST     =  'h420;
parameter BUS_ADDR_DATA0     =  'h440;
parameter BUS_ADDR_DATA1     =  'h444;

parameter DMI_ADDR_DATA0          = 7'h04;
parameter DMI_ADDR_DATA1          = 7'h05;
parameter DMI_ADDR_DMCONTROL      = 7'h10;
parameter DMI_ADDR_DMSTATUS       = 7'h11;
parameter DMI_ADDR_ABSTRACTCS     = 7'h16;
parameter DMI_ADDR_COMMAND        = 7'h17;

parameter HARTSEL_MSB  = 19;
parameter HARTSEL_LSB  =  0;
`define HARTSEL_RANGE HARTSEL_MSB:HARTSEL_LSB
`define HARTSEL_WIDTH 20

parameter DMREG_MSB  = 31;
parameter DMREG_LSB  =  0;
`define DMREG_RANGE  DMREG_MSB:DMREG_LSB
`define DMREG_WIDTH  32

// DMCONTROL
parameter HALTREQ_MSB          = 31;
parameter HALTREQ_LSB          = 31;
parameter RESUMEREQ_MSB        = 30;
parameter RESUMEREQ_LSB        = 30;
parameter HARTRESET_MSB        = 29;
parameter HARTRESET_LSB        = 29;
parameter ACKHAVERESET_MSB     = 28;
parameter ACKHAVERESET_LSB     = 28;
parameter HASEL_MSB            = 26;
parameter HASEL_LSB            = 26;
parameter HARTSELLO_MSB        = 25;
parameter HARTSELLO_LSB        = 16;
parameter HARTSELHI_MSB        = 15;
parameter HARTSELHI_LSB        =  6;
parameter SETRESETHALTREQ_MSB  =  3;
parameter SETRESETHALTREQ_LSB  =  3;
parameter CLRRESETHALTREQ_MSB  =  2;
parameter CLRRESETHALTREQ_LSB  =  2;
parameter NDMRESET_MSB         =  1;
parameter NDMRESET_LSB         =  1;
parameter DMACTIVE_MSB         =  0;
parameter DMACTIVE_LSB         =  0;
`define HALTREQ_WIDTH           1
`define RESUMEREQ_WIDTH         1
`define HARTRESET_WIDTH         1
`define ACKHAVERESET_WIDTH      1
`define HASEL_WIDTH             1
`define HARTSELLO_WIDTH         10
`define HARTSELHI_WIDTH         10
`define SETRESETHALTREQ_WIDTH   1
`define CLRRESETHALTREQ_WIDTH   1
`define NDMRESET_WIDTH          1
`define DMACTIVE_WIDTH          1
`define HALTREQ_RANGE           HALTREQ_MSB:HALTREQ_LSB
`define RESUMEREQ_RANGE         RESUMEREQ_MSB:RESUMEREQ_LSB
`define HARTRESET_RANGE         HARTRESET_MSB:HARTRESET_LSB
`define ACKHAVERESET_RANGE      ACKHAVERESET_MSB:ACKHAVERESET_LSB
`define HASEL_RANGE             HASEL_MSB:HASEL_LSB
`define HARTSELLO_RANGE         HARTSELLO_MSB:HARTSELLO_LSB
`define HARTSELHI_RANGE         HARTSELHI_MSB:HARTSELHI_LSB
`define SETRESETHALTREQ_RANGE   SETRESETHALTREQ_MSB:SETRESETHALTREQ_LSB
`define CLRRESETHALTREQ_RANGE   CLRRESETHALTREQ_MSB:CLRRESETHALTREQ_LSB
`define NDMRESET_RANGE          NDMRESET_MSB:NDMRESET_LSB
`define DMACTIVE_RANGE          DMACTIVE_MSB:DMACTIVE_LSB

// DMSTATUS
parameter IMPEBREAK_MSB          = 22;
parameter IMPEBREAK_LSB          = 22;
parameter ALLHAVERESET_MSB       = 19;
parameter ALLHAVERESET_LSB       = 19;
parameter ANYHAVERESET_MSB       = 18;
parameter ANYHAVERESET_LSB       = 18;
parameter ALLRESUMEACK_MSB       = 17;
parameter ALLRESUMEACK_LSB       = 17;
parameter ANYRESUMEACK_MSB       = 16;
parameter ANYRESUMEACK_LSB       = 16;
parameter ALLNONEEXISTENT_MSB    = 15;
parameter ALLNONEEXISTENT_LSB    = 15;
parameter ANYNONEEXISTENT_MSB    = 14;
parameter ANYNONEEXISTENT_LSB    = 14;
parameter ALLUNAVAIL_MSB         = 13;
parameter ALLUNAVAIL_LSB         = 13;
parameter ANYUNAVAIL_MSB         = 12;
parameter ANYUNAVAIL_LSB         = 12;
parameter ALLRUNNING_MSB         = 11;
parameter ALLRUNNING_LSB         = 11;
parameter ANYRUNNING_MSB         = 10;
parameter ANYRUNNING_LSB         = 10;
parameter ALLHALTED_MSB          =  9;
parameter ALLHALTED_LSB          =  9;
parameter ANYHALTED_MSB          =  8;
parameter ANYHALTED_LSB          =  8;
parameter AUTHENTICATED_MSB      =  7;
parameter AUTHENTICATED_LSB      =  7;
parameter AUTHBUSY_MSB           =  6;
parameter AUTHBUSY_LSB           =  6;
parameter HASRESETHALTREQ_MSB    =  5;
parameter HASRESETHALTREQ_LSB    =  5;
parameter CONFSTRPTRVALID_MSB    =  4;
parameter CONFSTRPTRVALID_LSB    =  4;
parameter VERSION_MSB            =  3;
parameter VERSION_LSB            =  0;
`define IMPEBREAK_WIDTH          1
`define ALLHAVERESET_WIDTH       1
`define ANYHAVERESET_WIDTH       1
`define ALLRESUMEACK_WIDTH       1
`define ANYRESUMEACK_WIDTH       1
`define ALLNONEEXISTENT_WIDTH    1
`define ANYNONEEXISTENT_WIDTH    1
`define ALLUNAVAIL_WIDTH         1
`define ANYUNAVAIL_WIDTH         1
`define ALLRUNNING_WIDTH         1
`define ANYRUNNING_WIDTH         1
`define ALLHALTED_WIDTH          1
`define ANYHALTED_WIDTH          1
`define AUTHENTICATED_WIDTH      1
`define AUTHBUSY_WIDTH           1
`define HASRESETHALTREQ_WIDTH    1
`define CONFSTRPTRVALID_WIDTH    1
`define VERSION_WIDTH            4
`define IMPEBREAK_RANGE          IMPEBREAK_MSB:IMPEBREAK_LSB
`define ALLHAVERESET_RANGE       ALLHAVERESET_MSB:ALLHAVERESET_LSB
`define ANYHAVERESET_RANGE       ANYHAVERESET_MSB:ANYHAVERESET_LSB
`define ALLRESUMEACK_RANGE       ALLRESUMEACK_MSB:ALLRESUMEACK_LSB
`define ANYRESUMEACK_RANGE       ANYRESUMEACK_MSB:ANYRESUMEACK_LSB
`define ALLNONEEXISTENT_RANGE    ALLNONEEXISTENT_MSB:ALLNONEEXISTENT_LSB
`define ANYNONEEXISTENT_RANGE    ANYNONEEXISTENT_MSB:ANYNONEEXISTENT_LSB
`define ALLUNAVAIL_RANGE         ALLUNAVAIL_MSB:ALLUNAVAIL_LSB
`define ANYUNAVAIL_RANGE         ANYUNAVAIL_MSB:ANYUNAVAIL_LSB
`define ALLRUNNING_RANGE         ALLRUNNING_MSB:ALLRUNNING_LSB
`define ANYRUNNING_RANGE         ANYRUNNING_MSB:ANYRUNNING_LSB
`define ALLHALTED_RANGE          ALLHALTED_MSB:ALLHALTED_LSB
`define ANYHALTED_RANGE          ANYHALTED_MSB:ANYHALTED_LSB
`define AUTHENTICATED_RANGE      AUTHENTICATED_MSB:AUTHENTICATED_LSB
`define AUTHBUSY_RANGE           AUTHBUSY_MSB:AUTHBUSY_LSB
`define HASRESETHALTREQ_RANGE    HASRESETHALTREQ_MSB:HASRESETHALTREQ_LSB
`define CONFSTRPTRVALID_RANGE    CONFSTRPTRVALID_MSB:CONFSTRPTRVALID_LSB
`define VERSION_RANGE            VERSION_MSB:VERSION_LSB

parameter VERSION_NOPRESENT  = `VERSION_WIDTH'h0;
parameter VERSION_011        = `VERSION_WIDTH'h1;
parameter VERSION_013        = `VERSION_WIDTH'h2;
parameter VERSION_NOTCONFORM = `VERSION_WIDTH'hf;

// ABSTRACTCS
parameter PROGBUFSIZE_MSB  = 28;
parameter PROGBUFSIZE_LSB  = 24;
parameter BUSY_MSB         = 12;
parameter BUSY_LSB         = 12;
parameter CMDERR_MSB       = 10;
parameter CMDERR_LSB       =  8;
parameter DATACOUNT_MSB    =  3;
parameter DATACOUNT_LSB    =  0;
`define PROGBUFSIZE_WIDTH  5
`define BUSY_WIDTH         1
`define CMDERR_WIDTH       3
`define DATACOUNT_WIDTH    4
`define PROGBUFSIZE_RANGE  PROGBUFSIZE_MSB:PROGBUFSIZE_LSB
`define BUSY_RANGE         BUSY_MSB:BUSY_LSB
`define CMDERR_RANGE       CMDERR_MSB:CMDERR_LSB
`define DATACOUNT_RANGE    DATACOUNT_MSB:DATACOUNT_LSB

parameter CMDERR_NONE           = `CMDERR_WIDTH'h0;
parameter CMDERR_BUSY           = `CMDERR_WIDTH'h1;
parameter CMDERR_NOTSUPPORTED   = `CMDERR_WIDTH'h2;
parameter CMDERR_EXCEPTION      = `CMDERR_WIDTH'h3;
parameter CMDERR_HALTRESUME     = `CMDERR_WIDTH'h4;
parameter CMDERR_BUS            = `CMDERR_WIDTH'h5;
parameter CMDERR_OTHER          = `CMDERR_WIDTH'h7;

// COMMAND
parameter CMDTYPE_MSB           = 31;
parameter CMDTYPE_LSB           = 24;
parameter AARSIZE_MSB           = 22;
parameter AARSIZE_LSB           = 20;
parameter AARPOSTINCREMENT_MSB  = 19;
parameter AARPOSTINCREMENT_LSB  = 19;
parameter POSTEXEC_MSB          = 18;
parameter POSTEXEC_LSB          = 18;
parameter TRANSFER_MSB          = 17;
parameter TRANSFER_LSB          = 17;
parameter WRITE_MSB             = 16;
parameter WRITE_LSB             = 16;
parameter REGNO_MSB             = 15;
parameter REGNO_LSB             =  0;
parameter AAMVIRTUAL_MSB        = 23;
parameter AAMVIRTUAL_LSB        = 23;
parameter AAMSIZE_MSB           = 22;
parameter AAMSIZE_LSB           = 20;
parameter AAMPOSTINCREMENT_MSB  = 19;
parameter AAMPOSTINCREMENT_LSB  = 19;
parameter TARGETSPECIFIC_MSB    = 15;
parameter TARGETSPECIFIC_LSB    = 14;
`define CMDTYPE_WIDTH           8
`define AARSIZE_WIDTH           3
`define AARPOSTINCREMENT_WIDTH  1
`define POSTEXEC_WIDTH          1
`define TRANSFER_WIDTH          1
`define WRITE_WIDTH             1
`define REGNO_WIDTH             16
`define AAMVIRTUAL_WIDTH        1
`define AAMSIZE_WIDTH           3
`define AAMPOSTINCREMENT_WIDTH  1
`define TARGETSPECIFIC_WIDTH    2
`define CMDTYPE_RANGE           CMDTYPE_MSB:CMDTYPE_LSB
`define AARSIZE_RANGE           AARSIZE_MSB:AARSIZE_LSB
`define AARPOSTINCREMENT_RANGE  AARPOSTINCREMENT_MSB:AARPOSTINCREMENT_LSB
`define POSTEXEC_RANGE          POSTEXEC_MSB:POSTEXEC_LSB
`define TRANSFER_RANGE          TRANSFER_MSB:TRANSFER_LSB
`define WRITE_RANGE             WRITE_MSB:WRITE_LSB
`define REGNO_RANGE             REGNO_MSB:REGNO_LSB
`define AAMVIRTUAL_RANGE        AAMVIRTUAL_MSB:AAMVIRTUAL_LSB
`define AAMSIZE_RANGE           AAMSIZE_MSB:AAMSIZE_LSB
`define AAMPOSTINCREMENT_RANGE  AAMPOSTINCREMENT_MSB:AAMPOSTINCREMENT_LSB
`define TARGETSPECIFIC_RANGE    TARGETSPECIFIC_MSB:TARGETSPECIFIC_LSB

parameter CMDTYPE_ACCESSREG   = `CMDTYPE_WIDTH'h0;
parameter CMDTYPE_QUICKACCESS = `CMDTYPE_WIDTH'h1;
parameter CMDTYPE_ACCESSMEM   = `CMDTYPE_WIDTH'h2;
parameter AARSIZE_32BITS      = `AARSIZE_WIDTH'h2;
parameter AARSIZE_64BITS      = `AARSIZE_WIDTH'h3;
parameter AARSIZE_128BITS     = `AARSIZE_WIDTH'h4;
parameter REGNO_CSR_BASE      = `REGNO_WIDTH'h0000;
parameter REGNO_GPR_BASE      = `REGNO_WIDTH'h1000;
parameter REGNO_FPR_BASE      = `REGNO_WIDTH'h1020;
parameter AAMVIRTUAL_PHYSICAL = `AAMVIRTUAL_WIDTH'h0;
parameter AAMVIRTUAL_VIRTUAL  = `AAMVIRTUAL_WIDTH'h1;
parameter AAMSIZE_8BITS       = `AAMSIZE_WIDTH'h0;
parameter AAMSIZE_16BITS      = `AAMSIZE_WIDTH'h1;
parameter AAMSIZE_32BITS      = `AAMSIZE_WIDTH'h2;
parameter AAMSIZE_64BITS      = `AAMSIZE_WIDTH'h3;
parameter AAMSIZE_128BITS     = `AAMSIZE_WIDTH'h4;

// CUSTOM
parameter REQUEST_VALID_MSB  = 31;
parameter REQUEST_VALID_LSB  = 31;
parameter REQUEST_NUMBER_MSB = 25;
parameter REQUEST_NUMBER_LSB = 20;
`define REQUEST_VALID_WIDTH  1
`define REQUEST_NUMBER_WIDTH 6
`define REQUEST_VALID_RANGE  REQUEST_VALID_MSB:REQUEST_VALID_LSB
`define REQUEST_NUMBER_RANGE REQUEST_NUMBER_MSB:REQUEST_NUMBER_LSB

parameter REQUEST_NUMBER_RESUME  =  0;
parameter REQUEST_NUMBER_SET_GPR =  1;
parameter REQUEST_NUMBER_GET_GPR =  2;
parameter REQUEST_NUMBER_SET_CSR =  3;
parameter REQUEST_NUMBER_GET_CSR =  4;
parameter REQUEST_NUMBER_SET_MEM =  5;
parameter REQUEST_NUMBER_GET_MEM =  6;

parameter CSR_DPC = 12'h7B1;
parameter GPR_S0  = 5'h8;
parameter GPR_S1  = 5'h9;
