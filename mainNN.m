clc
clear all
close all

C=xlsread('train.xlsx');

Open = C(:,1);
Open = Open.';


High = C(:,2);
High = High.';


Low = C(:,3);
Low = Low.';


Close = C(:,4);
Close = Close.';


SMA_10 = tsmovavg(Open,'s',10);
SMA_50 = tsmovavg(Open,'s',50);


EMA_10 = tsmovavg(Open,'e',10);
EMA_50 = tsmovavg(Open,'e',50);


Input = {Open; High; Low; SMA_10; EMA_10; SMA_50; EMA_50};
Input = cell2mat(Input);


net = newff([minmax(Open); minmax(High); minmax(Low); minmax(SMA_10); minmax(EMA_10); minmax(SMA_50); minmax(EMA_50)], [abs(floor(7)), 1],{'purelin', 'purelin', 'transIm'},'traingdx');


net.trainparam.epochs = 8000;


net.trainparam.goal = 1e-5;


net.trainparam.lr = 0.001;


net.divideFcn ='dividetrain';
net = train(net, Input, Close);
t = net(Input);



perf = perform(net, Close, t);
view(net);


x = 1:size(Close,2);
plot(x, Close, x, Open, x, High, x, Low);

%% Testing the constructed neural network


C_t = xlsread('test.xlsx');


Open_t = C_t(:,1);
Open_t = Open_t.';
High_t = C_t(:,2);
High_t = High_t.';
Low_t = C_t(:,3);
Low_t = Low_t.';
Close_t = C_t(:,4);
Close_t = Close_t.';
ma=50;
SMA_10_t = tsmovavg(Open_t, 's', 10);
SMA_50_t = tsmovavg(Open_t, 's', 50);
EMA_10_t = tsmovavg(Open_t, 'e', 10);
EMA_50_t = tsmovavg(Open_t, 'e', 50);

Input_t = {Open_t; High_t; Low_t; SMA_10_t; EMA_10_t; SMA_50_t; EMA_50_t};

Open_t = C_t(:,1);
Input_t = cell2mat(Input_t);


answer = ones(1, size(Close_t, 2));
answer_t = ones(1, size(Close_t, 2));
for i=1:size(Close_t, 2)
    answer(i) = net([Input_t(1, i); Input_t(2,i); Input_t(3, i); Input_t(4, i); Input_t(5, i); Input_t(6, i); Input_t(7, i)]);
    answer_t(i) = Close_t(i);
end
x = 1:size(answer(ma:end), 2);
plot(x, [answer(ma:end-50)  answer(end-50:end-1)*NaN], x, answer_t(ma:end));
axis([0 200 -2 2])
legend('Actual Value','PredictedValue')
xlabel('Data Points');
ylabel('Closing Stock Market Value');
title('Stock Market Prediction using Neural Networks');


acc=corr(answer(ma:end)',answer_t(ma:end)');

pr=sprintf('Accuracy is %2f',acc);

msgbox(pr)


