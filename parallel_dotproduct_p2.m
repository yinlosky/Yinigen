function result = parallel_dotproduct_p2()
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

[tRow,tCol,tVal] = temp(sprintf('%d,',1:NumOfMachines),:); 
if(~isempty(tVal))
tVal = str2num(tVal);
final = sum(tVal);
else 
final = 0;
end

result = final;
