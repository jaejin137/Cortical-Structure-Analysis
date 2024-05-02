dir_sample1 = '~/Casmiya/Scalograms/Cassius/190328/12500';

allImages = imageDatastore(dir_sample1,'IncludeSubfolders',true,'LabelSource','foldernames');
[imgsTrain,imgsValidation] = splitEachLabel(allImages,0.8,'randomized');
disp(['Number of training images: ',num2str(numel(imgsTrain.Files))]);
disp(['Number of validation images: ',num2str(numel(imgsValidation.Files))]);

net = googlenet;

lgraph = layerGraph(net)
numLayers = numel(lgraph.Layers)

figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]);
plot(lgraph)

newDropoutLayer = dropoutLayer(0.6,'Name','new_Dropout');
lgraph = replaceLayer(lgraph,'pool5-drop_7x7_s1',newDropoutLayer);
numClasses = numel(categories(imgsTrain.Labels));
newConnectedLayer = fullyConnectedLayer(numClasses,'Name','new_fc','WeightLearnRateFactor',5,'BiasLearnRateFactor',5);
lgraph = replaceLayer(lgraph,'loss3-classifier',newConnectedLayer);
newClassLayer = classificationLayer('Name','new_classoutput');
lgraph = replaceLayer(lgraph,'output',newClassLayer);

options = trainingOptions('sgdm','MiniBatchSize',6,'MaxEpochs',20,'InitialLearnRate',1e-4,'ValidationData',imgsValidation,'ValidationFrequency',10,'Verbose',1,'ExecutionEnvironment','cpu','Plots','training-progress');
rng default
trainedGN = trainNetwork(imgsTrain,lgraph,options);

