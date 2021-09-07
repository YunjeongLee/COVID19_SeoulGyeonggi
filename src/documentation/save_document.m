function [] = save_document(lt, filename)
fileID = fopen(filename, 'w');
formatSpec = '%s\n';
[nrows,~] = size(lt);
for row = 1:nrows
    fprintf(fileID,formatSpec,lt{row,:});
end
fclose(fileID);
