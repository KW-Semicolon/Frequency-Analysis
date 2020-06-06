clear; clc;
%데이터 읽기 
data = xlsread('bcg_sub60.csv');

%%
%데이터 길이, (BCG1,BCG2)의 수*2  
%BCG데이터 데이터량: 730  *1000
[len, num] = size(data);

r_data = transpose(data);
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

%%


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
    bcg(3,:) = randn(1000,1)*std(bcg(1,:)*0.1);
    imf = memd(bcg,8,'stop');
    imf_x = reshape(imf(1,:,:),size(imf,2),length(bcg)); % imfs corresponding to 1st component
    imf_y = reshape(imf(2,:,:),size(imf,2),length(bcg)); % imfs corresponding to 2nd component
    N = length(imf_x);         
    for k=1:9  
        x = hilbert(imf_x(k,:));
        y = hilbert(imf_y(k,:));
        ang1 = angle(imf_x(k,:) + 1i* x); %BCG1
        ang2 = angle(imf_y(k,:) + 1i * y); %BCG2
        for i = 1:N %IPD 구하는 작업 BCG 1 당 IMF 9개 -> n_ang = 9 * 1000
             n_ang(k,i) = unwrap(ang1(1,i))-unwrap(ang2(1,i));
        end
        dlmwrite('ipd_data2.csv',n_ang(k,:),'delimiter',',','-append'); %BCG1에 대한 IPD

   end

 end
    

    




