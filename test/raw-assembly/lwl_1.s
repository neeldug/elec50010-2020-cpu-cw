    .align    2
    .globl    main
    .set    nomips16
    .set    nomicromips
    .ent    main
    .type    main, @function
main:
    LI $2, 0x12345678
    LI $3, 0x10000000
    LI $4, 0xaeffdcba
    SW $4, 0($3)
    LWL $2, 1($3)
    JR $31
    .end main
    .set    noreorder
    .set    nomacro

# Expected output would be 0xdcba5678
