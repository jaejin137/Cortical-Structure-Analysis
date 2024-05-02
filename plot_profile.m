function [] = plot_profile(dataName,rightDepth,coordPos)

	dir_resultData = fullfile('~','audiDeci','mat','audiRespCSD');

	load(fullfile(dir_resultData,dataName))
	idx_rightDepth = find(probe_meanData.recordDepth == rightDepth);
	nChannel = 24;

	% Plot CSD Profile
	spacingCSD = 5000;
	wn = [0 50]; % clipping window [ms]
	MeanCSD_clipped = probe_meanData.smooth_CSD(idx_rightDepth,timeBin>=wn(1)&timeBin<=wn(2));
	subplot_tight(15,15,225-15*(coordPos(2)-1)-(15-coordPos(1)),0.01)
	pcolor(timeBin(timeBin>=wn(1)&timeBin<=wn(2)),nChannel-2:-1:1,MeanCSD_clipped(1:nChannel-2,:));
	shading interp;
	colormap jet;
	caxis([-spacingCSD/2 spacingCSD/2])
	set(gca,'Xticklabel',[])
	set(gca,'Yticklabel',[])
	title(sprintf('[%i,%i]',coordPos(1)-8,coordPos(2)-8))
	set(gca,'FontSize',4)
	%set(gca,'YDir','normal','yTickLabel',nChannel-2:-2:2);
	%title('CSD clipped')
	%xlabel('Time [ms]'); ylabel('electrode [ch]');
	drawnow

	% Plot rectMUA
	spacingRectMUA = 5;
	spacing = spacingRectMUA;
	nChannel = 24;
	area([0 200],[-spacing/2 -spacing/2],-(nChannel+0.5)*spacing,'EdgeColor','none','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.3)
	load(fullfile(dir_resultData,lamProf.dataName))
	for chn = 1:nChannel % data channels
		yOffset = -chn*spacing;
		line([timeBin(1) timeBin(end)],[yOffset yOffset],'Color',[0.5 0.5 0.5],'LineWidth',.5); %plots baseline
		hold on
		z = probe_meanData.smooth_muaRect(chn,:)*1e6; % convert from V to uV
		plot(timeBin,z + yOffset,'k','LineWidth',1);  %plots RectMUA
		hold on
	end
	axis tight
	hold off;
	xlabel('Time [ms]'), ylabel ([{'Amplitude [microvolts]'};{['Inter-Waveform Spacing = ',num2str(spacing)]}])
	cur_ax = gca;
	cur_ax.YTick = -((nChannel-1)*spacing):2*spacing:1;
	cur_ax.YTickLabel = num2str(((nChannel-1):-2:1)');
	title('RectMUA')
	hold off;

end
