function plotcoefs36b( coefs_filename )
% Usage:  plotcoefs36b( filename )
%         Plots the impulse response and FFT of the 4096 tap FIR filter
%         defined by the coefficients listed in file 'filename'
%         in two's complement, 36 bit (hex format), one value per line
%         (example in file 'outcoefs_RAM03.hex')


coefs = zeros(1,4096);
fid = fopen( coefs_filename, 'r' );
for i=1:4096
  coefs(i) = hex2dec( fscanf( fid, '%s\n', 1 ) );
end
fclose( fid );

% Convert to signed values:
for i=1:length( coefs )
    if coefs(i) > 2^35
        coefs(i) = coefs(i) - 2^36;
    end
end

fft_coefs = 20*log10( abs( fft( coefs/2^35 ) ) );

subplot(2,1,1); 
plot( coefs/2^35 ); 
grid;
xlabel('Sample');
title('Impulse response');

freqs = linspace(1,48000,4096);
subplot(2,1,2);
plot( freqs(1:2048), fft_coefs(1:2048) );
grid;
xlabel('Frequency (Hz)');
title('Frequency response');
