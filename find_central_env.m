function new_env=find_central_env(img_matrix,central_lim)

central_env = zeros(1,size(img_matrix,2));
Sum = 0;
[b,a]=butter(2,10/(250/2));
%% Central envelope
for t = 1:size(img_matrix,2)  
    for v = size(img_matrix,1):-1:1
        Sum = Sum + img_matrix(v,t);
        if (Sum > central_lim(t))
         
                Sum = 0;
                break
           
        end
    end
    central_env(t) = v;
end
%central_env=filtfilt(b,a,central_env);
%% Central envelope2
for t = 1:size(img_matrix,2)  
    for v = 1:1:size(img_matrix,1)
        Sum = Sum + img_matrix(v,t);
        if (Sum > central_lim(t))
         
                Sum = 0;
                break
           
        end
    end
    central_env2(t) = v;
end

two_cntrl=zeros(2,length(central_env2));
two_cntrl(1,:)=central_env;
two_cntrl(2,:)=central_env2;
mean_2=mean(two_cntrl);
%figure; plot(-1*(central_env),'m','LineWidth',2);hold on; plot(-1*(central_env2),'y','LineWidth',2); hold on; plot(-1*(mean_2),'c','LineWidth',2);
new_env=zeros(1,length(mean_2));

for idx=1:length(mean_2)
    if mean_2(idx)>central_env(idx)&& mean_2(idx)<mean_2(1)
        new_env(idx)=central_env(idx);
     
    elseif  mean_2(idx)>central_env(idx)&& mean_2(idx)>mean_2(1)
        new_env(idx)=central_env2(idx);
    end
end
new_env(1)=central_env(1);
new_env=filtfilt(b,a,new_env);