%--------------------------------------
% CSCI 59000 Biometrics - Track shoulder shrugging
% Author: Chu-An Tsai
% 04/27/2020
%--------------------------------------

clear, clc;

fileName = 'test.mp4';  
obj = VideoReader(fileName);
numFrames = obj.NumberOfFrames;   

frame = read(obj,1);       
imwrite(frame,'1.jpg');

% Catch the base position of shoulders from the first frame -------------------------------------------------------------------------------

%for each frame:
[X,map] = imread('1.jpg');
I1 = rgb2gray(X); I1 = double(I1)/255;
I1 = imresize(I1,.8);

%viola-jones:
faceDetector = vision.CascadeObjectDetector();
BB = step(faceDetector,I1); %==>[mincol,minrow,colwidth,rowwidth]
FCE = I1(BB(2):BB(2)+ BB(4),BB(1):BB(1)+BB(3)); %region only
%visualize:
SF = insertShape(I1,'Rectangle',BB);

%LEFT SIDE
Lbox = [round(BB(1)-(BB(3)/2.5)+20),round(BB(2)+(BB(4)/1.5)),round(BB(3)/2.5),BB(4)/1.4];
Lsd = I1(Lbox(2):Lbox(2)+Lbox(4),Lbox(1):Lbox(1)+Lbox(3));
%visualize:
SLbox = insertShape(SF,'Rectangle',Lbox);

%RIGHT SIDE
Rbox = [BB(1)+BB(3)-20,round(BB(2)+(BB(4)/1.5)),round(BB(3)/2.5),BB(4)/1.4];
Rsd = I1(Rbox(2):Rbox(2)+Rbox(4),Rbox(1):Rbox(1)+Rbox(3));
%visualize:
SRbox = insertShape(SLbox,'Rectangle',Rbox);

Pl = [];
for col = 1:size(Lsd,2)-5 %to average 5 columns and stay in bound
    %use average column value per row(sliding window)
    avg = [];
    for dr = 1:size(Lsd,1)
        v = mean(Lsd(dr,col:col+5)); %average 5 columns
        avg = [avg;v];
    end
    pks = fpeak([1:size(Lsd,1)],avg); %see link   
    g = gradient(pks(:,2));
    [m,idx] = min(g); %depends on contrast:dark foreground vs bright background
    Pl = [Pl;[Lbox(2)+pks(idx-1,1),Lbox(1)+col]];
end
Pr = [];
for col = 1:size(Rsd,2)-5 %to average 5 columns and stay in bound
    %use average column value per row(sliding window)
    avg = [];
    for dr = 1:size(Rsd,1)
        v = mean(Rsd(dr,col:col+5));%average 5 columns
        avg = [avg;v];
    end
    pks = fpeak([1:size(Rsd,1)],avg);%see link
    g = gradient(pks(:,2));
    [m,idx] = min(g);%depends on contrast:dark foreground vs bright background
    Pr = [Pr;[Rbox(2)+pks(idx-1,1),Rbox(1)+col]];
end

pL = polyfit(Pl(:,2),Pl(:,1),1);
xL = [min(Pl(:,2)):max(Pl(:,2))]; 
rowvalL_base = polyval(pL,xL);  
pR = polyfit(Pr(:,2),Pr(:,1),1);
xR = [min(Pr(:,2)):max(Pr(:,2))]; 
rowvalR_base = polyval(pR,xR);

