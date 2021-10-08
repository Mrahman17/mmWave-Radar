[m,n]=size(rp);
    ns = size(rp,2)+2;
    h=[1 -2 1]';
    %ns=n+length(h)-1
    rngpro=zeros(m,ns);
    for k=1:m
        rngpro(k,:)=conv(h,rp(k,:));
    end
     % range profiles
    figure
    colormap(jet)
    imagesc(20*log10(abs(rngpro)+eps))
    xlabel('No. of Sweeps')
    ylabel('Range cells')
    title('Range Profiles after MTI Filtering')
    clim = get(gca,'CLim');
    set(gca, 'CLim', clim(2)+[-40,0]);