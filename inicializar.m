function [base_de_dados, numero_de_cidades, numero_de_individuos,...
    pais, filhos, numero_de_geracoes,matriz_de_individuos,melhor_custo,melhor_caminho] = inicializar()
    % Ler a matriz de adjacêndia para ter a base de dados completa (espelhando os dados)
    base_de_dados=readmatrix('matriz_dados.txt');

    %Definir variávies importantes
    numero_de_cidades=length(base_de_dados);
    numero_de_individuos=500;
    matriz_de_individuos=zeros(numero_de_individuos, numero_de_cidades);
    pais = zeros(numero_de_individuos, numero_de_cidades);
    filhos = zeros(numero_de_individuos, numero_de_cidades);
    numero_de_geracoes=500;
    melhor_custo=zeros(1,numero_de_geracoes);
    melhor_caminho=zeros(numero_de_geracoes,numero_de_cidades);
end