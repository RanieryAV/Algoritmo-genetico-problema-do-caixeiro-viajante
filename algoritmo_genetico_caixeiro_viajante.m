%3º Trabalho - Inteligência Computacional - Semestre 2023.1
%Dupla: Raniery Alves Vasconcelos (473532) e João Gabriel Fernandes Gomes (418270)

%1.ª Crie um algoritmo genético para o problema do caixeiro viajante representado por
%um grafo completo não direcionado de 14 vértices (cidades) cuja matriz de adjacência,
%que representa as distâncias entre as cidades, é: [matriz do PDF com 14 cidades]
%O algoritmo deve exibir o melhor caminho encontrado e o seu custo de percurso.

% Limpar o console sempre que executa o código
clear; close all; clc;

%Função para inicializar genericamente e organizar os valores das variáveis
[base_de_dados, numero_de_cidades, numero_de_individuos,...
    pais, filhos, numero_de_geracoes,matriz_de_individuos,...
    melhor_custo,melhor_caminho] = inicializar();

[A,B] = randomizarPontoDeCorte();

matriz_de_individuos = permutarCidades(numero_de_individuos, matriz_de_individuos);
fprintf("O algoritmo vai rodar até a %d geração com %d individuos.\n", numero_de_geracoes,numero_de_individuos);
pause(3)
f = waitbar(0,'Fazendo o cross-over...','Name','Resultados');
%Iterar por todas as gerações (cuja quantidade foi definida anteriormente)
figure('Position', [1000 200 500 500]);
for contador_geracao_atual=1:numero_de_geracoes
    X=estimarCustos(base_de_dados,numero_de_individuos,numero_de_cidades,matriz_de_individuos);    
    %Obter o menor valor e seu índice
    [custo_menor,indice_do_custo_menor]=min(X);
    %Salvar o menor valor de custo
    melhor_custo(1,contador_geracao_atual)=custo_menor;
    %Plotar custos
    plot(X,'m');
    title('Relação entre custo de caminho a cada geração');
    xlabel('Indivíduo no cross-over');
    ylabel('Custo de caminho');
    %Guardar o caminho mais curto encontrado
    melhor_caminho(contador_geracao_atual,:)=matriz_de_individuos(indice_do_custo_menor,:);
    %Registrar a avaliação/nota do processo
    roleta_notas=sum(X);
    
    %Selecionar os pais (roleta)
    pais=selecionarPaisParaCruzamento(pais, X, roleta_notas, matriz_de_individuos, numero_de_individuos);
    
    %Gerar filhos por cross-over
    filhos = zeros(numero_de_individuos, numero_de_cidades);
    try
        filhos = fazerCrossOver(filhos, pais, numero_de_individuos, numero_de_cidades, A, B);
    
        %Mutação aplicada em individuo (promover diversidade)
        filhos=ativarMutacao(numero_de_individuos, filhos);
    
        troca = randi(numero_de_geracoes);
        filhos(troca, :) = matriz_de_individuos(indice_do_custo_menor, :);
        matriz_de_individuos = filhos;
        fprintf("Geracao_atual: %d\n",contador_geracao_atual);
    
        fecharJanelaDeCarregamento(f, contador_geracao_atual, numero_de_geracoes);
    catch
        warning(['Unable to perform assignment because the indices on the left side...' ...
            ' are not compatible with the size of the right side.']);
    end
end
exibirResultadosNoConsole(numero_de_geracoes, numero_de_individuos, melhor_custo, numero_de_cidades, melhor_caminho);
pause(8)
delete(findall(0));

