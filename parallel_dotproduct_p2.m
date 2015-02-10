%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File Name: parallel_dotproduct_p2.m
%% Function: p2 of parallel_dotproduct, which will read all data from dot_temp table and sum them up this can be done locally 

%% Author: Yin Huang
%% Date: Dec 11 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Above will write NumOfMachines result in the temp table
%  Now we need read all of them and add them up into 
final = 0;
myDB;
temp = DB('dot_temp');
output = DB('dot_output');

[tRow,tCol,tVal] = temp(sprintf('%d,',1:NumOfMachines),:); 
tVal = str2num(tVal);
final = sum(tVal);

%for i = 1:NumOfMachines
%	if(~isempty(temp(sprintf('%d,',i),'1,')))
%	tempV = str2num(Val(temp(sprintf('%d,',i),'1,')));
%	else 
%	tempV = 0;
%	end
%	final = final + tempV;
%end

 Result = Assoc('1,','1,',sprintf('%.15f,',final));
 put(output, Result);

dot_result = final;
