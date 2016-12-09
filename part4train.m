function part4train(which, LRaswell)
    trainingSet = [];
    load part4train.mat trainingSet;
    trainingSet = trainingSet(arrayfun(@(x) ~isempty(x.candidates), trainingSet));
    sample_size = size(trainingSet, 1);
    features = zeros(sample_size, 14);
    label =cell(sample_size, 1);

    for i=1:sample_size
        current = trainingSet(i);
        features(i,:) = transpose([current.candidates(:,1); current.candidates(:,2)]);
        label{i} = current.type;
    end
    
    if LRaswell
        % Seperate into L/R handed throws. Not yet implemented
    end
        

    if (strcmp(which, 'SVM'))
        t = templateSVM('KernelFunction','gaussian','KernelScale','auto');
        pitchClassModelSVM = fitcecoc(features,label, 'Learners', t, 'Coding', 'onevsall');
        save pitchClassModelSVM.mat pitchClassModelSVM;
        
    elseif (strcmp(which, 'KNN'))
        pitchClassModelKNN = fitcknn(features,label,'NumNeighbors',7);
        save pitchClassModelKNN.mat pitchClassModelKNN;
        
    elseif (strcmp(which, 'AverageWeights'))
        classes = unique(label);
        classCounts = zeros(size(classes));
        centroids = zeros(length(classes), 14);
        for i=1:length(label)
            [~, idx] = ismember(label(i),classes);
            classCounts(idx) = classCounts(idx) +1;
            centroids(idx,:) = centroids(idx,:) + features(idx,:);
        end
        
        pitchClassModelAW.ClassNames = classes;
        pitchClassModelAW.Centroids = centroids ./ classCounts;
        save pitchClassModelAW.mat pitchClassModelAW;
    end
            
end