%********************************************************
%Abaixo estão as definições das funções usadas no código*
%********************************************************
function retorno_custos = estimarCustos(base_dados, quantidade_de_individuos,...
    quantidade_de_cidades, array_de_individuos)

    retorno_custos=zeros(1,quantidade_de_individuos);
    for contador_linha=1:quantidade_de_individuos
        custo_aux=0;
        for contador_coluna=1:quantidade_de_cidades
            if contador_coluna == quantidade_de_cidades%Se chegarmos na outra extremidade
                                                        %do indivíduo...
                custo_aux = custo_aux + base_dados(array_de_individuos(contador_linha,...
                    contador_coluna), array_de_individuos(contador_linha,1));
                %Teste do cálculo da distância (custo) entre duas cidades
            else %Se AINDA NÃO tivermos chegado na outra extremidade do indivíduo...
                custo_aux = custo_aux + base_dados(array_de_individuos(contador_linha,...
                    contador_coluna), array_de_individuos(contador_linha,contador_coluna+1));
            end
        end
        retorno_custos(1,contador_linha)=custo_aux;
    end
    %fprintf("\n-----------------------------------------------------------\n\n");
end

function pais = selecionarPaisParaCruzamento(pais, avaliacao_nota, roleta_notas, matriz_de_individuos, numero_de_individuos)
    %Selecionar o pai para cruzamento
    for cont=1:numero_de_individuos
        valor_sorteio=rand*roleta_notas;%"rand" é uma palavra do MATLAB que retorna valor aleatório entre 0 e 1
        somatorio=avaliacao_nota(1);
        for var_cont=1:numero_de_individuos
            if valor_sorteio < somatorio
                pais(cont,:)=matriz_de_individuos(var_cont,:);
                break
            else
                somatorio=somatorio+avaliacao_nota(var_cont+1);
            end
        end
    end
end

function exibirResultadosNoConsole(numero_de_geracoes, numero_de_individuos, melhor_custo, numero_de_cidades, melhor_caminho)
    %Mostrar resultados no console do MATLAB
    fprintf(['-->Configuração com %d individuos e %d gerações (execute o código outras vezes para ver variações na eficácia da busca do menor caminho):\n\n' ...
        '- Menor custo    = %d\n- Melhor caminho = ['], numero_de_individuos, numero_de_geracoes, melhor_custo(numero_de_geracoes))
    for count = 1:numero_de_cidades
        fprintf(' %d ', melhor_caminho(numero_de_geracoes, count))
    end
    fprintf(']\n\n')
end

function filhos = ativarMutacao(numero_de_individuos, filhos)
    for i = 1:numero_de_individuos
        if rand <= 0.01
            indices = randperm(14, 2);
            auxiliar = filhos(i, indices(1));
            filhos(i, indices(1)) = filhos(i, indices(2));
            filhos(i, indices(2)) = auxiliar;
        end
    end
end

function [A,B] = randomizarPontoDeCorte()
    %Selecionar pontos aleatórios de corte para gerar os novos indivíduos
    A = randi(1,13);
    B = randi(1,13);
    parcela_de_B=round(B*rand*10);
    if parcela_de_B==0%Impedir que "parcela_de_B" seja igual a zero
        parcela_de_B=1;
    end
    %fprintf("\nparcela_de_B=%d\n",parcela_de_B);
    while(A>parcela_de_B)
        A = randi(1,13);
    end
end

function matriz_de_individuos = permutarCidades(numero_de_individuos, matriz_de_individuos)
    %Criar permutações aleatórias das cidades 01 a 14 na quantidade definida em "numero_de_individuos"
    for contador=1:numero_de_individuos
        matriz_de_individuos(contador,:)=randperm(14,14);
    end
end

