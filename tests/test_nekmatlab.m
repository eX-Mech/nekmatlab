%% Tests for nekmatlab package
%
% Jacopo Canton and Nicol? Fabbiane (in alphabetical order)
%
% January, 2016
%

function [status,err] = test_nekmatlab

%% Generate test flow field
lr1o = [5 5 1]';

xel = (cos(linspace(0,pi,lr1o(1)))+1)/2;
yel = (cos(linspace(0,pi,lr1o(2)))+1)/2;

xgr = [xel(1:end-1)-1 xel(1:end)];
ygr = [yel(1:end-1)-1 yel(1:end)];

[xxo,yyt] = meshgrid(xgr,ygr);

uuo = 1-yyt.^2;
vvo =   yyt.*0 + .1*(rand(size(yyt))*2-1);
ppo = 1+yyt.*0;
tto = 1+yyt.*0;


%% Test demeshnek/reshapenek
nelx = 2; nely = 2;

mesho = zeros(lr1o(1)*nelx-1,lr1o(2)*nely-1,6);
mesho(:,:,1) = xxo;
mesho(:,:,2) = yyt;
mesho(:,:,3) = uuo;
mesho(:,:,4) = vvo;
mesho(:,:,5) = ppo;
mesho(:,:,6) = tto;

datao = demeshnek(mesho,lr1o);

mesht = 0* mesho;
[mesht(:,:,1),mesht(:,:,2),mesht(:,:,3),...
 mesht(:,:,4),mesht(:,:,5),mesht(:,:,6)] = reshapenek(datao,nelx,nely);

errm = abs(max(max(max(mesht-mesho,[],1),[],2),[],3));

err(1) = errm > 1e-16;


%% Test writenek
elmapo  = 1:size(datao,1);
timeo   = rand(1);
istepo  = round(rand(1)*1e3);
fieldso = 'XUPT';
emodeo  = 'le';
wdszo   = 8;
etago   = 6.54321;

err(2) = writenek('test.fld',datao,lr1o,elmapo,timeo,istepo,fieldso,emodeo,wdszo,etago);


%% Test readnek

[datat,lr1t,elmapt,timet,istept,fieldst,emodet,wdszt,etagt,header,err(3)] = readnek('test.fld');

i = 0;
i = i+1; errwr(i) = abs(max(max(max(datat-datao,[],1),[],2),[],3));
i = i+1; errwr(i) = abs(max(lr1t-lr1o));
%i = i+1; errwr(i) = abs(max(elmapt-elmapo));
i = i+1; errwr(i) = abs(timet-timeo);
i = i+1; errwr(i) = abs(istept-istepo);
i = i+1; errwr(i) = ~strcmpi(fieldst,fieldso);
i = i+1; errwr(i) = ~strcmpi(emodet,emodeo);
i = i+1; errwr(i) = abs(wdszt-wdszo);
i = i+1; errwr(i) = abs(etagt-etago) >= 1e-5;

err(4) = max(errwr) > 1e-11;


%% Final status
status = sum(err)==0;