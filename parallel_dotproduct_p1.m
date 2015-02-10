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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% variables %%

myDB; %% connect to DB and return a binding named DB.
machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');
cur_it = DB('cur_it');

NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));
vector = ['lz_q' num2str(str2num(Val(cur_it('1,','1,'))))];

v = DB('lz_vpath'); 
vi = DB(vector);

temp = DB('dot_temp');

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Two approaches for this embarassing parallel job, one is to multiply one pair once and then sum them up, the other is use iterator 
% Not sure which is faster!!! For now I am taking the first approach.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% from previous step we have guaranteed that the vi and v are all filled with values
%% when use the range query the returned val string is not sorted in numerical order, but we have filled them will 0s, so the sequence of returned value is the same
   %  [vRow,vCol,vVal] = v(sprintf('%d,',start_node:end_node),:); 
   %  [viRow,viCol,viVal]= vi(sprintf('%d,',start_node:end_node),:);
%	vVal = str2num(vVal);
%	viVal = str2num(viVal);
%	temp_sum = viVal.' * vVal;
%	put(temp, Assoc(sprintf('%d,',i),'1,',sprintf('%.15f',temp_sum)));
	temp_sum = 0;
for j = start_node:end_node  % j is the row_id for the vector! We need to multiply the element from the same row_id. 
	
	if(~isempty(v(sprintf('%d,',j),'1,')))
	x = str2num(Val(v(sprintf('%d,',j),'1,')));
	else 
	x = 0;
	end
	if(~isempty(vi(sprintf('%d,',j),'1,')))
	y = str2num(Val(vi(sprintf('%d,',j),'1,')));
	else
	y = 0;
	end
	temp_sum = temp_sum + x * y;
	end 
  newAssoc = Assoc(sprintf('%d,',i),'1,',sprintf('%.15f,',temp_sum));
  put(temp,newAssoc);
end 
agg(w);

