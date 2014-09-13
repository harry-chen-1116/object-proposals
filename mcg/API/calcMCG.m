function calcMCG( config )
%EDGEBOXES Summary of this function goes here
%   Detailed explanation goes here

mcgconfig = config.mcg;


% if(strcmp(ebconfig.database,'pascal2012') && ~exist(ebconfig.pascal2012path))
%     fprintf('Path to dataset pascal2012 does not exist. Please make sure you give a proper full path\n');
%     return; 
% end
% 
% if(strcmp(ebconfig.database,'bsds500') && ~exist(ebconfig.bsds500path))
%     fprintf('Path to dataset bsds500 does not exist. Please make sure you give a proper full path\n');
%     return; 
% end


%Check if image location exists or not.

if(~exist(config.imageLocation, 'dir'))
	fprintf('Image Location does not exist. Please check path once again \n');
	return;
end

if(~exist(config.outputLocation, 'dir'))
	fprintf('Image Location does not exist. Please check path once again \n');
	return;
end

%Load All images in a particular folder
images = dir(config.imageLocation);
images = regexpi({images.name}, '.*jpg|.*jpeg|.*png|.*bmp', 'match');
images = [images{:}];

for i=1:length(images)
    imname = char(images(i));
    impath = fullfile(config.imageLocation, imname);
    whos impath
	im=imread(impath);
    
	if(size(im, 3) == 1)
		im=repmat(im,[1,1,3]);
	end
	fprintf('Calculating MCG for %s\n', imname);
	[candidates, scores] = im2mcg(config.root_dir, im, mcgconfig.opts.mode);

	boxes=zeros(length(candidates.labels),4);
	
	for j=1:length(candidates.labels)
		boxes(j,:)=mask2box(ismember(candidates.superpixels,candidates.labels{j}));
	end
	
	labels=candidates.labels; 
	
	if(isfield(mcgconfig.opts,'numProposals'))
    	numProposals=mcgconfig.opts.numProposals;

    	if(size(boxes,1)>=numProposals)
	    	boxes=boxes(1:numProposals,:);
        	labels=labels(1:numProposals);
    	else
	    	fprintf('Only %d proposals were generated for image:%s\n',size(boxes,1),imname);
    	end
	end


	boxes=[boxes(:,2) boxes(:,1) boxes(:,4) boxes(:,3)];
	
	proposals.boxes=boxes;
	proposals.scores = scores;
	proposals.regions.labels=labels;
	proposals.regions.superpixels=candidates.superpixels;
	
	saveFile=[imname '.mat'];
    if(~exist([config.outputLocation '/mcg'], 'dir'))
        mkdir(config.outputLocation,'/mcg')
    end
    save([config.outputLocation '/mcg/' saveFile], 'proposals');
end

end

