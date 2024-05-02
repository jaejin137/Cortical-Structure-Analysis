function audiRespMUA_AEP_CSD(dataPaths)
% audiRespMUA_AEP_CSD compute auditory responsiveness of MUA/AEP signals between noise vs no-noise epochs 
% & identify cortical layers based on CSD

if ~exist(dataPaths.dataFileSummaryFullName,'file')
    error('run audiDeciDataFileSummary!')
else
    disp('Loading data file summary...');
    tmp = load(dataPaths.dataFileSummaryFullName);
    recordSummary = tmp.recordSummary;
    clear tmp
end

if ~exist(dataPaths.recordInfoFullName,'file')
    error('run audiDeciRecordInfo!')
else
    disp('Loading recording info...');
    tmp = load(dataPaths.recordInfoFullName);
    recordInfo = tmp.recordInfo;
    clear tmp
    
    recordInfo.blockName = categorical(recordInfo.blockName);
    recordInfo.tankName = categorical(recordInfo.tankName);
end

% alignment & time window (StmOn [-100 400]) for data extraction
align  = 'STM_On';
wdt = [-100 400];

plot_pics = 1;
spacingCSD = 5000; %spacing in V
spacingAEP = 100; %spacing in uV
spacingRectMUA = 5;

screenSize = get(0,'ScreenSize');
screenSize(4) = screenSize(4)*0.9;

% analysis window
analysisEpoch = {'stimOn','stimOff'};
colorMapEpoch = {'YlOrBr','YlGn'};
nAlign = length(analysisEpoch);

settings.stimOn.name  = 'stimOn';
settings.stimOn.windowStart = 0;

settings.stimOff.name  = 'stimOff';
settings.stimOff.windowStart = 200;

analysisWindow = 150;
onsetMargin = 20;

cur_resultNamePrefix = 'audiRespCSD';
cur_resultPath = checkDirectory(dataPaths.results,[cur_resultNamePrefix filesep],1);
cur_matDir = checkDirectory(dataPaths.matDir,[cur_resultNamePrefix filesep],1);

[tc,aep,mua] = load_folder([dataPaths.hdfDir 'CSD' filesep],'trial','.tc.hdf5','continuous','.aep.hdf5','continuous','.mua.hdf5');
td = tc.get_trial_data();

ref = td.dates.(align);
w_start = ref + ms2d(wdt(1));
w_end   = ref + ms2d(wdt(2) + 0.1);

tmp_fs = aep.get_attribute('aep','sampling_frequency');
samplingFreq = tmp_fs{1};
nMinBin = round(samplingFreq*(wdt(2) - wdt(1))/1000);

chan_info = aep.get_content_attributes('aep');
chanInfo_table = struct2table(chan_info);
tmp_nameSplit = cellfun(@(x) strsplit(x,'_'),chanInfo_table.dataset_name,'UniformOutput',0);
chanInfo_table.probeID = categorical(cellfun(@(x) [x{1} '_' x{2} '_' x{5} '_' x{6}],tmp_nameSplit,'UniformOutput',0));
chanInfo_table.blockID = categorical(cellfun(@(x) [x{2} '_' x{3}],tmp_nameSplit,'UniformOutput',0));
chanInfo_table.chanID = categorical(chanInfo_table.dataset_name);
chanInfo_table.file_name = categorical(chanInfo_table.file_name);

listBlock_aep = unique(chanInfo_table.file_name);
listProbeID = unique(chanInfo_table.probeID);
nProbe = length(listProbeID);

