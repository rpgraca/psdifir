function cfloat2hex36b( coefs_r )
% Usage:  cfloat2hex36b( varname )
%         Generate HEX files with the 16384 filter coefficients
%         'varname' is a 16384 float array with the filter coefficients
%         Files generated are: 
%         all coefficients: 'outcoefs_RAM03.hex'
%         coefs 0, 4, 8,...   : 'outcoefs_RAM0.hex'
%         coefs 1, 5, 9,...   : 'outcoefs_RAM1.hex'
%         coefs 2, 6, 10,...  : 'outcoefs_RAM2.hex'
%         coefs 3, 7, 11,...  : 'outcoefs_RAM3.hex'

lsize = length(coefs_r);
% Initialize vector with 16384 zeros:
coefs_ni36b = zeros(1, lsize );

% Integer signed coefficients:
coefs_ri = round( coefs_r * (2^35-1) );

% Frequency response with the 36 bit rounded coefficients:
figure(3);
fft_coefs = ( abs( fft( coefs_ri/2^35 ) ) );

% Plot em escala linear:
%fft_coefs = ( abs( fft( coefs_ri/2^35 ) ) );

freqs = linspace(1,48000,lsize);
plot( freqs(1:round(lsize/2)), fft_coefs(1:round(lsize/2)) );
grid
xlabel('Frequency (Hz) - Fsampling:48kHz');
ylabel('Gain');

% Convert to 36-bit integer, two's complement:
coefs_ni = int64( coefs_ri );

for i=1:length( coefs_ni )
    if ( coefs_ni(i) < 0 )
        coefs_ni36b(i) = int64( 2^36 - abs( double(coefs_ni(i)) ) );
    else
        coefs_ni36b(i) = int64( coefs_ni(i) );
    end
end

% Removed first and last coefficient
% Filter has 16383 coefficients, ignore last, set first to zero:
coefs_ni36b(1) = 0;

% Print output file:
fid = fopen('outcoefs_RAM03.hex','w+');
for i=1:length( coefs_ni36b )-1
   fprintf(fid, '%s\n', dec2hex(coefs_ni36b(i), 9) );
end
fclose( fid );

% Print output file, RAM0
fid = fopen('outcoefs_RAM0.hex','w+');
for i=1:4:length( coefs_ni36b )-1
   fprintf(fid, '%s\n', dec2hex(coefs_ni36b(i), 9) );
end
fclose( fid );

% Print output file, RAM1
fid = fopen('outcoefs_RAM1.hex','w+');
for i=2:4:length( coefs_ni36b )-1
   fprintf(fid, '%s\n', dec2hex(coefs_ni36b(i), 9) );
end
fclose( fid );

% Print output file, RAM2
fid = fopen('outcoefs_RAM2.hex','w+');
for i=3:4:length( coefs_ni36b )-1
   fprintf(fid, '%s\n', dec2hex(coefs_ni36b(i), 9) );
end
fclose( fid );

% Print output file, RAM3
fid = fopen('outcoefs_RAM3.hex','w+');
for i=4:4:length( coefs_ni36b )-1
   fprintf(fid, '%s\n', dec2hex(coefs_ni36b(i), 9) );
end
fclose( fid );
