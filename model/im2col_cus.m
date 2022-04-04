function output = im2col_cus(arr)
output = [];
for index = 1:size(arr, 1)
   curr2D = arr(index,1,:,:);
   curr2D = squeeze(curr2D);
   unfolded2d = im2col(curr2D, [31,importdata("variable.txt")+2]);
   unfolded2d = reshape(unfolded2d,[1,size(unfolded2d,1),size(unfolded2d,2)]);
   if(isempty(output))
       output = unfolded2d;
   else 
       output = cat(1, output, unfolded2d);
   end
end
end

