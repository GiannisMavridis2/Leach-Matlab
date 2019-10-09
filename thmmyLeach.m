%thmmyLeach
clear;
%create the field 100x100 mXm
xm=100;
ym=100;
%x and y Coordinates of the Sink   
sink.x=0.5*xm;
sink.y=0.5*ym;
%Number of Nodes in the field
n=100;
%Optimal Election Probability of a node to become cluster head
p=0.1;
%Initial Energy of a node
Eo=19440;%joules
%number of rounds
r=200;
%Creation of the random Sensor Network
figure(1);
for i=1:1:n
    %the coordinates toy i-ostoy node are...
    S(i).x=rand*xm;
    S(i).y=rand*ym;
    S(i).type='member';
    %ποσοι γυροι εχουν περασει απο τοτε που εγινε CH last time
    %το 1000 σημαίνει οτι δεν εγινε ποτε CH
    S(i).roundsCH=1000;
    %the node's initial energy
    S(i).E=Eo;
    %the node's initial cluster
    S(i).cluster=0;
    plot(S(i).x,S(i).y,'ob');
    hold on;
end
S(n+1).x=sink.x;
S(n+1).y=sink.y;
plot(S(n+1).x,S(n+1).y,'xr');
hold on;
pause(2);
%start working...for each round
for gyro=1:1:r 
   cntrCH=0;%counter for CHs
   %elect the CHs
   for i=1:1:n
     %if the node is alive  
     if(S(i).E>0)
       temp_rand=rand;  
       %if the node hasn't been CH for the previous 100*P rounds
       if (strcmp(S(i).type,'member'))
         if(temp_rand<= (p/(1-p*mod(gyro,round(1/p)))))
             S(i).type='CH';
             S(i).roundsCH=0;
             plotTheNet(n,S);
             %fill the CH array
             cntrCH=cntrCH+1;
             chArray(cntrCH).x=S(i).x;
             chArray(cntrCH).y=S(i).y;
             %each CH broadcasts an ADVERTISMENT message
             S(i).E=S(i).E-0.00000666;
          end   
       elseif strcmp(S(i).type,'CH_before')
           S(i).roundsCH=S(i).roundsCH+1;
           if S(i).roundsCH==p*100
              %περασαν 100*p γυροι που ειχε γινει CH 
              S(i).type='member';
              plotTheNet(n,S);    
           else
              S(i).type='CH_before';
              plotTheNet(n,S);
           end
       else
           %εδω μπαινει αν S(i).type=='CH'
           S(i).type='CH_before';
           S(i).roundsCH=1;
           plotTheNet(n,S);
       end
     else
        %one node is dead 
     end
   end
   pause(2);
   %clusters formation
   for i=1:1:n
      if (strcmp(S(i).type,'member') || strcmp(S(i).type,'CH_before'))
          %για καθε κομβο υπολογιζουμε τις αποστασεις του απο τα CHs 
          for j=1:1:cntrCH
              dist(j)=sqrt( ( S(i).x - chArray(j).x )^2 + ( S(i).y - chArray(j).y )^2 );                
          end    
          %βρισκουμε τη min αποσταση 
          min=dist(1);
          temp=1;
          for j=2:1:cntrCH
              if dist(j) < min 
                min=dist(j);
                temp=j;
              end    
          end    
          S(i).cluster=temp;
          %each non CH transmits a JOIN-REQ message back to its chosen CH
          S(i).E=S(i).E-0.00000666;
      end    
   end  
   %data gathering,each member transmits its data to its CH
   for i=1:n
     if (strcmp(S(i).type,'member') || strcmp(S(i).type,'CH_before'))
          S(i).E=S(i).E-0.00000666;
     end    
   end
   %data sinking,each CH transmits its data to the BS(sink)
   for i=1:n
       if (strcmp(S(i).type,'CH'))
          S(i).E=S(i).E-0.00000666;
       end    
   end    
end    


function plotTheNet(n,S)
  hold off;
  plot(S(n+1).x,S(n+1).y,'xr');
  hold on;
  for j=1:1:n
    if (strcmp(S(j).type,'member') || strcmp(S(j).type,'CH_before')) 
           plot(S(j).x,S(j).y,'ob');
           hold on;
     else 
           plot(S(j).x,S(j).y,'*g');
           hold on;
    end    
  end    
end
