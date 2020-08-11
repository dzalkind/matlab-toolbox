function h = Af_ThesisFig(h,width,varargin)
% Varargin(1) = FontSize
% varargin(2) = figure height

if numel(varargin) > 0
    figureFontSize = varargin{1};
else
    figureFontSize = [];
end

if isempty(figureFontSize)
    figureFontSize = 11;  %for wind energy science
else
    figureFontSize = varargin{1};
end
% 
set(h,'defaulttextinterpreter','latex');
set(h, 'defaultAxesTickLabelInterpreter','latex');
set(h, 'defaultLegendInterpreter','latex');

% set(0,'defaulttextinterpreter','none');
% set(0, 'defaultAxesTickLabelInterpreter','none');
% set(0, 'defaultLegendInterpreter','none');

% set(groot, 'defaultAxesFontName','Times New Roman')
% set(groot, 'defaultTextFontName','Times New Roman');

%% Set Font Sizes

ha = get(gcf,'Children');
for ih = 1:length(ha)
    if strcmp(ha(ih).Type,'axes') || strcmp(ha(ih).Type,'legend') || strcmp(ha(ih).Type,'colorbar')
        set(ha(ih), 'FontSize', figureFontSize);
        set(ha(ih), 'FontName', 'Times New Roman');
    end
    
    if strcmp(get(ha(ih),'type'),'axes')
        set(ha(ih), 'TitleFontSizeMultiplier', 1);
        set(ha(ih), 'LabelFontSizeMultiplier', 1);
    end
    
    ht = get(ha(ih),'Children');
    for it = 1:length(ht)
        if strcmp(ht(it).Type,'text')
            set(ht(it), 'FontSize', figureFontSize);
            set(ht(it), 'FontName', 'Times New Roman');
            set(ht(it), 'Interpreter','latex');
        end
        
    end
end

%% Size Image

set(gcf,'Units','inches');
pos = get(h,'Position');
baseWidth = 6.5;

width = width * baseWidth;
if numel(varargin) > 1
    height = varargin{2};
else
    height = pos(4);
end

fig = gcf;
fig.Units = 'inches';
fig.Position = [9.1667 4.3646,width,height];
fig.PaperSize = [width,height];


%% Print




% set(gcf,...
%     'Units','inches',...
%     'PaperSize',[width,height],...
%     'PaperPosition',[0,0,width,height],...
%     'Position',[5,1,width,height]);