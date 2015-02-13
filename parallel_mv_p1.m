%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Name:parallel_mv_p1.m
% Function: this is the p1 of mv in parallel, input matrix is 'InputMatrix', input vector table should read the current iteration value from cur_it table
%
tic;
myDB; %% connect to DB and return a binding named DB.

machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');
cur_it = DB('cur_it');


NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));
vector = [num2str(NumOfNodes) 'lz_q' num2str(str2num(Val(cur_it('1,','1,'))))];


disp(['!!!!!!!Now running matrix multiply the vector!!!!!!!!!!!!!']);
disp(['********matrix:  InputMatrix  times vector: ' vector ' into mv_temp ************']);

m = DB(['M' num2str(NumOfNodes)]);
v = DB(vector);
temp = DB('mv_temp'); %%hard coded temporary output table


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% parallel part %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% For now split is evenly distributed among the machines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gap = floor(NumOfNodes / NumOfMachines);
myMachine = 1:NumOfMachines;
w = zeros(NumOfMachines,1,map([Np 1],{},0:Np-1));
myMachine = global_ind(w); %Parallel



for i = myMachine

        start_node = (i-1)*gap+1;
        if (i<NumOfMachines)
        end_node = i*gap ;
        else
        end_node = NumOfNodes ;
        end

        %% supposed to read all columns, but d4m only support read all rows luckily matrix is symmetric, so when we 
        % write back to the table we switch the column and the row.
        ColsOfMatrix = m(sprintf('%d,',start_node:end_node),:);  

      
        
        % Store the result for building up the associative arrays
        ArowStr='';
        AcolStr='';
        AvalStr='';
        
    for j = start_node:end_node
	    %disp(['current j is:' num2str(j)]);
	    [JR, JC, JCol] = ColsOfMatrix(:,sprintf('%d,',j));
        
        if(~isempty(JCol))
         JCol = str2num(JCol);
            JR = str2num(JR);
            JC = str2num(JC);
        
            if(~isempty(Val(v(sprintf('%d,',j),:))))
             Jvector = str2num(Val(v(sprintf('%d,',j),:)));
            else 
             Jvector = 0;
            end

         JCol = JCol .* Jvector;
         rowStr = sprintf('%d,',JR);
         colStr = sprintf('%d,',JC);
         valStr = sprintf('%.15f,',JCol);
         ArowStr = strcat(ArowStr,rowStr);
         AcolStr = strcat(AcolStr,colStr);
         AvalStr = strcat(AvalStr,valStr);
        end
    end	
        put(temp,Assoc(ArowStr,AcolStr,AvalStr));
end
totalT=toc;
disp(['Total Running time is: ' num2str(totalT)]);
tic;
agg(w);
waitingT=toc;
disp(['Total syn time is: ' num2str(waitingT)]);

%{
tic;
myDB; %% connect to DB and return a binding named DB.

machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');
cur_it = DB('cur_it');


NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));
vectorName = [num2str(NumOfNodes) 'lz_q' num2str(str2num(Val(cur_it('1,','1,'))))];


disp(['!!!!!!!Now running matrix multiply the vector!!!!!!!!!!!!!']);
disp(['********matrix:  InputMatrix  times vector: ' vectorName ' into mv_temp ************']);

m = DB(['M' num2str(NumOfNodes)]);
v = DB(vectorName);
temp = DB(['mv_temp']); %%hard coded temporary output table


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% parallel part %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% For now split is evenly distributed among the machines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gap = floor(NumOfNodes / NumOfMachines);
myMachine = 1:NumOfMachines;
w = zeros(NumOfMachines,1,map([Np 1],{},0:Np-1));
myMachine = global_ind(w); %Parallel



for i = myMachine

        start_node = (i-1)*gap+1;
        if (i<NumOfMachines)
        end_node = i*gap ;
        else
        end_node = NumOfNodes ;
        end
%**************************************************************
        queryStr = sprintf('%d,',start_node:end_node);

        myIt = Iterator(m,'elements', NumOfNodes);
        Matrix = myIt(queryStr,:);

        vectorIt = Iterator(v,'elements',ceil(NumOfNodes/NumOfMachines));
        Vector = vectorIt(queryStr,:);

        rowStr='';
        colStr='';
        valStr='';
     
        while ( nnz(Matrix) && nnz(Vector) )
            [Mr,Mc,Mv] = Matrix(:,:);
            [Vr,Vc,Vv] = Vector(:,:);
            if(~isempty(Mv) && ~isempty(Vv))
                Mr=str2num(Mr); Mc = str2num(Mc);
                Mv= str2num(Mv)
                Vv = str2num(Vv)
                Mv = Mv * Vv;
                valStr = strcat(valStr,sprintf('%.15f,',Mv));
                rowStr = strcat(rowStr, sprintf('%d,', Mr));
                colStr = strcat(colStr,sprintf('%d,',Mc));
            end 
            Matrix =myIt();
            Vector =vectorIt();
        end
        put(temp,Assoc(colStr,rowStr,valStr));
end
totalT=toc;
disp(['Total Running time is: ' num2str(totalT)]);
tic;
agg(w);
waitingT=toc;
disp(['Total syn time is: ' num2str(waitingT)]);
%}