if ~any(ismember(fieldnames(td.dates),align)), error([align ' is not a valid time event. No matched trial times found']); end
all_maxMUA = [];
all_maxAEP = [];
all_maxCSD = [];
for pp = 1:nProbe
    cur_probe = listProbeID(pp);
    cur_probeTable = chanInfo_table(chanInfo_table.probeID == cur_probe,:);
    cur_listBlock = unique(cur_probeTable.file_name);
    nBlock = length(cur_listBlock);

	% JL
	probeTok = split(char(cur_probe),'_');
	sessID = [probeTok{1} '_' probeTok{2}];
	figPath = fullfile(cur_resultPath, sessID);
	if ~exist(figPath)
		mkdir(figPath);
	end
    
    probe_meanData = [];
    maxMuaRect = zeros(nBlock,1);
    maxAepRect = zeros(nBlock,1);
    maxCSDRect = zeros(nBlock,1);
    saveMatName = [char(cur_probe) '.mat'];
    if ~exist([cur_matDir saveMatName],'file')
        
        for bb = 1:nBlock
            streamData = [];
            cur_block = cur_listBlock(bb);
            cur_blockTable = cur_probeTable(cur_probeTable.file_name == cur_block,:);
            cur_chan = cur_blockTable.dataset_name;
            nChannel = length(cur_chan);
            fileNameIndx = find(ismember(listBlock_aep,cur_block));
            %%%%%%%%%%%%
            % get data %
            %%%%%%%%%%%%
            for ch = 1:nChannel
                [tmp_aep,tmp_timeBin] = aep(fileNameIndx).get_subdata_date('aep',cur_chan{ch},w_start,w_end);
                [tmp_mua,~] = mua(fileNameIndx).get_subdata_date('mua',cur_chan{ch},w_start,w_end);
                % remove empty cells
                dataIndx = cellfun(@(x) ~isempty(x),tmp_aep);
                
                tmp_aep = tmp_aep(dataIndx);
                tmp_mua = tmp_mua(dataIndx);
                tmp_timeBin = tmp_timeBin(dataIndx);
                
                %Correct time for display
                tmp_timeBin = cellfun(@(t)t-t(1) + wdt(1),tmp_timeBin,'UniformOutput',false);
                
                % check data length
                aep_length = cellfun(@(x) length(x), tmp_aep);
                mua_length = cellfun(@(x) length(x), tmp_mua);
                min_length = min([aep_length;mua_length]);
                if any(aep_length < nMinBin) || any(mua_length < nMinBin)
                    error(['Check data length! (minimum: ' num2str(nMinBin) ' ; extracted data: ' num2str(min_length) ')']);
                end
                tmp_aep = cellfun(@(x) x(1:nMinBin), tmp_aep, 'UniformOutput',0);
                tmp_mua = cellfun(@(x) x(1:nMinBin), tmp_mua, 'UniformOutput',0);
                tmp_timeBin = cellfun(@(x) x(1:nMinBin), tmp_timeBin, 'UniformOutput',0);
                
                % put aep into table
                tmp_size = size(tmp_aep);
                
                % calculate rectified MUA
                tmp_chanStream = cell2table([repmat(cellstr(cur_blockTable.chanID(ch)),tmp_size),...
                    tmp_aep,tmp_mua,tmp_timeBin],...
                    'VariableNames',{'chanID','aep','mua','timeBin'});
                streamData = [streamData;tmp_chanStream];
            end
            
            % average LFP/MUA
            streamData.muaRect = abs(streamData.mua);
            mean_streamData = grpstats(streamData,'chanID',{'mean','std'},'DataVars',{'aep','muaRect'});
            mean_streamData = [mean_streamData cur_blockTable(:,{'probeID','blockID','file_name','guideTubeX','guideTubeY','recordDepth'})];
            cur_CSD = calculateCSD(mean_streamData.mean_aep);
            
            % smooth all data
            mean_streamData.smooth_aep = smoothEachChannel(mean_streamData.mean_aep);
            mean_streamData.smooth_muaRect = smoothEachChannel(mean_streamData.mean_muaRect);
            smooth_CSD = smoothEachChannel(cur_CSD);
            
            % baseline offset
            timeBin = streamData.timeBin(1,:);
            mean_streamData.smooth_aep = baselineOffset(mean_streamData.smooth_aep,timeBin);
            mean_streamData.smooth_muaRect = baselineOffset(mean_streamData.smooth_muaRect,timeBin);
            smooth_CSD = baselineOffset(smooth_CSD,timeBin);
            mean_streamData.smooth_CSD = [smooth_CSD; zeros(2,size(smooth_CSD,2))];
            
            maxMuaRect(bb) = max(mean_streamData.mean_muaRect(:));
            maxAepRect(bb) = max(abs(mean_streamData.mean_aep(:)));
            maxCSDRect(bb) = max(abs(cur_CSD(:)));
            %%%%%%%%
            % plot %
            %%%%%%%%
            if plot_pics

                
                % Plot aep in 3D smoothing for area
                % clim = max(abs(mean_streamData.smooth_aep(:))); %Find the max of max/min and use it for z
                % figure
                % imagesc(mean_streamData.smooth_aep, [-clim clim]);
                % title('AEP')
                % colorbar();
                
                screenSize = get(0,'ScreenSize');
                screenSize(4) = screenSize(4)*0.9;
                cur_resultFilename = ['AEP_MUA_CSD_' char(cur_probe) '_Block' char(mean_streamData.blockID(1)) '_Depth' num2str(mean_streamData.recordDepth(1))];
                h1 = figure('Name',cur_resultFilename,'Position',screenSize);
                subaxis(1,3,1)
                spacing = spacingCSD;
                area([0 200],[-spacing/2 -spacing/2],-(nChannel-1.5)*spacing,'EdgeColor','none','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.3)
                for chn = 1:nChannel-2
                    % baseline
                    yOffset = -chn*spacing;
                    line([timeBin(1) timeBin(end)],[yOffset yOffset],'Color',[0.5 0.5 0.5],'LineWidth',.5); %plots baseline
                    hold on
                    z = smooth_CSD(chn,:); % convert to uV
                    plot(timeBin,z + yOffset,'k','LineWidth',1.5);  %plots CSD
                    hold on
                end
                axis tight
                xlabel('Time [ms]'), ylabel ([{'Channels/'};{'Current [V/m2]'};{['Inter-Waveform Spacing = ' num2str(spacing)]}])
                cur_ax = gca;
                cur_ax.YTick = -((nChannel-3)*spacing):2*spacing:0;
                cur_ax.YTickLabel = num2str((nChannel-2:-2:2)');
                title('CSD')
                hold off;
                
                subaxis(1,3,2)
                spacing = spacingAEP;
                area([0 200],[-spacing/2 -spacing/2],-(nChannel+0.5)*spacing,'EdgeColor','none','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.3)
                for chn = 1:nChannel % data channels
                    % baseline
                    yOffset = -chn*spacing;
                    line([timeBin(1) timeBin(end)],[yOffset yOffset],'Color',[0.5 0.5 0.5],'LineWidth',.5); %plots baseline
                    hold on
                    z = mean_streamData.smooth_aep(chn,:)*1e6; % convert from V to uV
                    plot(timeBin,z + yOffset,'k','LineWidth',1);  %plots AEP
                    hold on
                end
                axis tight
                hold off;
                xlabel('Time [ms]'), ylabel ([{'Amplitude [microvolts]'};{['Inter-Waveform Spacing = ',num2str(spacing)]}])
                cur_ax = gca;
                cur_ax.YTick = -((nChannel-1)*spacing):2*spacing:1;
                cur_ax.YTickLabel = num2str(((nChannel-1):-2:1)');
                title('AEP')
                hold off;
                
                subaxis(1,3,3)
                spacing = spacingRectMUA;
                area([0 200],[-spacing/2 -spacing/2],-(nChannel+0.5)*spacing,'EdgeColor','none','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.3)
                for chn = 1:nChannel % data channels
                    % baseline
                    yOffset = -chn*spacing;
                    line([timeBin(1) timeBin(end)],[yOffset yOffset],'Color',[0.5 0.5 0.5],'LineWidth',.5); %plots baseline
                    hold on
                    z = mean_streamData.smooth_muaRect(chn,:)*1e6; % convert from V to uV
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
                mtit(cur_resultFilename,'Interpreter','none','xoff',0,'yoff',0.03);
                %fig_fullname = [cur_resultPath cur_resultFilename];
                fig_fullname = [cur_resultFilename];
                saveas(h1,fullfile(figPath, [fig_fullname '.fig']));
                save2pdf(fullfile(figPath, [fig_fullname '.pdf']),h1);
                %close(h1)
                
                h2 = figure('Name','AEP_MUA_CSD','Position',screenSize);
                subaxis(1,3,1);
                pcolor(timeBin,nChannel-2:-1:1,smooth_CSD);
                colormap jet;
                caxis([-spacingCSD/2 spacingCSD/2])
                line([0 0],[1 nChannel-2],'Color',[0.5 0.5 0.5],'LineStyle','--','LineWidth',1.5);
                line([200 200],[1 nChannel-2],'Color',[0.5 0.5 0.5],'LineStyle','--','LineWidth',1.5);
                set(gca,'YDir','normal','yTickLabel',nChannel-2:-2:2);
                shading interp;
                xlabel('Time [ms]'); ylabel('electrode [ch]');
                title('CSD');
                
                subaxis(1,3,[2 3]);
                wn = [0 100]; % clipping window [ms]
                MeanCSD_clipped = smooth_CSD(:,timeBin>=wn(1)&timeBin<=wn(2));
                pcolor(timeBin(timeBin>=wn(1)&timeBin<=wn(2)),nChannel-2:-1:1,MeanCSD_clipped);
                colormap jet;
                caxis([-spacingCSD/2 spacingCSD/2])
                set(gca,'YDir','normal','yTickLabel',nChannel-2:-2:2);
                shading interp;
                title('CSD clipped')
                xlabel('Time [ms]'); ylabel('electrode [ch]');
                
                mtit(cur_resultFilename,'Interpreter','none','xoff',0,'yoff',0.03);
                
                %fig_fullname = [cur_resultPath cur_resultFilename '_clipped'];
                fig_fullname = [cur_resultFilename '_clipped'];
                saveas(h2,fullfile(figPath, [fig_fullname '.fig']));
                saveas(h2,fullfile(figPath, [fig_fullname '.jpg']));
                %                 save2pdf([fig_fullname '.png'],h2);
                %close(h2)
				close all
            end
            probe_meanData = [probe_meanData; mean_streamData];
        end
        save([cur_matDir saveMatName], 'probe_meanData', 'maxMuaRect', 'maxAepRect', 'maxCSDRect', 'timeBin','-v7.3');
    else
        load([cur_matDir saveMatName]);
    end

    % check max muaRect for each probe -> select to put in all_streamData
    [~,maxMuaRectIndx] = max(maxMuaRect);
    [~,maxAepRectIndx] = max(maxAepRect);
    [~,maxCSDRectIndx] = max(maxCSDRect);
    
    all_maxMUA = [all_maxMUA;probe_meanData(probe_meanData.file_name == cur_listBlock(maxMuaRectIndx),:)];
    all_maxAEP = [all_maxAEP;probe_meanData(probe_meanData.file_name == cur_listBlock(maxAepRectIndx),:)];
    all_maxCSD = [all_maxCSD;probe_meanData(probe_meanData.file_name == cur_listBlock(maxCSDRectIndx),:)];
    
    if plot_pics
        if nBlock <= 3
            nRow = 1;
            nCol = 3;
        elseif nBlock <= 5
            nRow = 1;
            nCol = nBlock;
        elseif nBlock <= 10
            nRow = 2;
            nCol = 5;
        else
            nRow = 2;
            nCol = ceil(nBlock/2);
        end
        % plot all muaRect
        cur_resultFilename = [char(cur_probe) '_all_muaRect'];
        h3 = figure('Name',cur_resultFilename,'Position',screenSize);
        for bb = 1:nBlock
            cur_blockIndx = find(probe_meanData.file_name == cur_listBlock(bb));
            cur_streamData = probe_meanData.smooth_muaRect(cur_blockIndx,:);
            nChannel = size(cur_streamData,1);
            subaxis(nRow,nCol,bb)
            spacing = spacingRectMUA; %spacing in microvolts
            area([0 200],[-spacing/2 -spacing/2],-(nChannel+0.5)*spacing,'EdgeColor','none','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.3)
            for chn = 1:nChannel % data channels
                % baseline
                yOffset = -chn*spacing;
                line([timeBin(1) timeBin(end)],[yOffset yOffset],'Color',[0.5 0.5 0.5],'LineWidth',.5); %plots baseline
                hold on
                z = cur_streamData(chn,:)*1e6; % convert from V to uV
                plot(timeBin,z + yOffset,'k');  %plots RectMUA
                hold on
            end
            axis tight
            hold off;
            xlabel('Time [ms]'), ylabel ([{'Channels/'};{'Amplitude [microvolts]'}])
            cur_ax = gca;
            cur_ax.YTick = -((nChannel-1)*spacing):2*spacing:1;
            cur_ax.YTickLabel = num2str(((nChannel-1):-2:1)');
            if bb == maxMuaRectIndx
                title(['Block: ' char(probe_meanData.blockID(cur_blockIndx(1))) ';Depth: ' num2str(probe_meanData.recordDepth(cur_blockIndx(1)))],'Interpreter','none','FontWeight','bold','Color','r');
            else
                title(['Block: ' char(probe_meanData.blockID(cur_blockIndx(1))) ';Depth: ' num2str(probe_meanData.recordDepth(cur_blockIndx(1)))],'Interpreter','none');
            end
            hold off;
        end
        mtit(cur_resultFilename,'Interpreter','none','xoff',0,'yoff',0.03);
        %fig_fullname = [cur_resultPath cur_resultFilename];
        fig_fullname = [cur_resultFilename];
        saveas(h3,fullfile(figPath, [fig_fullname '.fig']));
        save2pdf(fullfile(figPath, [fig_fullname '.pdf']),h3);
        %close(h3)
        
        cur_resultFilename = [char(cur_probe) '_all_AEP'];
        h4 = figure('Name',cur_resultFilename,'Position',screenSize);
        for bb = 1:nBlock
            cur_blockIndx = find(probe_meanData.file_name == cur_listBlock(bb));
            cur_streamData = probe_meanData.smooth_aep(cur_blockIndx,:);
            nChannel = size(cur_streamData,1);
            subaxis(nRow,nCol,bb)
            spacing = spacingAEP; %spacing in microvolts
            area([0 200],[-spacing/2 -spacing/2],-(nChannel+0.5)*spacing,'EdgeColor','none','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.3)
            for chn = 1:nChannel % data channels
                % baseline
                yOffset = -chn*spacing;
                line([timeBin(1) timeBin(end)],[yOffset yOffset],'Color',[0.5 0.5 0.5],'LineWidth',.5); %plots baseline
                hold on
                z = cur_streamData(chn,:)*1e6; % convert from V to uV
                plot(timeBin,z + yOffset,'k');  %plots RectMUA
                hold on
            end
            axis tight
            hold off;
            xlabel('Time [ms]'), ylabel ([{'Channels/'};{'Amplitude [microvolts]'}])
            cur_ax = gca;
            cur_ax.YTick = -((nChannel-1)*spacing):2*spacing:1;
            cur_ax.YTickLabel = num2str(((nChannel-1):-2:1)');
            if bb == maxAepRectIndx
                title(['Block: ' char(probe_meanData.blockID(cur_blockIndx(1))) ';Depth: ' num2str(probe_meanData.recordDepth(cur_blockIndx(1)))],'Interpreter','none','FontWeight','bold','Color','r');
            else
                title(['Block: ' char(probe_meanData.blockID(cur_blockIndx(1))) ';Depth: ' num2str(probe_meanData.recordDepth(cur_blockIndx(1)))],'Interpreter','none');
            end
            hold off;
        end
        mtit(cur_resultFilename,'Interpreter','none','xoff',0,'yoff',0.03);
        %fig_fullname = [cur_resultPath cur_resultFilename];
        fig_fullname = [cur_resultFilename];
        saveas(h4,fullfile(figPath, [fig_fullname '.fig']));
        save2pdf(fullfile(figPath, [fig_fullname '.pdf']),h4);
        %close(h4)
        
        cur_resultFilename = [char(cur_probe) '_all_CSD'];
        h5 = figure('Name',cur_resultFilename,'Position',screenSize);
        for bb = 1:nBlock
            cur_blockIndx = find(probe_meanData.file_name == cur_listBlock(bb));
            cur_streamData = probe_meanData.smooth_CSD(cur_blockIndx,:);
            nChannel = size(cur_streamData,1);
            subaxis(nRow,nCol,bb)
            pcolor(timeBin,nChannel-2:-1:1,cur_streamData(1:nChannel-2,:));
            colormap jet;
            caxis([-spacingCSD/2 spacingCSD/2])
            line([0 0],[1 nChannel-2],'Color',[0.5 0.5 0.5],'LineStyle','--');
            line([200 200],[1 nChannel-2],'Color',[0.5 0.5 0.5],'LineStyle','--');
            set(gca,'YDir','normal','yTickLabel',nChannel-2:-2:2);
            shading interp;
            xlabel('Time [ms]'); ylabel('electrode [ch]');
            title('CSD');
            if bb == maxCSDRectIndx
                title(['Block: ' char(probe_meanData.blockID(cur_blockIndx(1))) ';Depth: ' num2str(probe_meanData.recordDepth(cur_blockIndx(1)))],'Interpreter','none','FontWeight','bold','Color','r');
            else
                title(['Block: ' char(probe_meanData.blockID(cur_blockIndx(1))) ';Depth: ' num2str(probe_meanData.recordDepth(cur_blockIndx(1)))],'Interpreter','none');
            end
        end
        mtit(cur_resultFilename,'Interpreter','none','xoff',0,'yoff',0.03);
        %fig_fullname = [cur_resultPath cur_resultFilename];
        fig_fullname = [cur_resultFilename];
        saveas(h5,fullfile(figPath, [fig_fullname '.fig']));
        saveas(h5,fullfile(figPath, [fig_fullname '.jpg']));
        %close(h5)
    end
	close all
end

probeID_split = cellfun(@(x) strsplit(x,'_'), cellstr(all_maxMUA.probeID),'UniformOutput',0);
all_maxMUA.monkeyID = categorical(cellfun(@(x) x{1}, probeID_split,'UniformOutput',0));
listMonkey = unique(all_maxMUA.monkeyID);
nMonkey = length(listMonkey);

all_maxMUA.chamber = categorical(cellfun(@(x) x{4}, probeID_split,'UniformOutput',0));
listChamber = unique(all_maxMUA.chamber);
nChamber = length(listChamber);

for mm = 1:nMonkey
    curMonkey = listMonkey(mm);
    curMonkeyIndx = all_maxMUA.monkeyID == curMonkey;
    for chm = 1:nChamber
        curChamber = listChamber(chm);
        curChamberIndx = all_maxMUA.chamber == curChamber;
        
        curProbeLocations = unique(all_maxMUA(curMonkeyIndx & curChamberIndx,{'probeID','guideTubeX','guideTubeY'}));
        
        % check probe locations
        guideTubeXs = min(curProbeLocations.guideTubeX): max(curProbeLocations.guideTubeX);
        guideTubeYs = min(curProbeLocations.guideTubeY): max(curProbeLocations.guideTubeY);
        nCol = guideTubeXs(end) - guideTubeXs(1) + 1;
        nRow = guideTubeYs(end) - guideTubeYs(1) + 1;
        
        if nCol > 6
            nML = ceil(nCol / 6);
        else
            nML = 1;
        end
        for ml = 1:nML
            ml_start = ((ml-1)*6)+1;
            ml_end = ml*6;
            if ml_end > nCol, ml_end = nCol; end
            selIndx = curProbeLocations.guideTubeX <= guideTubeXs(ml_end) & curProbeLocations.guideTubeX >= guideTubeXs(ml_start);
            subProbeLocation = curProbeLocations(selIndx,:);
            
            cur_guideTubeXs = min(subProbeLocation.guideTubeX): max(subProbeLocation.guideTubeX);
            cur_guideTubeYs = min(subProbeLocation.guideTubeY): max(subProbeLocation.guideTubeY);
            nCol_sub = cur_guideTubeXs(end) - cur_guideTubeXs(1) + 1;
            nRow_sub = cur_guideTubeYs(end) - cur_guideTubeYs(1) + 1;
            if nCol_sub < 5, nCol_sub = 5; end
            
            subProbeLocation.subX = subProbeLocation.guideTubeX - cur_guideTubeXs(1) + 1;
            subProbeLocation.subY = cur_guideTubeYs(end) - subProbeLocation.guideTubeY + 1;
            subProbeLocation.subIndx = sub2ind([nCol_sub nRow_sub],subProbeLocation.subX,subProbeLocation.subY);
            [probeLocations, ~, ic] = unique([subProbeLocation.subIndx],'rows');
            a_counts = accumarray(ic,1);
            location_counts = [probeLocations, a_counts];
            duplicate_counts = location_counts(a_counts>1,:);
            nSubplot = nRow_sub * nCol_sub;
            indxList = reshape(1:nSubplot,[nCol_sub nRow_sub])';
            for rr = 1:nRow_sub
                cur_duplicates = duplicate_counts(ismember(duplicate_counts(:,1),indxList(rr,:)),:);
                nDuplicates = size(cur_duplicates,1);
                if any(nDuplicates)
                    for dd = 1:nDuplicates
                        nDupRep = cur_duplicates(dd,2);
                        dupIndx = find(subProbeLocation.subIndx == cur_duplicates(dd,1));
                        
                        % add subplots for duplicates
                        subProbeLocation.subIndx(dupIndx(1:nDupRep-1)) = nSubplot+1:nSubplot+nDupRep-1;
                        nSubplot = nSubplot+nDupRep-1;
                    end
                end
            end
            nRow_sub = ceil(nSubplot / nCol_sub);
            
            % PLOT MUA
            for sp = 1:nSubplot
                if mod(sp,nCol_sub*2) == 1
                    figNum = ceil(sp/(nCol_sub*2));
                    cur_resultFilename = [char(curMonkey) '_' char(curChamber) '_all_MUARect_' num2str(ml) '_' num2str(figNum)];
                    h6 = figure('Name',cur_resultFilename,'Position',screenSize);
                end
                selProbeIndx = subProbeLocation.subIndx == sp;
                if any(selProbeIndx)
                    subaxis(2,nCol_sub,mod(sp-1,nCol_sub*2)+1)
                    curProbeID = subProbeLocation.probeID(selProbeIndx);
                    cur_streamData = all_maxMUA(all_maxMUA.probeID == curProbeID,:);
                    nChannel = height(cur_streamData);
                    spacing = spacingRectMUA; %spacing in microvolts
                    area([0 200],[-spacing/2 -spacing/2],-(nChannel+0.5)*spacing,'EdgeColor','none','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.3)
                    for chn = 1:nChannel % data channels
                        % baseline
                        yOffset = -chn*spacing;
                        line([timeBin(1) timeBin(end)],[yOffset yOffset],'Color',[0.5 0.5 0.5],'LineWidth',.5); %plots baseline
                        hold on
                        z = cur_streamData.smooth_muaRect(chn,:)*1e6; % convert from V to uV
                        plot(timeBin,z + yOffset,'k');  %plots RectMUA
                        hold on
                    end
                    axis tight
                    hold off;
                    xlabel('Time [ms]'), ylabel ([{'Channels/'};{'Amplitude [microvolts]'}])
                    cur_ax = gca;
                    cur_ax.YTick = -((nChannel-1)*spacing):2*spacing:1;
                    cur_ax.YTickLabel = num2str(((nChannel-1):-2:1)');
                    title({['Block:' char(cur_streamData.blockID(1))]; ...
                        ['; X:' num2str(cur_streamData.guideTubeX(1)) ...
                        '; Y:' num2str(cur_streamData.guideTubeY(1)) ...
                        '; Depth:' num2str(cur_streamData.recordDepth(1))]},'Interpreter','none','FontName','Arial');
                    hold off;
                end
                if mod(sp,nCol_sub*2) == 0 || sp == nSubplot
                    mtit(cur_resultFilename,'Interpreter','none','xoff',0,'yoff',0.03);
                    %fig_fullname = [cur_resultPath cur_resultFilename];
                    fig_fullname = [cur_resultFilename];
                    saveas(h6,fullfile(figPath, [fig_fullname '.fig']));
                    save2pdf(fullfile(figPath, [fig_fullname '.pdf']),h6);
                    %close(h6)
                end
            end
            
            
            % PLOT AEP
            for sp = 1:nSubplot
                if mod(sp,nCol_sub*2) == 1
                    figNum = ceil(sp/(nCol_sub*2));
                    cur_resultFilename = [char(curMonkey) '_' char(curChamber) '_all_AEP_' num2str(ml) '_' num2str(figNum)];
                    h7 = figure('Name',cur_resultFilename,'Position',screenSize);
                end
                selProbeIndx = subProbeLocation.subIndx == sp;
                if any(selProbeIndx)
                    subaxis(2,nCol_sub,mod(sp-1,nCol_sub*2)+1)
                    curProbeID = subProbeLocation.probeID(selProbeIndx);
                    cur_streamData = all_maxAEP(all_maxAEP.probeID == curProbeID,:);
                    nChannel = height(cur_streamData);
                    spacing = spacingAEP; %spacing in microvolts
                    area([0 200],[-spacing/2 -spacing/2],-(nChannel+0.5)*spacing,'EdgeColor','none','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.3)
                    for chn = 1:nChannel % data channels
                        % baseline
                        yOffset = -chn*spacing;
                        line([timeBin(1) timeBin(end)],[yOffset yOffset],'Color',[0.5 0.5 0.5],'LineWidth',.5); %plots baseline
                        hold on
                        z = cur_streamData.smooth_aep(chn,:)*1e6; % convert from V to uV
                        plot(timeBin,z + yOffset,'k');  %plots RectMUA
                        hold on
                    end
                    axis tight
                    hold off;
                    xlabel('Time [ms]'), ylabel ([{'Channels/'};{'Amplitude [microvolts]'}])
                    cur_ax = gca;
                    cur_ax.YTick = -((nChannel-1)*spacing):2*spacing:1;
                    cur_ax.YTickLabel = num2str(((nChannel-1):-2:1)');
                    title({['Block:' char(cur_streamData.blockID(1))]; ...
                        ['; X:' num2str(cur_streamData.guideTubeX(1)) ...
                        '; Y:' num2str(cur_streamData.guideTubeY(1)) ...
                        '; Depth:' num2str(cur_streamData.recordDepth(1))]},'Interpreter','none','FontName','Arial');
                    hold off;
                end
                if mod(sp,nCol_sub*2) == 0 || sp == nSubplot
                    mtit(cur_resultFilename,'Interpreter','none','xoff',0,'yoff',0.03);
                    %fig_fullname = [cur_resultPath cur_resultFilename];
                    fig_fullname = [cur_resultFilename];
                    saveas(h7,fullfile(figPath, [fig_fullname '.fig']));
                    save2pdf(fullfile(figPath, [fig_fullname '.pdf']),h7);
                    %close(h7)
                end
            end
            
            % PLOT CSD
            for sp = 1:nSubplot
                if mod(sp,nCol_sub*2) == 1
                    figNum = ceil(sp/(nCol_sub*2));
                    cur_resultFilename = [char(curMonkey) '_' char(curChamber) '_all_CSD_' num2str(ml) '_' num2str(figNum)];
                    h8 = figure('Name',cur_resultFilename,'Position',screenSize);
                end
                selProbeIndx = subProbeLocation.subIndx == sp;
                if any(selProbeIndx)
                    subaxis(2,nCol_sub,mod(sp-1,nCol_sub*2)+1)
                    curProbeID = subProbeLocation.probeID(selProbeIndx);
                    cur_streamData = all_maxCSD(all_maxCSD.probeID == curProbeID,:);
                    nChannel = height(cur_streamData);
                    pcolor(timeBin,nChannel-2:-1:1,cur_streamData.smooth_CSD(1:nChannel-2,:));
                    colormap jet;
                    caxis([-spacingCSD/2 spacingCSD/2])
                    line([0 0],[1 nChannel-2],'Color',[0.5 0.5 0.5],'LineStyle','--');
                    line([200 200],[1 nChannel-2],'Color',[0.5 0.5 0.5],'LineStyle','--');
                    set(gca,'YDir','normal','yTickLabel',nChannel-2:-2:2);
                    shading interp;
                    xlabel('Time [ms]'); ylabel('electrode [ch]');
                    title({['Block:' char(cur_streamData.blockID(1))]; ...
                        ['; X:' num2str(cur_streamData.guideTubeX(1)) ...
                        '; Y:' num2str(cur_streamData.guideTubeY(1)) ...
                        '; Depth:' num2str(cur_streamData.recordDepth(1))]},'Interpreter','none','FontName','Arial');
                    hold off;
                end
                if mod(sp,nCol_sub*2) == 0 || sp == nSubplot
                    mtit(cur_resultFilename,'Interpreter','none','xoff',0,'yoff',0.03);
                    %fig_fullname = [cur_resultPath cur_resultFilename];
                    fig_fullname = [cur_resultFilename];
                    saveas(h8,fullfile(figPath, [fig_fullname '.fig']));
                    saveas(h8,fullfile(figPath, [fig_fullname '.jpg']));
                    %close(h8)
                end
            end
			close all
        end
    end
end     
% [4 - correct dead channels (omit the dead channel and double contact distance)
end





function CSD = calculateCSD(aepData)
% calculate CSD
% create the spatial deltas, which in the Freeman & Nicholson 1975
%  is 1, 2, 1 for the before-channel, channel, post-channel respectively.
nChannel = size(aepData,1);
if nChannel == 24
    e_Dist = 100e-6; % distance between electrodes (from V-probe configuration)
elseif nChannel == 16
    e_Dist = 150e-6;
else
    error('check channel number!')
end
mat_deltas = zeros(nChannel-2,nChannel);
for i=1:nChannel-2
    for j=1:nChannel
        if (i == j-1)
            mat_deltas(i,j) = -2/e_Dist^2;
        elseif (abs(i-j+1) == 1)
            mat_deltas(i,j) = 1/e_Dist^2;
        else
            mat_deltas(i,j) = 0;
        end
    end
end

% check if there's dead channel -> ignore that channel & double neigboring distance
CSD = -1*mat_deltas*aepData;

% calculate CSD (from Taku)
% CSD = zeros(nChannel-2,size(mean_aep,2));
% for cc = 2:nChannel-1
%     CSD(cc-1,:) = ((-1*mean_aep(cc-1,:))+(2*mean_aep(cc,:))+(-1*mean_aep(cc+1,:)));
% end
end

function smoothData = smoothEachChannel(dataIn)
smoothSpan = 5;
nChannel = size(dataIn,1);
smoothData = dataIn;
for ch = 1:nChannel
    smoothData(ch,:) = smooth(dataIn(ch,:),smoothSpan);
end
end

function baselineOffsetData = baselineOffset(dataIn,timeBin)
%now baseline correct the data to the negative time segment:
baselineOffsetData = dataIn;
baselineIndx = timeBin <= 0;
nChannel = size(dataIn,1);
for ch = 1:nChannel
    baselineOffsetData(ch,:) = dataIn(ch,:) - mean(dataIn(ch,baselineIndx));
end
end


