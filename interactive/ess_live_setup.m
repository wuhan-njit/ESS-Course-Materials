function lesson = ess_live_setup
% 读取交互教学文件位置及课程算例，不改变原有教学文件。
lesson.home = fileparts(mfilename('fullpath'));
lesson.cases = fullfile(fileparts(lesson.home),'cases');
lesson.results = fullfile(lesson.home,'results');
addpath(lesson.home,lesson.cases);
if ~isfolder(lesson.results), mkdir(lesson.results); end
assert(exist('runpf','file')==2,'请先安装 MATPOWER 并添加路径。');
end
