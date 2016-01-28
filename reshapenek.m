function varargout = reshapenek(data,nelx,nely)
%
% Reshape data from nekread to a meshgrid
%
%   [meshgrid1,meshgrid2,...] = reshapenek(data,nelx,nely)
%
%   INPUT
%   - data:   nek5000 data ordered as (iel,inode,[x|y|(z)|u|v|(w)|p|T|s_i])
%   - nelx:   number of element in the first direction (second index)
%   - nely:   number of element in the second direction (first index)
%
%   OUTPUT
%   - meshgridn: meshgrid of the n-th field in data
%
% Last edit: 20151028 Nicolo Fabbiane (nicolo@mech.kth.se)
%


% get dimension and check number of elements
[nel,N2,nfld] = size(data); N = sqrt(N2);

if nel ~= nelx*nely
    disp('Error: nel ~= nelx*nely.');
    return
end

% check output
if nfld < nargout
    disp('Error: nfld < outputs.');
    return
end

% reshape data
for ifld = 1:min([nfld,nargout])
    mesh = zeros((N-1)*nely+1,(N-1)*nelx+1);
    
    for iel = 1:nel
        
        ielx = floor((iel-1)/nely) + 1;
        iely = mod(iel-1,nely) + 1;
        
        ii = (0:N-1) + (N-1)*(ielx-1) + 1;
        jj = (0:N-1) + (N-1)*(iely-1) + 1;
        
        mesh(jj,ii) = reshape(data(iel,:,ifld),N,N)';
        
    end
    
    varargout{ifld} = mesh;
end
