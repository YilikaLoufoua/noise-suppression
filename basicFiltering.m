
function filtered_wave_path_list = basicFiltering(all_wav_path_list)
    % Before combine: preprocess clean (is_too_short, is_clipped_wav, is_low_
    % activity, sample_rate==48000, length==10s, 8000hz)
    expectedLength = 10;
    expectedFs = 48000;
    index = 1;
    % filtered_wave_path_list= zeros(1,length(all_wav_path_list));
    filtered_wave_path_list = [""];
    for wav_file_path=1:numel(all_wav_path_list)
        filename = all_wav_path_list(wav_file_path);
        [y, Fs] = audioread(filename);
        time = length(y)./Fs;
        is_not_equal_length = floor(time) ~= expectedLength;
        % is_clipped = check_if_clipped(y);
        % TO-DO
        is_clipped = false;
        is_not_standard_fs = Fs ~= expectedFs;
        if(~is_clipped && ~is_not_equal_length && ~is_not_standard_fs)
            filtered_wave_path_list(index)=filename;
            index = index+1;
        end
    end
    % filtered_wave_path_list = nonzeros(filtered_wave_path_list);
   
end


function is_clipped =  check_if_clipped(y, clipping_threshold)
    if ~exist('clipping_threshold','var')
        clipping_threshold=0.999;
    end
    is_clipped = any(abs(y) > clipping_threshold);
end