function filhos = fazerCrossOver(filhos, pais, numero_de_individuos,numero_de_cidades,A, B)
    try
        for i = 1:2:numero_de_individuos
            %Seleciona pontos_de_corte
            pontos_de_corte = [A B];
            filhos(i, :) = [filhos(i,1:pontos_de_corte(A)), pais(i+1, pontos_de_corte(A)+1:pontos_de_corte(B)), filhos(i, pontos_de_corte(B)+1:numero_de_cidades)];
            filhos(i+1, :) = [filhos(i+1,1:pontos_de_corte(A)), pais(i, pontos_de_corte(A)+1:pontos_de_corte(B)), filhos(i+1, pontos_de_corte(B)+1:numero_de_cidades)];
            
            dentro_do_ponto = busca_diferente([filhos(i, :), filhos(i+1, :)]);
            dentro_do_ponto = dentro_do_ponto(dentro_do_ponto~=0);
            fora_do_ponto = [];
        
            for j = 1:numero_de_cidades
                if buscar(dentro_do_ponto == j) > 0
                    %Tem no ponto de corte
                else
                    %Não tem, então insere no filho
                    filhos(i, buscar(pais(i, :) == j)) = j;
                    filhos(i+1, buscar(pais(i+1, :) == j)) = j;
                    fora_do_ponto = [fora_do_ponto j];
                end
            end
            
            variavel1_para_salvar = [];
            variavel2_para_salvar = [];
            f = filhos(i+1, pontos_de_corte(A)+1:pontos_de_corte(B));
            h = filhos(i, pontos_de_corte(A)+1:pontos_de_corte(B));
    
            for j = 1:length(f)
                if buscar(h == f(j)) > 0
                else
                    variavel1_para_salvar = [variavel1_para_salvar, f(j)];
                end
            end
    
            for j = 1:length(h)
                if buscar(f == h(j)) > 0
                else
                    variavel2_para_salvar = [variavel2_para_salvar, h(j)];
                end
            end
    
            primeiro_zero = buscar(filhos(i, :) == 0);
            segundo_zero = buscar(filhos(i+1, :) == 0);
            fprintf('')
            for j = 1:length(primeiro_zero)
                filhos(i, primeiro_zero(j)) = variavel1_para_salvar(j);
            end
            for j = 1:length(segundo_zero)
                filhos(i+1, segundo_zero(j)) = variavel2_para_salvar(j);
            end
        end
    catch
        warning(['Unable to perform assignment because the indices on the left side...' ...
            ' are not compatible with the size of the right side.']);
    end
end

function indices = buscar(condicao)
    %Guarda os indices
    indices = [];
   
    for i = 1:length(condicao)
        %Verifica se a condição é verdadeira para o elemento atual
        if condicao(i)
            %Incluir o indice dentro do array de indices
            indices = [indices, i];
        end
    end
end

function valoresUnicos = busca_diferente(array)
    %Inicializar um array vazio para armazenar os valores que são únicos
    valoresUnicos = [];
    
    %Percorrer os elementos do vetor de entrada
    for i = 1:numel(array)
        %Averiguar se o elemento atual já está no array valoresUnicos
        if ~Testes_diferentes_treino(array(i), valoresUnicos)
            %Colocar o valor único recém-encontrado no vetor valoresUnicos
            valoresUnicos = [valoresUnicos, array(i)];
        end
    end
end

function fecharJanelaDeCarregamento(janela_feedback, contador_geracao_atual, numero_de_geracoes)
    %Controle da janela de carregamento (feedback visual para o usuário)
    janela_feedback = waitbar((contador_geracao_atual/numero_de_geracoes));
    if(contador_geracao_atual == numero_de_geracoes)
        close(janela_feedback);
        janela_feedback = waitbar((contador_geracao_atual/numero_de_geracoes),'Concluido!');
    end
end

function result = Testes_diferentes_treino(vetor1, vetor2)
    vetor1 = vetor1(:);
    vetor2 = vetor2(:);
    [~, odernador] = sort([vetor1; vetor2]);
    numero_vetor1 = numel(vetor1);
    indice_ordenado_vetor1 = odernador(odernador <= numero_vetor1);
    indice_ordenado_vetor2 = odernador(odernador > numero_vetor1) - numero_vetor1;
    result = vetor1(~contem(indice_ordenado_vetor1, indice_ordenado_vetor2));
end

function [C, D] = contem(A, B)
    C = false(size(A));
    D = zeros(size(A));
    
    for i = 1:numel(A)
        for j = 1:numel(B)
            if A(i) == B(j)
                C(i) = true;
                D(i) = j;
                break;
            end
        end
    end
end
