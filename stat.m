clear;
Ori = 'Resp1';
Noi = 'Resp2';
piclist = dir(fullfile(Ori,'C1','*.mat'));
layer = 5;
%%
for k=1:layer
    dest = ['Stat/C' num2str(k)];
    if ~exist(dest,'dir')
        mkdir(dest);
    end
    for i = 1:length(piclist)
	tmp1 = load(fullfile(Ori,['C' num2str(k)], piclist(i).name));
	tmp2 = load(fullfile(Noi,['C' num2str(k)], piclist(i).name));
	t = (tmp1.C - tmp2.C)./(tmp1.C + tmp2.C);
	save(fullfile(dest,piclist(i).name),'t');
    end
end
%%
tempt = [];
for k=1:layer
    dest = ['Stat/C' num2str(k)];
    for i = 1:length(piclist)
	tmp = load(fullfile(dest,piclist(i).name));
	tempt = [tempt;reshape(tmp.t,1,[])];
    end
    excep = sum(isnan(tempt));
    tempt(isnan(tempt)) = 0;
    valid = size(tempt,1) - excep;
    distr = sum(tempt)./valid;
    save(['C' num2str(k) '_distr.mat'],'distr');
    tempt = [];
end

color_map     = cell(5, 1);
color_map{1}  = [0, 166, 80]/255;
color_map{2}  = [56, 119, 197]/255;
color_map{3}  = [248, 175, 5]/255;
color_map{4}  = [253, 0, 6]/255;
color_map{5}  = [87, 119, 55]/255;
%%
figure;
set(gcf,'Position',[10,409,1349,257]);
for k = 1:layer
    load(['C' num2str(k) '_distr.mat']);
    subplot(1,layer,k);
    hist(distr,8);
    h = findobj(gca,'Type','patch');
    
    set(h, 'FaceColor', color_map{k},'Edgecolor','w');
    ylabels = get(gca, 'YTickLabel');
    newy = zeros(size(ylabels,1),1);
    
    for tmp_j=1:size(ylabels,1)
        if k == 2|| k==3
            newy(tmp_j) = str2num(ylabels(tmp_j, :))*10000/size(distr,2);  
        else
            newy(tmp_j) = str2num(ylabels(tmp_j, :))/size(distr,2);
        end
        newy(tmp_j) = floor(newy(tmp_j)*1000)/1000;
    end
    set(gca,'YTickLabel',newy);
    title(['V' num2str(k) ' modulation distribution']);
end