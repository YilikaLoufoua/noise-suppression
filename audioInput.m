
function y = audioInput()
    afr = dsp.AudioFileReader('uploads/userUpload.wav');
    adw = audioDeviceWriter(afr.SampleRate);
    completeAudio = [];
    while ~isDone(afr)
        audio = afr();
        adw(audio);
        completeAudio = [completeAudio; audio];
    end
    y=completeAudio;
    release(afr);
    release(adw);
end

