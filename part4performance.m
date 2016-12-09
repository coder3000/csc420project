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
        KNNmodel = [];
        load KNNmodel.mat KNNmodel;
        predicts = predict(KNNmodel, features);
        
    elseif (strcmp(mode, 'SVM'))
        SVMmodel = [];
        load SVMmodel.mat SVMmodel;
        predicts = predict(SVMmodel, features);
        
    elseif (strcmp(mode, 'AverageWeights'))
        AWmodel = [];
        load AWmodel.mat AWmodel;
        distances = pdist2(features, AWmodel.Centroids);
        [~,minidx] = min(distances, [], 2);
        predicts = AWmodel.ClassNames(minidx);
    end
    
    match = cellfun(@strcmp, predicts, label);
    match(match==0) = [];
    fprintf('Accuracy of %s: %f%%\n', mode, 100*length(match)/length(label));
        
end