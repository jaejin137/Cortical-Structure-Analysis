%resultMatPath = fullfile('I:','Parooa','Synapse','i','audiDeci','mat','audiRespCSD');
%targetMonk = input('Enter monkey initial(C/M): ','s');
targetSess = input('Enter session date: ');
%targetDrive = input('Enter drive number: ');

resultMatPath = fullfile('~','audiDeci','mat','audiRespCSD');
%resultMatFiles = dir(fullfile(resultMatPath,sprintf('*D*AC.mat')));
%targetMatFiles = dir(fullfile(resultMatPath,sprintf('Mr%s_%i_D*_AC.mat',targetMonk,targetSess)));
targetMatFiles = dir(fullfile(resultMatPath,sprintf('*%i_D*_AC.mat',targetSess)));


nChannel = 24;

for k = 1:numel(targetMatFiles)
%for k = 1:2
	load(fullfile(resultMatPath,targetMatFiles(k).name));
	%load(fullfile(resultMatPath,'MrC_190326_D2_AC'));
	recDep = sort(unique(probe_meanData.recordDepth));
	nRecordings = floor(length(probe_meanData.recordDepth)/nChannel);
	%fnamePlot{k,1} = unique(probe_meanData.file_name);
	l = 1;
	allRecDep = [];
	for j = 1:numel(recDep)
		idx_recDepTmp = find(probe_meanData.recordDepth == recDep(j));
		for i = 1:floor(numel(idx_recDepTmp)/nChannel)
			idx_recDep(l,1:nChannel) = idx_recDepTmp(nChannel*(i-1)+1:nChannel*i);
			%fnamePlot{end+1,1} = unique(probe_meanData.file_name(idx_recDep(nChannel*(i-1)+1:nChannel*i)));
			%fnamePlot{l,1} = unique(probe_meanData.file_name(idx_recDep(nChannel*(i-1)+1:nChannel*i)));
			allRecDep(end+1,1) = recDep(j);
			l = l+1;
		end
	end
	% Plot CSD
	figure
	for j = 1:nRecordings
		%CSD = probe_meanData.smooth_CSD(end-23:end-2,:);
		CSD = probe_meanData.smooth_CSD(idx_recDep(j,end-23:end-2),:);
		% Find channel with maximum mean CSD
		CSD_rect = abs(CSD);
		CSD_rectMean = mean(CSD_rect,2);
		[maxRectMean,maxCh] = max(CSD_rectMean);
		
		%subplot(2,nRecordings,2*(j-1)+1)
		subplot(2,nRecordings,j)
		pcolor(timeBin,nChannel-2:-1:1,CSD(1:nChannel-2,:))
		%pcolor(timeBin,nChannel:-1:1,CSD(1:nChannel,:))
		%yline(nChannel-maxCh-3,'-.','LineWidth',2);
		%yline(nChannel-maxCh,'--','LineWidth',2);
		shading interp;
		colormap jet;
		caxis([-2500 2500])
		set(gca,'YDir','normal','yTickLabel',nChannel-2:-2:2);
		%set(gca,'YDir','normal','yTickLabel',nChannel:-2:0);
		xlabel('Time [ms]'); ylabel('electrode [ch]');
		%title(sprintf('Depth=%i',allRecDep(j)))
		% Plot rectified CSD
		%subplot(2,nRecordings,2*j)
		subplot(2,nRecordings,nRecordings+j)
		pcolor(timeBin,nChannel-2:-1:1,CSD_rect(1:nChannel-2,:))
		%pcolor(timeBin,nChannel:-1:1,CSD_rect(1:nChannel,:))
		%yline(nChannel-maxCh-3,'-.','LineWidth',2);
		%yline(nChannel-maxCh,'--','LineWidth',2);
		shading interp;
		colormap jet;
		caxis([0 2500])
		set(gca,'YDir','normal','yTickLabel',nChannel-2:-2:2);
		%set(gca,'YDir','normal','yTickLabel',nChannel:-2:0);
		xlabel('Time [ms]'); ylabel('electrode [ch]');
		%title(sprintf('Depth=%i',allRecDep(j)))
	end
	fnameTok = split(targetMatFiles(k).name,'_');
	suptitle(sprintf('%s-%s-%s',fnameTok{1:3}))
	currPos = get(gcf,'Position'); set(gcf,'Position',[currPos(1),currPos(2),200*nRecordings,800]);
	%saveas(gcf,fullfile('~','Casmiya','PrelimData',sprintf('%s_%s_%s.png',fnameTok{1:3})),'png')
	print(gcf,fullfile('~','Casmiya','PrelimData',sprintf('%s_%s_%s.png',fnameTok{1:3})),'-dpng','-r600')
end
