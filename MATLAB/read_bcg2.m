clear; clc;
%데이터 읽기 
data = xlsread('bcg_all_ver2.xlsx');

%%
%데이터 길이, (BCG1,BCG2)의 수*2  
%BCG데이터 데이터량: 900* 1000 
[len, num] = size(data);

r_data = transpose(data);

%%

[len, num] = size(r_data);
%1,2 / 3,4/ 5,6/ 7,8..../129,130
for i=1:len/2
    for j = i+(i-1):i+i 
        %BCG1, BCG2 읽어오기  및 normalization
        if(j == i+(i-1))
            bcg(1,:) =( r_data(j,:)- mean(r_data(j,:))) /std(r_data(j,:));  
        else
            bcg(2,:) =( r_data(j,:)- mean(r_data(j,:))) /std(r_data(j,:));  
        end
    end
    noise_bcg = randn(1000,1)*std(bcg(1,:)*0.1);
    bcg(3,:) = noise_bcg;
    
    imf = memd(bcg,8,'stop');
    imf_x = reshape(imf(1,:,:),size(imf,2),length(bcg)); % imfs corresponding to 1st component
    imf_y = reshape(imf(2,:,:),size(imf,2),length(bcg)); % imfs corresponding to 2nd component
    
   
    %normalized bcg1, bcg2에 대한 csv파일
    dlmwrite('norm_bcg1.csv',bcg(1,:),'delimiter',',','-append');
    dlmwrite('norm_bcg2.csv',bcg(2,:),'delimiter',',','-append');
    
    [a,b] =size(imf_x);
        for i = 1:9
            dlmwrite('bcg1-imf.csv',imf_x(i,:),'delimiter',',','-append'); %BCG1에 대한 IMF 
        end
         for i = 1:9
            dlmwrite('bcg2-imf.csv',imf_y(i,:),'delimiter',',','-append'); %BCG2에 대한 IMF2
         end
         
       for k=1:9  
         %논문에서 IMF1을 사용했으므로 그를 이용해본다.
x = hilbert(imf_x(k,:));
y = hilbert(imf_y(k,:));
ang1 = angle(imf_x(k,:) + 1i* x); %BCG1
ang2 = angle(imf_y(k,:) + 1i * y); %BCG2


N = length(imf_x);

ip_1(k,:) = unwrap(ang1(1,:)); % 
ip_2(k,:) = unwrap(ang2(1,:)); %

      dlmwrite('bcg1_ip_data.csv',ip_1(k,:),'delimiter',',','-append'); %BCG1에 대한 ip
      dlmwrite('bcg2_ip_data.csv',ip_2(k,:), 'delimiter',',','-append'); %BCG2에 대한 IP

      %BCG1 450개 * IMF 9개 * 1000 = 4050 * 1000

for i = 1:N %IPD 구하는 작업 BCG 1 당 IMF 9개 -> n_ang = 9 * 1000
      n_ang(k,i) = unwrap(ang1(1,i))-unwrap(ang2(1,i));
      
end

dlmwrite('ipd_data.csv',n_ang(k,:),'delimiter',',','-append'); %BCG1에 대한 IPD

       end
%BCG1,BCG2 묶음 450개 (총 데이터는 900 * 1000)에 대해서
%imf 개수는 9개로 정함. 
%ipd data = 450*9개가 나와야 함 (4050 x 1000) 
%ip data = 450*9개가 나와야 함  ( 4050x 1000)

%bcg1-imf : bcg1 하나당 imf 9개이므로 450 * 9 -> 4050 * 1000
%bcg2-imf: 위와 같음 

%norm_bcg1 : bcg1을 normalization한 것으로 450개의 bcg1에 대한 것임.-> 450*1000
%norm_bcg2: 위와 같음 
    end
    

    