% Start to process each frame ------------------------------------------------------------------------------------

 for i = 1 : numFrames     
    frame = read(obj,i);                                             
    imwrite(frame,strcat(num2str(i), '.jpg' ), 'jpg' );
    
    %---------------------------------
    
    %for each frame:
    [X,map] = imread([num2str(i),'.jpg']);
    I1 = rgb2gray(X); I1 = double(I1)/255;
    I1 = imresize(I1,.8);
    I_color = imresize(X,.8);

    %viola-jones:
    faceDetector = vision.CascadeObjectDetector();
    BB = step(faceDetector,I1); %==>[mincol,minrow,colwidth,rowwidth]
    if length(BB(:,1)) >= 2
        BB = BB(length(BB(:,1)),:);
    end
    FCE = I1(BB(2):BB(2)+ BB(4),BB(1):BB(1)+BB(3)); %region only
    %visualize:
    SF = insertShape(I_color,'Rectangle',BB);
    figure(1),imshow(SF);

    %LEFT SIDE
    Lbox = [round(BB(1)-(BB(3)/2.5)+20),round(BB(2)+(BB(4)/1.5)),round(BB(3)/2.5),BB(4)/1.3];
    Lsd = I1(Lbox(2):Lbox(2)+Lbox(4),Lbox(1):Lbox(1)+Lbox(3));
    %visualize:
    SLbox = insertShape(SF,'Rectangle',Lbox);
    figure(1),imshow(SLbox);

    %RIGHT SIDE
    Rbox = [BB(1)+BB(3)-20,round(BB(2)+(BB(4)/1.5)),round(BB(3)/2.5),BB(4)/1.3];
    Rsd = I1(Rbox(2):Rbox(2)+Rbox(4),Rbox(1):Rbox(1)+Rbox(3));
    %visualize:
    SRbox=insertShape(SLbox,'Rectangle',Rbox);
    figure(1),imshow(SRbox);
    hold on
    
    Pl = [];
    for col = 1:size(Lsd,2)-5 %to average 5 columns and stay in bound
        %use average column value per row(sliding window)
        avg = [];
        for dr = 1:size(Lsd,1)
            v = mean(Lsd(dr,col:col+5)); %average 5 columns
            avg = [avg;v];
        end
        pks = fpeak([1:size(Lsd,1)],avg); %see link
       
        g = gradient(pks(:,2));
        [m,idx] = min(g); %depends on contrast:dark foreground vs bright background
        Pl = [Pl;[Lbox(2)+pks(idx-1,1),Lbox(1)+col]];
    end
    Pr = [];
    for col = 1:size(Rsd,2)-5 %to average 5 columns and stay in bound
        %use average column value per row(sliding window)
        avg = [];
        for dr = 1:size(Rsd,1)
            v = mean(Rsd(dr,col:col+5)); %average 5 columns
            avg = [avg;v];
        end
        pks = fpeak([1:size(Rsd,1)],avg); %see link

        g = gradient(pks(:,2));
        [m,idx] = min(g); %depends on contrast:dark foreground vs bright background
        Pr = [Pr;[Rbox(2)+pks(idx-1,1),Rbox(1)+col]];
    end

    %figure(2),imshow(I1),hold on,plot(Pl(:,2),Pl(:,1),'b.'),plot(Pr(:,2),Pr(:,1),'b.')

    %FIT LINE (polynomial n=1)
    pL = polyfit(Pl(:,2),Pl(:,1),1);
    xL = [min(Pl(:,2)):max(Pl(:,2))]; %from one end to the other
    rowvalL = polyval(pL,xL);
    pR = polyfit(Pr(:,2),Pr(:,1),1);
    xR = [min(Pr(:,2)):max(Pr(:,2))]; %from one end to the other
    rowvalR = polyval(pR,xR);

    fig = figure(1);
    hold on 
    
    % Determine if the shoulder starts to move, threshold = 21, plot with
    % different color
    if (abs(rowvalL_base(1)- rowvalL(1)) < 21) && (abs(rowvalR_base(end)- rowvalR(end)) < 21)     
        plot(xL,rowvalL,'r','LineWidth', 4), plot(xR,rowvalR,'r','LineWidth', 4)
    elseif (abs(rowvalL_base(1)- rowvalL(1)) < 21) && (abs(rowvalR_base(end)- rowvalR(end)) > 21)
        plot(xL,rowvalL,'r','LineWidth', 4), plot(xR,rowvalR,'c','LineWidth', 4)
    elseif (abs(rowvalL_base(1)- rowvalL(1)) > 21) && (abs(rowvalR_base(end)- rowvalR(end)) < 21)
        plot(xL,rowvalL,'c','LineWidth', 4), plot(xR,rowvalR,'r','LineWidth', 4)
    elseif (abs(rowvalL_base(1)- rowvalL(1)) > 21) && (abs(rowvalR_base(end)- rowvalR(end)) > 21)
        plot(xL,rowvalL,'c','LineWidth', 4), plot(xR,rowvalR,'c','LineWidth', 4)    
    end
    
    frame = getframe(fig); 
    img = frame2im(frame);
    img = imresize(img,[720 1280]);
    imwrite(img,[num2str(i),'.jpg']); 

    % close the figure window to fix the memory issue
    close;
    %-------------------------------------------------------------------------------
        
 end
 
 % Combine all the images(frames) to make the video
 vedio = VideoWriter('Tsai_tracking shoulders'); 
 vedio.FrameRate = 30;
 open(vedio);
 for i = 1 : numFrames  
     fname = strcat([num2str(i,'%d'),'.jpg']);
     frame = imread(fname);
     writeVideo(vedio,frame);
 end
 close(vedio);
 