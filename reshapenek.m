function varargout = reshapenek(data,nelx,nely)
%
% Reshape data from nekread to a meshgrid
%
%   [meshgrid1,meshgrid2,...] = reshapenek(data,nelx,nely)
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