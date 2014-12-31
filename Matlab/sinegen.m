% Generate a test signal with a sum of sines quantrized to 18 bits:
% PSD 2014/2015 - (c) FEUP 2014 jca@fe.up.pt

% Set the sampling frequency:
fs = 48000;

% One second, 48 Khz:
t = linspace(0,1,fs);

% generate a sum of sines, unit amplitude, set the frequencies in Hz:
freqs = [  600  800 1000 1200 1400 1600 1800 ...
          1980 2000 2200 2400 2600 2800 3000 3020 3200 ...
          3400 3600 3800 ];

sineout = zeros(1, length( t ) );

for i=1:length( freqs )
    s1 = sin( 2*pi*freqs(i)*t );
    sineout = sineout + s1;
end

maxsineout = max( abs( sineout ) );

% Normalize to [+1, -1]:
sineout = sineout / maxsineout;

% Convert to 18 bits signed:
sineout_ri = round( sineout * (2^17-1) );
sineout_ii = int32( sineout_ri );

figure(1);
plot( t(1:1000), sineout_ii(1:1000),'.-');
grid;
title('Test signal');
xlabel('Time (s)');
ylabel('Amplitude sampled to 18 bits');

figure(2);
f = linspace(0, fs/4, length( sineout ) / 4 );
sfft = ( abs( fft( sineout.*hamming( length(sineout) )' ) ) );
plot(f, sfft(1:length( sineout ) / 4) );
axis( [0 fs/8 -100 1000] );
grid;
title('FFT of test signal');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

% Convert to two's complement, 18 bits:
for i=1:length( sineout_ii )
    if ( sineout_ii(i) < 0 )
        sineout_ii(i) = 2^18 - abs( sineout_ii(i) );
    end
end
fid = fopen('testsine.hex','w+');
fprintf( fid, '%05X\n', sineout_ii );
fclose( fid );

fprintf('Created output file testsine.hex for Verilog task $readmemh()\n');

