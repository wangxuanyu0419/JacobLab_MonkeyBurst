function txt = get_mat_comment(x)
% Gets matfile comment which can be useful to determine the matfile version.
% 
% Input
% -----
% x: str
%   Filepath to mat file.
%
% Output
% ------
% txt: str
%   Matfile comment.

    fid=fopen(x);
    txt=char(fread(fid,[1,140],'*char'));
    txt=[txt,0];
    txt=txt(1:find(txt==0,1,'first')-1);
    fclose(fid);
end
