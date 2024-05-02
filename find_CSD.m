function [lamProf] = find_CSD(monkeyID,recordDate,recordInfo,CSDDepth,CSDTime)

	for k = 1:size(recordInfo,1)
		if contains(char(recordInfo.blockName(k)),recordDate) && contains(char(recordInfo.blockName(k)),'mainTask') && strcmp(char(recordInfo.chamber(k)),'AC')
			%sprintf('\nmainDepth = %i\n',recordInfo.recordDepth(k))
			if nargin < 4
				idx_CSDBlock = [];
				for j = 1:size(recordInfo,1)
					if contains(char(recordInfo.blockName(j)),recordDate) && contains(char(recordInfo.blockName(j)),'CSD_') && strcmp(char(recordInfo.chamber(j)),'AC') && recordInfo.recordDepth(j) == recordInfo.recordDepth(k)
						idx_CSDBlock(end+1) = j;
					end
				end
				idx_CSDPick = max(idx_CSDBlock(idx_CSDBlock<k));
			elseif nargin == 5
				for j = 1:size(recordInfo,1)
					if contains(char(recordInfo.blockName(j)),recordDate) && contains(char(recordInfo.blockName(j)),'CSD_') && strcmp(char(recordInfo.chamber(j)),'AC') && recordInfo.recordDepth(j) == CSDDepth && recordInfo.recordTime(j) == CSDTime
						idx_CSDPick = j;
					end
				end
			else
				display("!!!Error: No matching CSD block found. Skipping.")
			end
			
			lamProf.date = recordInfo.recordDate(idx_CSDPick);
			lamProf.coord = [recordInfo.guideTubeX(idx_CSDPick),recordInfo.guideTubeY(idx_CSDPick)];
			lamProf.coordPos = lamProf.coord+8;
			lamProf.depth = recordInfo.recordDepth(idx_CSDPick);
			lamProf.dataName = sprintf('Mr%s_%i_D%i_AC.mat',monkeyID,recordInfo.recordDate(idx_CSDPick),recordInfo.driveID(idx_CSDPick));
			lamProf.figName = sprintf('AEP_MUA_CSD_Mr%s_%i_D%i_AC_Block%i_%i_Depth%i.fig',monkeyID,recordInfo.recordDate(idx_CSDPick),recordInfo.driveID(idx_CSDPick),recordInfo.recordDate(idx_CSDPick),recordInfo.recordTime(idx_CSDPick),recordInfo.recordDepth(idx_CSDPick))

		end
	end


end



