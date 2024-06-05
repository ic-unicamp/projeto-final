sccb_controle(
    input CLOCK_50;
    input SCCB_E;
    input SIO_C;
    inout SIO_D;
    input [7:0] SCCB_DATA;
    input reset;

);

//Temporização do início da transmissão
reg trpa;
reg tpcr;
//Temposiração do final da transmissão
reg tpsa;

