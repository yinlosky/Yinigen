%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%% File Name: parallel_rtv_p2.m
%% Function: This is p2 for calculating rtv, reading data from rtv_temp and sum them up and write to scalar_rtv and 'scalar_rtv'
%%
%% Author: Yin Huang
%% Date: Dec 11, 2014

final = 0;
myDB;
temp = DB('rtv_temp');
output = DB('scalar_rtv');
 [tempR,tempC,tempV] = temp(sprintf('%d,',1:NumOfMachines),:);
	if(isempty(tempV))
	final = 0;
	else
	final = sum(str2num(tempV));
	end
 
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

scalar_rtv =  str2num(Val(output('1,','1,')));
