function formatedArr = permuteCrossChannel(input)
    formatedArr = extractdata(input);
    formatedArr = permute(formatedArr, [1,3,2,4]);
end

