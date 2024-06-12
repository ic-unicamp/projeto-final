# Projeto final de MC613 - 2024s1

Grupo: arejado e sem odor

- 260640 - Pedro Damasceno Vasconcellos
- 251027 - Filipe Franco Ferreira
- 260440 - Francisco Vinicius Sousa Guedes
## Descrição

Projeto em uma placa FPGA DECSOC-1 em que foi implementado um programa semelhante ao Paint, em que o cursor é movido detectando a posição da mão do usuário. Isso é feito utilizando uma câmera e uma luva verde. São implementadas as funcionalidades de pintura, borracha, mudar o tamanho do pincel, e mostrar a imagem da câmera, destacando as posições verdes detectadas. O processo de detecção da mão é feito analisando os os limites de valores de YCbCr para a cor verde, e quando um certo número de pixels verdes são detectados em sequência o programa considera que a luva foi achada e que o pixel nao é ruído.


A tela de pintura é guardada em uma memória implementada na placa, e tem suporte para 512 cores diferentes, variando os valores R, G e B da cor de 0 a 224 em incrementos de 32.
