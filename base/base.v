module (
    input CLOCK_50,
    output I2C_SCLK,//verificar a frequencia máxima, provavelmente usar pll
    inout I2C_SDAT 
);
    /*
        Não esquecer do mux

        SYSMGR_I2C0USEFPGA = 0;
        SYSMGR_GENERALIO7 = 1;
        SYSMGR_GENERALIO8 = 1;
    */

    /* Visão geral
        R ~W, chuto que 1 é leitura e 0 é escrita

        sempre envio do mias significativo para o menos significativo

        start = 4'b0100

        0x32 DATAX0, parte do x menos significativa
        0x33 DATAX1, parte mais sifnificativa do x

        0x34 DATAY0
        0x35 DATAY1

        0x36 DATAZO
        0x37 DATAZ1
    */

    /* Sequência
        mux
        init

        comunicação de multiplas leituras
            * Por padrão sempre mandamos star [0x400] + 0x53, para iniciar o i2c, informar que o dispositivos que desejamos comunicar é o 0x53, um bit W e esperamos o sinal ACK, que viŕa do slave

            * apos isso indicamos o address que desejaos ler e esperamos novamente o ack, após esse sinal damos um stop e um star

            * novamente enviamos 0x53, para iniciar o i2c, informar que o dispositivos que desejamos comunicar é o 0x53, um bit de Resperamos o sinal ACK, que viŕa do slave

            * agora é p slava que irá enviar os dados, assim que recebemso o dado enviamos o ack para o slave se deu certo, caso contraio o nack, se der certo ele enviara 6 dados, por fim enviamos um stop

    */

     // Send read signal, será que é 4b'0001?
     // *I2C0_DATA_CMD = 0x100; 

endmodule