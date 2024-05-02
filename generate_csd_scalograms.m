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
				CSD = csdData.probe_meanData.smooth_CSD(idx_recDep(j,end-23:end),:);
				% Find channel with maximum mean CSD
				CSD_rect = abs(CSD);
				CSD_rectMean = mean(CSD_rect,2);
				[maxRectMean,maxCh] = max(CSD_rectMean);
				%if ifPlot == 'y'
				%	subplot(2,nRecordings,j)
				%	pcolor(csdData.timeBin,nChannel:-1:1,CSD(1:nChannel,:))
				%	shading interp;
				%	colormap jet;
				%	caxis([-2500 2500])
				%	set(gca,'YDir','normal','yTickLabel',nChannel:-2:0);
				%	xlabel('Time [ms]'); ylabel('electrode [ch]');
				%	if allRecDep(j) == targetDepth;
				%		title(sprintf('Depth=%i',allRecDep(j)),'Color','r')
				%	else
				%		title(sprintf('Depth=%i',allRecDep(j)))
				%	end
				%end
		
				% Plot CSD
				spacing = 5*1.e3;
				%if ifPlot == 'y'
				%	subplot(2,nRecordings,nRecordings+j)
				%end
				figure(h_wavelet)
				for chn = 1:nChannel % data channels
					%yOffset = -chn*spacing;
					z = csdData.probe_meanData.smooth_CSD(idx_recDep(j,1)+chn-1,:); % convert from V to uV
					fb = cwtfilterbank('SignalLength',length(z),'SamplingFrequency',Fs,'VoicesPerOctave',12);
					%[cfs, frq] = cwt(z);
					%cfs = abs(fb.wt(z));
					[cfs,frq] = wt(fb,z);
					%subplot(6,8,2*(chn-1)+1)
					%plot(tt(1:end-1),z)
					%title(sprintf('Ch=%i',chn))
					%subplot(6,8,2*chn)
					%%imagesc(tt, frq, abs(cfs))
					%pcolor(tt(1:end-1),frq,abs(cfs))
					%set(gca,'yscale','log')
					%shading interp
					%%axis xy;
					%axis tight
					%xlabel('Time (s)')
					%ylabel('Frequency (Hz)')
					%%title('Scalogram');
					%title(sprintf('Ch=%i',chn))
					%drawnow
					% Save the wavelet data into array
					CSDwave{chn,j,k} = z;
					CSDwavelet{chn,j,k} = [frq cfs];
					% Save image file
					dirCSDSGImg = fullfile('~','Casmiya',sprintf('Scalograms/%s/%s/%s',monkName,targetSess,num2str(targetDepth)));
					if ~exist(dirCSDSGImg,'dir')
						mkdir(dirCSDSGImg)
					end
					fnameCSDSGImg = sprintf('scalogram_ch%s.jpg',num2str(chn,'%02i'));
					imCSD = ind2rgb(im2uint8(rescale(abs(cfs))),jet(128));
					imwrite(imresize(imCSD,[224 224]),fullfile(dirCSDSGImg,fnameCSDSGImg));
				end
			end
		end
	end
end
fprintf('\nGenerating scalograms done!\n\n')

