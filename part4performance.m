function part4performance(mode)
    %% Test on training set
    testSet = [];
    load part4test.mat testSet;
    testSet = testSet(arrayfun(@(x) ~isempty(x.candidates), testSet));
    sample_size = size(testSet, 1);
    features = zeros(sample_size, 14);
    label =cell(sample_size, 1);

    for i=1:sample_size
        current = testSet(i);
        features(i,:) = transpose([current.candidates(:,1); current.candidates(:,2)]);
        label{i} = current.type;
    end

    if (strcmp(mode, 'KNN'))
        pitchClassModelKNN = [];
        load pitchClassModelKNN.mat pitchClassModelKNN;
        predicts = predict(pitchClassModelKNN, features);
        
    elseif (strcmp(mode, 'SVM'))
        pitchClassModelSVM = [];
        load pitchClassModelSVM.mat pitchClassModelSVM;
        predicts = predict(pitchClassModelSVM, features);
        
    elseif (strcmp(mode, 'AverageWeights'))
        pitchClassModelAW = [];
        load pitchClassModelAW.mat pitchClassModelAW;
        distances = pdist2(features, pitchClassModelAW.Centroids);
        [~,minidx] = min(distances, [], 2);
        predicts = pitchClassModelAW.ClassNames(minidx);
    end
    
    match = cellfun(@strcmp, predicts, label);
    match(match==0) = [];
    fprintf('Accuracy of %s: %f%%\n', mode, 100*length(match)/length(label));
        
end