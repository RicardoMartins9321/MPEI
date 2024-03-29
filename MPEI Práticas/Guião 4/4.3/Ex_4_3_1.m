clear all;

% Codigo base para deteção de pares similares

udata=load('u.data'); % Carrega o ficheiro dos dados dos filmes
% Fica apenas com as duas primeiras colunas
u= udata(1:end,1:2); clear udata;

% Lista de utilizadores
users = unique(u(:,1)); % Extrai os IDs dos utilizadores
Nu= length(users); % Número de utilizadores

% Constroi a lista de filmes para cada utilizador
Set= cell(Nu,1); % Usa células

for n = 1:Nu % Para cada utilizador
    % Obtem os filmes de cada um
    ind = find(u(:,1) == users(n));
    % E guarda num array. Usa celulas porque utilizador tem um numero
    % diferente de filmes. Se fossem iguais podia ser um array
    Set{n} = [Set{n} u(ind,2)];
end

% Calcula a distancia de Jaccard entre todos os pares pela definicão
tic;
J=zeros(Nu); % array para guardar distaˆncias
h= waitbar(0,'Calculating');
for n1= 1:Nu
    waitbar(n1/Nu,h);
    for n2= n1+1:Nu
        J(n1,n2)=length(intersect(Set{n1},Set{n2}))/length(union(Set{n1},Set{n2}));  
    end
end
delete (h)
save("distances.mat","J");
fprintf("time to calculate distances: %7.6es\n",toc);

% Com base na distancia, determina pares com
% distancia inferior a um limiar pré-definido 

tic;
threshold =0.4; % limiar de decisão
h= waitbar(0,"Filtering...");
% Array para guardar pares similares (user1, user2, distancia)
SimilarUsers= zeros(1,3); 
k= 1;
for n1= 1:Nu
    waitbar(n1/Nu,h);
    for n2= n1+1:Nu
        if J(n1,n2) < threshold
            SimilarUsers(k,:)= [users(n1) users(n2) J(n1,n2)];
            k= k+1;
        end
    end
end
delete (h);
fprintf("time to filter similar: %7.6es\n",toc);

fprintf("Similar users (%d pairs):\n",height(SimilarUsers));
for n=1:height(SimilarUsers)
    u1 = SimilarUsers(n,1);
    u2 = SimilarUsers(n,2);
    d=J(u1,u2);
    fprintf("Pair (%d;%d): %f\n",u1,u2,d);
end
