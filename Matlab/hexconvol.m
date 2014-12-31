function hexconvol( coefs_filename, input_filename )
% Usage:  hexconvol( coefs_filename, input_filename )
%         Calculates the convolution between the two vectors
%         listed in files in hex format. Coefs is represented in
%         hexdecimal as 36 bit signed values with 35 fractional bits;
%         the input signal is represented in hexadecimal as 18 bit signed

lsize = 16384;
% read coefficients:
coefs = zeros(1,lsize);
fid = fopen( coefs_filename, 'r' );
for i=1:lsize
  coefs(i) = hex2dec( fscanf( fid, '%s\n', 1 ) );
end
fclose( fid );

% Convert to signed values:
for i=1:length( coefs )
    if coefs(i) > 2^35
        coefs(i) = coefs(i) - 2^36;
    end
end
% Scale to 35 bits fractional part:
% coefs = coefs/2^35;

for i=1:10
    fprintf('%d, ', coefs(i) );
end
fprintf('\n');
for i=lsize:-1:lsize-10
    fprintf('%d, ', coefs(i) );
end

% read input test signal:
fid = fopen( input_filename, 'r' );
xin = fscanf( fid, '%lx\n');
fclose( fid );

% Convert to signed values:
for i=1:length( xin )
    if xin(i) > 2^17
        xin(i) = xin(i) - 2^18;
    end
end

whos
% Calculate convolution, use only the first 10000 input samples:
yout = conv( coefs, xin );
yout = round( yout ./ 2^35 );

figure(4);
subplot(3,1,1);
plot(xin(1:10000));
title('Input signal');
grid;

subplot(3,1,2);
plot( coefs/2^35,'.-r');
title('Filter impulse response');
grid;

subplot(3,1,3);
plot( yout(1:10000) );
title('Output signal');
grid;

figure(5)
subplot(3,1,1)
freqs = linspace(0,48000,lsize);
fft_coefs = ( abs( fft( coefs ) ) );
plot( freqs(1:round(lsize/8)), fft_coefs(1:round(lsize/8)) );
grid;
xlabel('Frequency (Hz)');
title('Filter frequency response');

subplot(3,1,2);
xsize = length( xin );
fft_in = ( abs( fft( xin ) ) );
freqs = linspace(0,48000,xsize);
plot( freqs(1:round(xsize/8)), fft_in(1:round(xsize/8)) );
grid;
xlabel('Frequency (Hz)');
title('Input spectrum');

subplot(3,1,3);
yout1 = yout(9000: 48000-9000 );
ysize = length( yout1 );
fft_out = ( abs( fft( yout1 ) ) );
freqs = linspace(0,48000,ysize);
plot( freqs(1:round(ysize/8) ), fft_out(1:round(ysize/8)) );
grid;
xlabel('Frequency (Hz)');
title('Output spectrum');

% Create the golden output file:
% Convert yout to two's complement, 18 bits:
yout_i = int32(yout);
for i=1:length( yout_i )
    if ( yout_i(i) < 0 )
        yout_i(i) = 2^18 - abs( yout_i(i) );
    end
end
fid = fopen('goldenout.hex','w+');
fprintf( fid, '%05X\n', yout_i );
fclose( fid );
fprintf('Created golden output file to goldenout.hex\n');
