%% Clear matlab console and close other m files    
clc;
clear;
close all;

%% Define global variables
global names info;

%% Load input data from excel
disp("Loading......");

[raw_topic, raw_student, raw_time] = load_data();
[info, names] = parse_data(raw_topic, raw_student, raw_time);
tsize = length(info);
nsize = length(names);

%% Initialize routine for DPSO
pcnt = 200;
maxLoop = 1000;

w = 0.9;
c1 = 0.8;
c2 = 0.7;

%% Initialize particles
% X : current position of particle
% XL : goal position of particle

for k = 1: pcnt
    % nsize : students
    % tsize : topic count
    p(k).X = randperm(nsize, tsize);
    p(k).XL = randperm(nsize, tsize);
end

%% Initialize swarm
gBest = f(p(1).XL);
for i = 1: pcnt
    if f(p(i).XL) <= gBest
        gBest = f(p(i).XL);
        XG = p(i).XL;
    end
end

%% Update particles
% update function in DPSO is as follows
%
% Xi = c2 @ CR2(c1 @ CR1(w @ DC(Xi), Pi), G)
%
% i : particle index
% w : inertia
% c1 : [0, 1]
% c2 : [0, 1]
% CR1 : one-cut crossover operator
% CR2 : two-cut crossover operator
% DC : destruction operator
% Xi : ith particle's position
% Pi : ith particle's local best position
% G : global best position

% for cost graph
cost = zeros(1, maxLoop);

for loop = 1: maxLoop
    % update particles based on s_pos
    % xL : local best position
    % xG : global best position
    % gBest : global best fitness value
    for i = 1: pcnt
        r = rand;

        % destruction
        if (r < w)
            lamda = DC(p(i).X);
        else
            lamda = p(i).X;
        end
        
        % local best position
        if (r < c1)
            delta = CR1(lamda, p(i).XL);
        else
            delta = lamda;
        end
        
        % global best position
        if (r < c2)
            p(i).X = CR2(delta, XG);
        else
            p(i).X = delta;
        end
        
        % evaluate fitness and update local best position
        fitValue = f(p(i).X);
        if fitValue < f(p(i).XL)
            p(i).XL = p(i).X;
        end
    end

    % update sworm
    for i = 1: pcnt
        if f(p(i).XL) <= gBest
            gBest = f(p(i).XL);
            XG = p(i).XL;
        end
    end
    
    % save global best fitness of ith loop
    cost(loop) = gBest;
end

%% Write to XLSX file
topic = "";
name = "";
choice = "";
date = "";
category = zeros(1, 3);

for i = 1: tsize
    topic(i) = info(i).topic;
    student_name = names(XG(i));
    
    option = "Not selected";
    request = "Unknown";
    if ~isempty(info(i).name)
        name_id = find(info(i).name == student_name);
        if ~isempty(name_id)
            idx = info(i).choice(name_id);
            switch idx
                case 1
                    option = "1st choice";
                case 2
                    option = "2nd choice";
                case 3
                    option = "3rd choice";
            end
            request = info(i).date(name_id);
            category(idx) = category(idx) + 1;
        end
    end
    name(i) = student_name;
    choice(i) = option;
    date(i) = request;
end
data = [topic' name' choice' date'];
xlswrite('report.xlsx', data);

%% Output result
% display graph
loop = 1: maxLoop;
plot(loop, cost, 'r');
grid on;
title('DPSO ALGORITHM')
xlabel('Loop');
ylabel('Cost');

% display choice list
disp("1st choice --------> " + category(1));
disp("2nd choice --------> " + category(2));
disp("3rd choice --------> " + category(3));

%% Release memory
clear;

%% Destruction operator
function y = DC(X)
    % get exchange indice by randomization
    xsize = length(X);
    range = randi(xsize, 1, 2);
    first = range(1);
    second = range(2);
    
    % swap two elements
    tmp = X(first);
    X(first) = X(second);
    X(second) = tmp;
    
    % return
    y = X;
end

%% Crossover operator : one-cut
function y = CR1(X, Y)
    % get one-cut point by randomization
    xsize = length(X);
    index = randi(xsize);
    
    % crossover two particles
    codes = Y(index:xsize);
    [~, id] = ismember(codes, X);
    id = sort(id);
    
    k = 1;
    for i = 1: length(id)
        if id(i) ~= 0
           X(id(i)) = codes(k);
           k = k + 1;
        end
    end
    
    y = X;
end

%% Crossover operator : two-cut
function y = CR2(X, Y)
    % get two-cut points by randomization
    xsize = length(X);
    range = randi(xsize, 1, 2);
    first = range(1);
    last = range(2);
    
    % crossover two particles
    codes = X(first:last);
    refcodes = Y(first:last);

    X(first:last) = refcodes;
    for i = 1: first - 1
        [TF, id] = ismember(X(i), refcodes);
        if TF
            X(i) = codes(id);
            [STF, sid] = ismember(codes(id), refcodes);
            while STF
                X(i) = codes(sid);
                [STF, sid] = ismember(codes(sid), refcodes);
            end
        end
    end
    
    for i = last + 1: xsize
        [TF, id] = ismember(X(i), refcodes);
        if TF
            X(i) = codes(id);
            [STF, sid] = ismember(codes(id), refcodes);
            while STF
                X(i) = codes(sid);
                [STF, sid] = ismember(codes(sid), refcodes);
            end
        end
    end
    
    % return
    y = X;
end

%% Calculate the fitness
function y = f(val)
    global info names;

    % initial fitness value
    y = 0;
    for i = 1: length(val)
        score = 450;        % this is for penalty score
        idx = val(i);       % get the ith value - name id
        
        % get the student id in each project
        if ~isempty(info(i).name)         
            TF = contains(info(i).name, names(idx));
            [mval, id] = max(TF);

            % if name exists
            if mval == 1
                score = score - 220;

                % search his/her choice for project
               ch_id = info(i).choice(id); 
                switch ch_id
                    case 1
                        score = score - 150;
                    case 2
                        score = score - 100;
                    case 3
                        score = score - 50;
                end
                
                % extract same choice student
                indice = info(i).choice == ch_id;
                ext_order = info(i).order(indice);
                ext_order = sort(ext_order);
                
                % search proposed time for project
                [~, idx] = ismember(info(i).order(id), ext_order);
                switch idx
                    case 1
                        score = score - 80;
                    case 2
                        score = score - 50;
                    case 3
                        score = score - 20;
                end
            end
        end
        
        % return fitness
        y = y + score;
    end
    y = y / length(val);
end