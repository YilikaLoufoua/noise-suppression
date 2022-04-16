function output = im2col_cus(arr)
output = [];
for index = 1:size(arr, 1)
   curr2D = arr(index,1,:,:);
   curr2D = squeeze(curr2D);
   % unfolded2d = im2col(curr2D, [31,importdata("variable.txt")+2]);
   unfolded2d = im2col_cus_cus(curr2D, 31,importdata("variable.txt")+2);
   unfolded2d = reshape(unfolded2d,[1,size(unfolded2d,1),size(unfolded2d,2)]);
   if(isempty(output))
       output = unfolded2d;
   else 
       output = cat(1, output, unfolded2d);
   end
end
end

function output =  im2col_cus_cus(arr,x, y)
    output = [];
    for index = 1:size(arr,1)-x+1
        block = arr(index:index+x-1,:);
        % result_col = [];
        block = reshape(block.',1,[]);
        %for row = 1:size(block,1)
         %   curr_row = block(row,:);
          %  result_col = [result_col; curr_row'];
        %end
        % output = [output, result_col];
        output = [output, block'];
    end

end

