%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Name:parallel_mv_p1.m
% Function: this is the p1 of mv in parallel, input matrix is 'InputMatrix', input vector table should read the current iteration value from cur_it table
%
myDB; %% connect to DB and return a binding named DB.
machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');
cur_it = DB('cur_it');
%inputm_t = DB('InputMatrixName');

NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));
vector = ['lz_q' num2str(str2num(Val(cur_it('1,','1,'))))];
%inputmatrix_name = sprintf('%s',Val(inputm_t('1,','1,')) )

disp(['!!!!!!!Now running matrix multiply the vector!!!!!!!!!!!!!']);
disp(['********matrix:  InputMatrix  times vector: ' vector ' into mv_temp ************']);

m = DB('InputMatrix');
v = DB(vector);
temp = DB('mv_temp'); %%hard coded temporary output table

gap = floor(NumOfNodes / NumOfMachines);

myMachine = 1:NumOfMachines;
w = zeros(NumOfMachines,1,map([Np 1],{},0:Np-1));
myMachine = global_ind(w); %Parallel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% For now split is evenly distributed among the machines
%%%
%%%
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = myMachine

        start_node = (i-1)*gap+1;
        if (i<NumOfMachines)
        end_node = i*gap ;
        else
        end_node = NumOfNodes ;
        end
       for j = start_node:end_node
	disp(['current j is:' num2str(j)]);
	[row,col,val] = m(:,sprintf('%d,',j));  %% Get all the rows from col j from input matrix!!
	if(~isempty(val))     % if v is empty do nothing
         [vectorR,vectorC,vectorV] = v(sprintf('%d,',j),'1,'); % everything returns from associative array is string
        vectorV = str2num(vectorV);  % get the integer num of vectorV
	matrixV = str2num(val);    
	matrixV = matrixV .* vectorV;
	valStr = sprintf('%.15f,',matrixV);
        rowStr = sprintf('%d,',str2num(row));                % rowStr is all the row id from matrix from col j
	colStr = sprintf('%d,',j);
	put(temp,Assoc(rowStr,colStr,valStr));
	end
	end
end
agg(w);
%        myRow = str2num(Row(m(:,sprintf('%d,',j))));
%        vector_j = str2num(Val(v(sprintf('%d,',j),'1,')));
%        [M,N] = size(myRow);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                if (M>0)
%                for i=1:M
%                matrix_i = str2num(Val(m(sprintf('%d,',myRow(i)),sprintf('%d,',j))));
%                newVal= matrix_i * vector_j;
%                newAssoc = Assoc(sprintf('%d,',myRow(i)),sprintf('%d,',j),sprintf('%.15f,',newVal));
%                put(temp,newAssoc);
%                end (if)
%                end (for)
%        end   (if)
%        end  (for)


% end
%agg(w);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%for i = myMachine
%
%        start_node = (i-1)*gap+1;
%	if (i<NumOfMachines)
%	end_node = i*gap ;
%	else 
%	end_node = NumOfNodes ;
%	end
%	for j = start_node:end_node
%
%	disp(['current j is:' num2str(j)]);
%	[Mm,Nn]=size(Row(m(:,sprintf('%d,',j))));   %Nn will tell if m has 0 elements 
%        if(Nn ~= 0)                             %Do only when m has elements
%	myRow = str2num(Row(m(:,sprintf('%d,',j))));
%	vector_j = str2num(Val(v(sprintf('%d,',j),'1,')));
%	[M,N] = size(myRow);
%	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		if (M>0)
%		for i=1:M
%		matrix_i = str2num(Val(m(sprintf('%d,',myRow(i)),sprintf('%d,',j))));
%		newVal= matrix_i * vector_j;
%		newAssoc = Assoc(sprintf('%d,',myRow(i)),sprintf('%d,',j),sprintf('%.15f,',newVal));
%		put(temp,newAssoc);
%		end
%		end
%	end
%	end
%	
%
% end
%agg(w);


