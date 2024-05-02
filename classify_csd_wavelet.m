%% Generate templates for each monkey
resultMatPath = fullfile('~','audiDeci','mat','audiRespCSD');
dir_save_plot = fullfile('~','Casmiya','CSD_Template_Fig');
if ~exist(dir_save_plot,'dir')
	mkdir(dir_save_plot)
end
ifPlot = 'y';

%% Constants
Fs = 12208;
tt = -.1:1/Fs:.4;

load(fullfile('~','Casmiya','Laminae_AC.mat'));

nChannel = 24;

tmplt_indv = cell(size(laminar_ac_cassius,1)+size(laminar_ac_miyagi,1),3);

for m = 1:1
	if m == 1
		fprintf('\nProcessing data for Cassius...\n')
		targetMonk = 'C';
		monkName = 'Cassius';
		laminar_ac = laminar_ac_cassius;
	else
		fprintf('\nProcessing data for Miyagi...\n')
		targetMonk = 'M';
		monkName = 'Miyagi';
		laminar_ac = laminar_ac_miyagi;
	end

	for sessNum = 1:size(laminar_ac,1)
		sessTok = split(laminar_ac.RecordingSite(sessNum),'_');
		targetSess = sessTok(1);
		drvTok = split(sessTok(2),'D');
		targetDrive = drvTok(2);
		depthTok = split(sessTok(4),'Depth');
		targetDepth = str2num(depthTok(2));

		targetMatFiles = dir(fullfile(resultMatPath,sprintf('Mr%s_%s_D%s_AC.mat',targetMonk,targetSess,targetDrive)));
					
		for k = 1:numel(targetMatFiles)
			fprintf('\nProcessing %s...\n',targetMatFiles(k).name)
			csdData = load(fullfile(resultMatPath,targetMatFiles(k).name));
			recDep = sort(unique(csdData.probe_meanData.recordDepth));
			nRecordings = floor(length(csdData.probe_meanData.recordDepth)/nChannel);
			l = 1;
			allRecDep = [];
			for j = 1:numel(recDep)
				idx_recDepTmp = find(csdData.probe_meanData.recordDepth == recDep(j));
				for i = 1:floor(numel(idx_recDepTmp)/nChannel)
					idx_recDep(l,1:nChannel) = idx_recDepTmp(nChannel*(i-1)+1:nChannel*i);
					allRecDep(end+1,1) = recDep(j);
					l = l+1;
				end
			end
			% Plot CSD
			%if ifPlot == 'y'
			%	if exist('h_csd')
			%		clf(h_csd)
			%	else
			%		h_csd = figure;
			%	end
			%	currPos = get(h_csd,'Position'); set(h_csd,'Position',[currPos(1),currPos(2),200*nRecordings,800]);
			%end
			if ifPlot == 'y'
				if exist('h_wavelet')
					clf(h_wavelet)
				else
					h_wavelet = figure;
				end
				currPos = get(h_wavelet,'Position'); set(h_wavelet,'Position',[currPos(1),currPos(2),200*nRecordings,800]);
			end
			for j = 1:nRecordings
				fprintf('\tProcessing %i out of %i recording depth\n',j,nRecordings)
				dirCSDSGImg = fullfile('~','Casmiya',sprintf('Scalograms/%s/%s/%s',monkName,targetSess,num2str(targetDepth)));
				% Load all scalograms for a given depth
				allImages = imageDatastore(dirCSDSGImg,'IncludeSubfolders',true,'LabelSource','foldernames');
				rng default
				[imgsTrain,imgsValidation] = splitEachLabel(allImages,0.8,'randomized');
				disp(['Number of training images: ',num2str(numel(imgsTrain.Files))]);
				return





			end
		end
	end
end
fprintf('\nGenerating scalograms done!\n\n')

