function [A] = tabread(data,col)
%tabread reads data from table and writes as array of numbers
data_table = data{:,col};
A = zeros(length(data_table),1);
for i=1:length(data_table)
    A(i) = str2double(cell2mat(data_table(i)));
end
end