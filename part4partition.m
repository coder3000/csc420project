function part4partition(testRatio) % test set/all
    samples = [];
    load part4samples.mat samples;
    shuffled = samples(randperm(length(samples)));
    breakpoint = round(length(samples)*(1-testRatio));
    trainingSet = shuffled(1:breakpoint);
    testSet = shuffled(breakpoint+1:end);
    save part4test.mat testSet;
    save part4train.mat trainingSet;
end