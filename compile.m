function compile(verb)

if nargin < 1
	verb = false;
end

cd cpp;

files = dir('./*.cc');

for n = 1:length(files)
	fname = files(n).name;
    
    if strcmp(fname, 'fv_cache.cc') ...
        || strcmp(fname, 'obj_func.cc')
        continue;
    end

	fprintf_flush('Compiling %s ...\n', fname);	
    
    fmex = [fname(1:end-3) '.mex'];		
    eval([octcmd(verb) ' ' fname ' -o ../bin/' fmex]);
end

% compile fv_cache
fprintf_flush('Compiling fv_cache ...\n');	

fv_compile(verb);

% clean up
delete *.o;

cd ..;

end

function cmd = octcmd(verb)

cmd = 'mkoctfile --mex -Wall';

if verb
	cmd = [cmd ' -v'];
end
end

function fv_compile(verb)

if ispc
  error('fv_cache is not supported on Windows.');
end

%setenv('CXXFLAGS', '-fopenmp');

mexcmd = ' mkoctfile --mex -lgomp';

if verb
    mexcmd = [mexcmd ' -v'];
end

mexcmd = [mexcmd ' fv_cache.cc obj_func.cc' ' -o ../bin/fv_cache.mex'];

try
  eval(mexcmd);
catch e
  % The fv_cache uses static structures to maintain the cache in memory.
  % To avoid hard to track bugs, the fv_cache locks itself so that the
  % mex binary cannot be unloaded and reloaded without explicitly first
  % unlocking the binary.
  warning(e.identifier, 'Maybe you need to call fv_cache(''unlock'') first?');
end

end
