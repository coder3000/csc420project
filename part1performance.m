function part1performance() 
    [vote, total] = test('pitching');
    fprintf('Pitching scenes: voted %d/%d true. %f%% accurate.\n', vote, total, vote/total*100);
    [vote, total] = test('nonpitching');
    fprintf('Nonpitching scenes: voted %d/%d true. %f%% accurate.\n', (total-vote), total, (total-vote)/total*100);
end

function [truecount, pitchingNumFiles] = test(folder)
    load sceneModel;
    pitchingFiles = dir(['part1test/' folder '/*.jpg']); 
    pitchingNumFiles = length(pitchingFiles);
    truecount = 0;

    for k = 1:pitchingNumFiles
        im = imread(['part1test/' folder '/' pitchingFiles(k).name]);
        feature = sceneFeature(im);
        if predict(sceneModel, feature)
            truecount = truecount + 1;
        end
    end
end
