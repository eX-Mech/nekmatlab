function [data,lr1,elmap,time,istep,fields,emode,wdsz,etag,header,status,metax,metau,metap,metat] = readnek(fname)
%
% This function reads binary data from the nek5000 file format
%
%   [data,lr1,elmap,time,istep,fields,emode,wdsz,etag,header,status] = readnek(fname)
%
%   INPUT
%   - fname:  name of the file 
%
%   OUTPUT
%   - data:   nek5000 data ordered as (iel,inode,[x|y|(z)|u|v|(w)|p|T|s_i])
%   - lr1:    element-size vector (lx1,ly1,lz1)
%   - elmap:  reading/writing map of the elements in the file
%   - time:   simulation time
%   - istep:  simulation step
%   - fields: fields saved in the file
%   - emode:  endian mode 'le' = little-endian, 'be' = big-endian
%   - wdsz:   single (4) or double (8) precision
%   - etag:   tag for endian indentification
%   - header: header of the file (string)
%   - status: status (< 0 something went wrong)
%   - metax:  metadata for coordinates
%   - metau:  metadata for velocity field
%   - metap:  metadata for pressure field
%   - metat:  metadata for temperature field
%   - metas:  metadata for passive scalar field(s)
%
%
% Last edit: 20170810 Jacopo Canton (jcanton@mech.kth.se)
%

%--------------------------------------------------------------------------
%  INITIALIZE OUTPUT
%--------------------------------------------------------------------------
data   = [];
etag   = [];
lr1    = [];
elmap  = [];
time   = [];
istep  = [];
fields = [];
wdsz   = [];
header = [];

metax = [];
metau = [];
metap = [];
metat = [];
metas = [];

%--------------------------------------------------------------------------
%  OPEN THE FILE
%--------------------------------------------------------------------------
emode = 'le';
[infile,message] = fopen(fname,'r',['ieee-' emode]);
if infile == -1, disp(message), status = -1; return, end
%
% read header
header = fread(infile,132,'*char')';
%
% check endian
etag = round(fread(infile,1,'*float32')*1e5);
if (etag ~= 654321)
    fclose(infile);
    
    emode = 'be';
    [infile,message] = fopen(fname,'r',['ieee-' emode]);
    
    header = fread(infile,132,'*char')';
    etag = round(fread(infile,1,'*float32')*1e5);
    
    if (etag ~= 654321)
        disp('ERROR: could not interpret endianness.')
        status = -3; return
    end
end
etag = etag * 1e-5;

%--------------------------------------------------------------------------
% READ HEADER
%--------------------------------------------------------------------------
%
% word size
wdsz = str2double(header(6));
if (wdsz == 4)
    realtype = '*float32';
elseif (wdsz == 8)
    realtype = '*float64';
else
    fprintf('ERROR: could not interpret real type (wdsz = %i)',wdsz);
    status = -2; return
end
%
% element size
lr1 = [str2double(header(8:9))
       str2double(header(11:12))
       str2double(header(14:15))];
%
% compute the total number of points per element
npel = prod(lr1);
%
% compute number of active dimensions
ndim = 2 + (lr1(3)>1);
%
% number of elements
nel = str2double(header(17:26));
%
% number of elements in the file
nelf = str2double(header(28:37));
%
% time
time = str2double(header(39:58));
%
% istep
istep = str2double(header(60:68));
%
% get file id  
fid = str2double(header(70:75)); % TODO: multiple files not supported
%
% get tot number of files
nf = str2double(header(77:82)); % TODO: multiple files not supported
%
% getfields [XUPT]
fields = strtrim(header(84:end));
var=zeros(1,5);
if sum(fields == 'X') > 0
  var(1) = ndim;
end
if sum(fields == 'U') > 0
  var(2) = ndim;
end
if sum(fields == 'P') > 0
  var(3) = 1;
end
if sum(fields == 'T') > 0
  var(4) = 1;
end
if sum(fields == 'S') > 0
  ids = find(fields == 'S');
  var(5) = sscanf(fields(ids+1:ids+2),'%d',1);
end
nfields = sum(var);
%
% read element map
elmap = fread(infile,nelf,'*int32').';

%--------------------------------------------------------------------------
% READ DATA
%--------------------------------------------------------------------------
data = zeros(nelf,npel,nfields);
for ivar = 1:length(var)
    idim0 = sum(var(1:ivar-1));
    for iel = elmap
        for idim = (1:var(ivar))+idim0
            data(iel,:,idim) = fread(infile,npel,realtype);
        end
    end
end

%--------------------------------------------------------------------------
% READ "METADATA": max and min of every field in every element
%--------------------------------------------------------------------------
% this is forced to being written in single precision
if ndim == 3
	if var(1) ~= 0
		metax = fread(infile,2*ndim*nel,'*float32');
	else
		metax = [];
	end
	if var(2) ~= 0
		metau = fread(infile,2*ndim*nel,'*float32');
	else
		metau = [];
	end
	if var(3) ~= 0
		metap = fread(infile,2*nel,'*float32');
	else
		metap = [];
	end
	if var(4) ~= 0
		metat = fread(infile,2*nel,'*float32');
	else
		metat = [];
	end
	if var(5) ~= 0
		metas = fread(infile,2*nel*var(5),'*float32');
	else
		metas = [];
	end
end


%--------------------------------------------------------------------------
% CLOSE FILE
%--------------------------------------------------------------------------
status = fclose(infile);
