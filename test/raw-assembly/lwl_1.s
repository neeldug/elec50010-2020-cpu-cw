    .align    2
    .globl    main
    .set    nomips16
    .set    nomicromips
    .ent    main
    .type    main, @function
main:
    MOVE $2, $0
    LI $3, 0x10000000
    LI $4, 0x00000016
    SW $4, 0($3)
    LWL $2, 3($3)
    SRL $2, $2, 24
    JR $31
    .end main
        .set    noreorder
        .set    nomacro
