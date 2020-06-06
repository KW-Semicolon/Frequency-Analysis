clear; clc;
%데이터 읽기 
data = xlsread('bcg_all_ver2.xlsx');

%%
%데이터 길이, (BCG1,BCG2)의 수*2  
%BCG데이터 데이터량: 724  *1000
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
    %imf_z = reshape(imf(3,:,:),size(imf,2),length(bcg)); % imfs corresponding to 3rd component
   
    %normalized bcg1, bcg2에 대한 csv파일
    dlmwrite('norm_bcg1.csv',bcg(1,:),'delimiter',',','-append');
    dlmwrite('norm_bcg2.csv',bcg(2,:),'delimiter',',','-append');
    
    [a,b] =size(imf_x);
        for i = 1:a
            dlmwrite('bcg1-imf.csv',imf_x(i,:),'delimiter',',','-append'); %BCG1에 대한 IMF 
        end
         for i = 1:a
            dlmwrite('bcg2-imf.csv',imf_y(i,:),'delimiter',',','-append'); %BCG2에 대한 IMF2
         end
         
         
         %논문에서 IMF1을 사용했으므로 그를 이용해본다.
x = hilbert(imf_x(1,:));
y = hilbert(imf_y(1,:));
ang1 = angle(imf_x(1,:) + 1i* x); %BCG1
ang2 = angle(imf_y(1,:) + 1i * y); %BCG2


N = length(imf_x);

ip_1 = unwrap(ang1(1,:)); % 1x 1000 
ip_2 = unwrap(ang2(1,:)); % 1 x 1000

      dlmwrite('bcg1_ip_data.csv',ip_1(1,:),'delimiter',',','-append'); %BCG1에 대한 ip
      dlmwrite('bcg2_ip_data.csv',ip_2(1,:), 'delimiter',',','-append'); %BCG2에 대한 IP


for i = 1:N
      n_ang(1,i) = unwrap(ang1(1,i))-unwrap(ang2(1,i));
end

dlmwrite('ipd_data.csv',n_ang(1,:),'delimiter',',','-append'); %BCG1,BCG2에 대한 IPD


%BCG1,BCG2 묶음 3개에 대해서
%ipd data = 3000개가 나와야 함 (3 x 1000) 
%ip data = 3000개가 나와야 함  ( 3x 1000)
    end
    

    




