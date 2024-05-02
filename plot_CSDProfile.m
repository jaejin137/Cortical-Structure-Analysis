function [] = plot_CSDProfile(recordDate,dataName,depthPicked,timePicked,coordPos,figHandle1,figHandle2,idx_prof)

	dir_resultData = fullfile('~','audiDeci','mat','audiRespCSD');

	load(fullfile(dir_resultData,dataName))
	%idx_rightDepth = find(probe_meanData.recordDepth == rightDepth);
	idx_rightDepth = find((probe_meanData.blockID == sprintf('%i_%i',recordDate,timePicked)).*(probe_meanData.recordDepth == depthPicked));
	nChannel = 24;

	% Plot CSD Profile
	spacingCSD = 5000;
	wn = [-.1 50.1]; % clipping window [ms]
	MeanCSD_clipped = probe_meanData.smooth_CSD(idx_rightDepth,timeBin>=wn(1)&timeBin<=wn(2));
	% Plot all CSD sequentially
	figure(figHandle1)
	subplot_tight(7,7,idx_prof,0.02)
	pcolor(timeBin(timeBin>=wn(1)&timeBin<=wn(2)),nChannel-2:-1:1,MeanCSD_clipped(1:nChannel-2,:));
	shading interp;
	colormap jet;
	caxis([-spacingCSD/2 spacingCSD/2])
	%set(gca,'XTick',[0 10 20 30 40 50])
	set(gca,'Xticklabel',[])
	set(gca,'YTick',1:2:22,'YTickLabel',nChannel-2:-2:2)
	title(sprintf('[%i,%i]',coordPos(1)-8,coordPos(2)-8))
	set(gca,'FontSize',8)
	drawnow
	% Plot CSD on grid
	figure(figHandle2)
	subplot_tight(15,15,225-15*(coordPos(2)-1)-(15-coordPos(1)),0.01)
	pcolor(timeBin(timeBin>=wn(1)&timeBin<=wn(2)),nChannel-2:-1:1,MeanCSD_clipped(1:nChannel-2,:));
	shading interp;
	colormap jet;
	caxis([-spacingCSD/2 spacingCSD/2])
	%set(gca,'YDir','normal','yTickLabel',nChannel-2:-2:2);
	%title('CSD clipped')
	%xlabel('Time [ms]'); ylabel('electrode [ch]');
	set(gca,'Xticklabel',[])
	set(gca,'Yticklabel',[])
	%title(sprintf('[%i,%i]',coordPos(1)-8,coordPos(2)-8))
	set(gca,'FontSize',4)
	drawnow

end
