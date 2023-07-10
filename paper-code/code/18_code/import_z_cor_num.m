function zcor = import_z_cor_num(filename, startRow, endRow)
%IMPORTFILE ���ı��ļ��е���ֵ������Ϊ�����롣
%   ZCOR = IMPORTFILE(FILENAME) ��ȡ�ı��ļ� FILENAME ��Ĭ��ѡ����Χ�����ݡ�
%
%   ZCOR = IMPORTFILE(FILENAME, STARTROW, ENDROW) ��ȡ�ı��ļ� FILENAME ��
%   STARTROW �е� ENDROW ���е����ݡ�
%
% Example:
%   zcor = importfile('z_cor.txt', 2, 79);
%
%    ������� TEXTSCAN��

% �� MATLAB �Զ������� 2017/02/07 13:52:48

%% ��ʼ��������
delimiter = '\t';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% ÿ���ı��еĸ�ʽ�ַ���:
%   ��2: ˫����ֵ (%f)
%	��3: ˫����ֵ (%f)
%   ��4: ˫����ֵ (%f)
%	��5: ˫����ֵ (%f)
%   ��6: ˫����ֵ (%f)
%	��7: ˫����ֵ (%f)
%   ��8: ˫����ֵ (%f)
%	��9: ˫����ֵ (%f)
%   ��10: ˫����ֵ (%f)
%	��11: ˫����ֵ (%f)
%   ��12: ˫����ֵ (%f)
%	��13: ˫����ֵ (%f)
%   ��14: ˫����ֵ (%f)
%	��15: ˫����ֵ (%f)
%   ��16: ˫����ֵ (%f)
%	��17: ˫����ֵ (%f)
%   ��18: ˫����ֵ (%f)
%	��19: ˫����ֵ (%f)
%   ��20: ˫����ֵ (%f)
%	��21: ˫����ֵ (%f)
%   ��22: ˫����ֵ (%f)
%	��23: ˫����ֵ (%f)
%   ��24: ˫����ֵ (%f)
%	��25: ˫����ֵ (%f)
%   ��26: ˫����ֵ (%f)
%	��27: ˫����ֵ (%f)
%   ��28: ˫����ֵ (%f)
%	��29: ˫����ֵ (%f)
%   ��30: ˫����ֵ (%f)
%	��31: ˫����ֵ (%f)
%   ��32: ˫����ֵ (%f)
%	��33: ˫����ֵ (%f)
%   ��34: ˫����ֵ (%f)
%	��35: ˫����ֵ (%f)
%   ��36: ˫����ֵ (%f)
%	��37: ˫����ֵ (%f)
%   ��38: ˫����ֵ (%f)
%	��39: ˫����ֵ (%f)
%   ��40: ˫����ֵ (%f)
%	��41: ˫����ֵ (%f)
%   ��42: ˫����ֵ (%f)
%	��43: ˫����ֵ (%f)
%   ��44: ˫����ֵ (%f)
%	��45: ˫����ֵ (%f)
%   ��46: ˫����ֵ (%f)
%	��47: ˫����ֵ (%f)
%   ��48: ˫����ֵ (%f)
%	��49: ˫����ֵ (%f)
%   ��50: ˫����ֵ (%f)
%	��51: ˫����ֵ (%f)
%   ��52: ˫����ֵ (%f)
%	��53: ˫����ֵ (%f)
%   ��54: ˫����ֵ (%f)
%	��55: ˫����ֵ (%f)
%   ��56: ˫����ֵ (%f)
%	��57: ˫����ֵ (%f)
%   ��58: ˫����ֵ (%f)
%	��59: ˫����ֵ (%f)
%   ��60: ˫����ֵ (%f)
%	��61: ˫����ֵ (%f)
%   ��62: ˫����ֵ (%f)
%	��63: ˫����ֵ (%f)
%   ��64: ˫����ֵ (%f)
%	��65: ˫����ֵ (%f)
%   ��66: ˫����ֵ (%f)
%	��67: ˫����ֵ (%f)
%   ��68: ˫����ֵ (%f)
%	��69: ˫����ֵ (%f)
%   ��70: ˫����ֵ (%f)
%	��71: ˫����ֵ (%f)
%   ��72: ˫����ֵ (%f)
%	��73: ˫����ֵ (%f)
%   ��74: ˫����ֵ (%f)
%	��75: ˫����ֵ (%f)
%   ��76: ˫����ֵ (%f)
%	��77: ˫����ֵ (%f)
%   ��78: ˫����ֵ (%f)
%	��79: ˫����ֵ (%f)
% �й���ϸ��Ϣ������� TEXTSCAN �ĵ���
formatSpec = '%*s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

%% ���ı��ļ���
fileID = fopen(filename,'r');

%% ���ݸ�ʽ�ַ�����ȡ�����С�
% �õ��û������ɴ˴������õ��ļ��Ľṹ����������ļ����ִ����볢��ͨ�����빤���������ɴ��롣
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% �ر��ı��ļ���
fclose(fileID);

%% ���޷���������ݽ��еĺ�����
% �ڵ��������δӦ���޷���������ݵĹ�����˲������������롣Ҫ�����������޷���������ݵĴ��룬�����ļ���ѡ���޷������Ԫ����Ȼ���������ɽű���

%% �����������
zcor = [dataArray{1:end-1}];