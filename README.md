# NEK5000 utilities for MATLAB

Nicolo` Fabbiane <br /> 
January, 2016


## Functions

### readnek.m
This function reads binary data from the nek5000 file format

`[data,lr1,elmap,time,istep,fields,emode,wdsz,etag,header,status] = readnek(fname)`

input
   - `fname:  name of the file 

output
   - `data`:   nek5000 data ordered as (iel,inode,[x|y|(z)|u|v|(w)|p|T|s_i])
   - `lr1`:    element-size vector (lx1,ly1,lz1)
   - `elmap`:  reading/writing map of the elements in the file
   - `time`:   simulation time
   - `istep`:  simulation step
   - `fields`: fields saved in the file
   - `emode`:  endian mode 'le' = little-endian, 'be' = big-endian
   - `wdsz`:   single (4) or double (8) precision
   - `etag`:   tag for endian indentification
   - `header`: header of the file (string)
   - `status`: status (< 0 something went wrong)

