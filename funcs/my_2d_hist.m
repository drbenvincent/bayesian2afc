function [density,bx,by]=my_2d_hist(x,y , nxbins,nybins)
% Converts 2D scatter x,y data into a 2D grid image of density


bx=linspace(min(x),max(x),nxbins);

by=linspace(min(y),max(y),nybins);

xbinhalfwidth=abs(bx(2)-bx(1));
ybinhalfwidth=abs(by(2)-by(1));

density=zeros(length(bx),length(by));

for cx=1:length(bx)
    
    for cy=1:length(by)
        
        SET = (x > (bx(cx)-xbinhalfwidth) & x < (bx(cx)+xbinhalfwidth))...
            & (y > (by(cy)-ybinhalfwidth) & y < (by(cy)+ybinhalfwidth));
        
        density(cx,cy)=sum(SET);
        
        clear SET
        
    end
end


imagesc(bx,by,density')
axis xy

end

% hold on
% 
% plot(x,y,'.','MarkerSize',1)
% hold off