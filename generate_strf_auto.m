
% Setup directories
keyword = input('Enter keyword to filter target sessions: ','s');

% Exceptions
exceptions = {};
tag_exception = 1;
while tag_exception == 1
	exception = input('Any exceptions?("no" for no more): ','s');
	if strcmp(exception,'no')
		tag_exception = 0;
	else
		exceptions{end+1} = exception;
	end
end

