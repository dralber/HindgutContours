 function frames2movie(frames, fileName, frameRate)
% Takes an input array of frames and the full directory + filename and
% writes a movie.
%
% Author: Daniel Alber
% Date: 10/16/2023
%
% Usage: frames2movie(movieFrames,...
%     [dirName '\' datestr(datetime('today'),'yymmdd') '_view_' ...
%     int2str(setView(1)) '_' int2str(setView(2)) '_movie.mj2']);
% Inputs: frame - cell array of frame, i.e.: frames(i) = {getframe(gcf)};
%       fileName: full directory and file name of output file
% Notes: to convert into a ppt format, ffmpeg settings:
%       ffmpeg -i input.mp4 -vf "setpts=2.0*PTS" -c:v libx264 -crf 18 output.mp4
%       where setpts is the amount of slowing in the converted file
if isempty(frameRate)
    frameRate = 26;
end
v = VideoWriter(fileName, 'MPEG-4');
v.FrameRate = frameRate;
v.Quality = 100;
open(v);
for i=1:length(frames)
    writeVideo(v,frames{i});
end
close(v);

end