clear;clc;
name = 'bcg_data';  %bcg ���� �̸� 

% PPG ���� �ٲٱ�!!!!! %
exi=0;
s= dir("");
while true
    cd 'C:\Users\user1617\data\data0'
    exi= exist(name) ;  
   
    if(exi ~= 0)
        s = dir(name);
        s.bytes
        %the_size = s.bytes
        flag = 0;
    %    A = importdata(name,';',1);
     %   data = A.data;
      %  [numRows,numCols] = size(data);
    end
if(size(s,1) ~= 0 && s.bytes ~=0)
     A = importdata(name,';',1);
        data = A.data;
 if (length(data)>=15000&&s.bytes ~= 0 && (exi ~= 0)) %������ �����ϰ� ũ�Ⱑ �ִٸ� 
      flag = 1;
      A = importdata(name,';',1);
      data = A.data; 
      data(:,3) = []; %3��° �� ���� 
      %data(:,1) = [];
      data(15001:length(data),:) = []; 
      [ResMove,dy] = resample(data ,2,5); %Resampling 
      
      [len, num] = size(data); %10
k=1;
kk = 2;
for i=1:num %10
    temp = data(:,i); %15000 -> 1000 * 15���� �ɰ��Ŵ�. 
    if (rem(i,2) == 1) %Ȧ����
        for j = 1:1000:15000 % 1, 1001, 2001, 3001,....
            temp2 = temp(j:j+999); %1*1000
            temp3(:,k) = transpose(temp2);
            k = k + 2;
        end
    else %¦���� 
        for j = 1:1000:15000 % 1, 1001, 2001, 3001,....
            temp2 = temp(j:j+999); %1*1000
            temp3(:,kk) = transpose(temp2);
            kk = kk + 2;
        end
    end   
end

dlmwrite('new_all.csv',temp3,'delimiter',',','-append');

%% ipd �ѱ�� �۾� 
data2 = xlsread('new_all.csv');

%������ ����, (BCG1,BCG2)�� ��*2  
%BCG������ �����ͷ�: 730  *1000
[len, num] = size(data2);

r_data = transpose(data2);
bcg = zeros(3,1000);
imf = 0;
imf_x = zeros(11,1000);
imf_y = zeros(11,1000);
N = 0;
ang1 = zeros(1,1000);
ang2 = zeros(1,1000);
x = zeros(1,1000);
y= zeros(1,1000);
n_ang = zeros(9,1000);

[len, num] = size(r_data);
%1,2 / 3,4/ 5,6/ 7,8..../129,130
cd 'C:\Users\user1617\data\data2'

   n_ang(1,1:1000) = 0;
   dlmwrite('ipd_data.csv',n_ang(1,:),'delimiter',',');
for i=1:len/2
    for j = i+(i-1):i+i 
        %BCG1, BCG2 �о����  �� normalization
        if(j == i+(i-1))
            bcg(1,:) =( r_data(j,:)- mean(r_data(j,:))) /std(r_data(j,:));  
        else
            bcg(2,:) =( r_data(j,:)- mean(r_data(j,:))) /std(r_data(j,:));  
        end
    end
    bcg(3,:) = randn(1000,1)*std(bcg(1,:)*0.1); %noise 
    imf = memd(bcg,8,'stop');
    imf_x = reshape(imf(1,:,:),size(imf,2),length(bcg)); % imfs corresponding to 1st component
    imf_y = reshape(imf(2,:,:),size(imf,2),length(bcg)); % imfs corresponding to 2nd component
    N = length(imf_x);         
 
    for k=2:10 % ���� 1~9 ������ 2~10   
        x = hilbert(imf_x(k-1,:));
        y = hilbert(imf_y(k-1,:));
        ang1 = angle(imf_x(k-1,:) + 1i* x); %BCG1
        ang2 = angle(imf_y(k-1,:) + 1i * y); %BCG2
        for i = 1:N %IPD ���ϴ� �۾� BCG 1 �� IMF 9�� -> n_ang = 9 * 1000
             n_ang(k,i) = unwrap(ang1(1,i))-unwrap(ang2(1,i));
        end
        dlmwrite('ipd_data.csv',n_ang(k,:),'delimiter',',','-append'); %BCG1�� ���� IPD
    end
end
    
cd 'C:\Users\user1617\data\result'
data = transpose(ResMove); %BCG2(������), BCG1(��) ���� 
 
r_data = zeros(2,6000); %1�� 100��  //3��ġ 18000���� 0.4�ؼ� 7200�� 
r_data(1,:) = data(2,1:6000); %BCG2
r_data(2,:) = data(1,1:6000); %BCG1


%1�� �����Ѵ� ġ��, 15�ʾ� window�� �Űܰ��� ������ �ؼ� ����� ����. -> 4�� ���
%4���� 
k = 6000; %60�� 
add = 1500; %15��

results = zeros(2,4);  
rr_ind = 1;

%for i = 0:2 %2�д뿡 ���� for��
    i = 0;
    com1 =  1;
    com2 = 1500;
    r_ind = 1;
 
    for j=1:4 % 1�д� ���� 4���� 
        min_data = r_data(1, com1 + (i*6000) :com2 + (i*6000)); %1~1500, 1501~3000, 3001~4500, 4501~6000
        com1 = com2 + 1;
        com2 = com2 + 1500;
       
bcgresult(1,:) = (min_data(1,:)-mean(min_data(1,:)))/std(min_data(1,:));
ResMove = bcgresult(1,:);

%ResMove = min_data;
Fs = 100;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = length(ResMove);             % Length of signal
t = (0:L-1)*T;        % Time vectorxx
NFFT = length(ResMove);

N = 6;
Fc1 = 1.05;  % First Cutoff Frequency  ������ 0.83
Fc2 = 2.5;   % Second Cutoff Frequency

HR_filter = iir(N, Fc1, Fc2, Fs);

N=8;
Fc1 = 0.2;  % First Cutoff Frequency
Fc2 = 0.48;  %Second Cutoff Frequency

Res_filter = iir(N,Fc1, Fc2, Fs);

S = fft(ResMove,NFFT);
P2 = abs(S/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;


ymr = filtfilt(Res_filter.sosMatrix,1000, ResMove);
S = fft(ymr);
P2 = abs(S/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;


[pL, fL] = max(P1(2:end));
f1 = fL*Fs/L;
RESP2 = 60/(1/(f1));

results(1,r_ind) = RESP2;


ymh = filtfilt(HR_filter.sosMatrix,1000,ResMove);



S = fft(ymh);
P2 = abs(S/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;


[pL, fL] = max(P1(2:end));
f2 = fL*Fs/L;
HEART2= 60/(1/(f2)) ;

results(2,r_ind) = HEART2;
r_ind = r_ind+ 1;

    end

info = zeros(1,2);
info(1,1) = sum(results(1,1:4))/4; %�� ���� ��� �ѹ� ���þ� 
info(1,2) = sum(results(2,1:4))/4;

dlmwrite('heart.txt',info(1,2)); 
dlmwrite('resp.txt',info(1,1));

%end

 end
  pause(1);

   if (exi && flag == 1)
        cd 'C:\Users\user1617\data\data0'
        delete (name)
        %cd 'C:\Users\user1617\data\data2'
        %delete ipd_data.csv
        delete new_all.csv
        exi = 0;
disp("Calculated ...")
   end
    s.bytes = 0;
end 
    
end

  