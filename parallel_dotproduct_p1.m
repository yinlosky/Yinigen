%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File Name: parallel_dotproduct_p1.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This is the function for alph_i = v_i'.*v (two vectors dotproduct) // both vectors are dense.
%% Input: 
%%  	para1: 'lz_vpath'
%%	para2: vector 2
%%   	para3: Num of nodes in the graph
%% 	para4: Num of machines for parallelization
%% Output: 
%%      Return the value of dot_prodcut R
%%      dot_output table will be created and saved 
%% ------------This function requires some optimization for matrix partition and load balancing------
%% For now I am simply evenly splitting the columns among different processros
%%
%%
%%
%% This is an embarassing parallel job, need attention for parallelization
%%
%% Author: Yin Huang
%% Date: Nov,30,2014
%% Usage: dotprodcut('test_dot1','test_dot2',3,2)

tic;

myDB; %% connect to DB and return a binding named DB.
machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');
cur_it = DB('cur_it');

NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));
vector = [num2str(NumOfNodes) 'lz_q' num2str(str2num(Val(cur_it('1,','1,'))))];
v = DB([num2str(NumOfNodes) 'lz_vpath']); 
vi = DB(vector);

%output table dot_temp
temp = DB('dot_temp');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   Parallel part %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gap = floor(NumOfNodes / NumOfMachines);
w = zeros(NumOfMachines,1,map([Np 1],{},0:Np-1));
myMachine = global_ind(w); %Parallel

for i = myMachine
	
        start_node = (i-1)*gap+1;
	if (i<NumOfMachines)
	end_node = i*gap ;
	else 
	end_node = NumOfNodes ;
	end
	disp(['start index: ' num2str(start_node) ' end index: ' num2str(end_node)]);

	temp_sum = 0;
    vAll = v(sprintf('%d,',start_node:end_node),:);
    viAll = vi(sprintf('%d,',start_node:end_node),:);	

for j = start_node:end_node  % j is the row_id for the vector! We need to multiply the element from the same row_id. 

        if(~isempty(Val(vAll(sprintf('%d,',j),'1,'))))
        x = str2num(Val(vAll(sprintf('%d,',j),'1,')));
        else
        x = 0;
        end
        if(~isempty(Val(viAll(sprintf('%d,',j),'1,'))))
        y = str2num(Val(viAll(sprintf('%d,',j),'1,')));
        else
        y = 0;
        end
        temp_sum = temp_sum + x * y;
 end
  newAssoc = Assoc(sprintf('%d,',i),'1,',sprintf('%.15f,',temp_sum));
  put(temp,newAssoc);
end

totalT=toc;
disp(['Total Running time is: ' num2str(totalT)]);
tic;
agg(w);
waitingT=toc;
disp(['Total syn time is: ' num2str(waitingT)]);

