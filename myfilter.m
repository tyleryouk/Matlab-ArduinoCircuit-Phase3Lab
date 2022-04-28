%%
%3B a function that computes and low pass filters the recorded data.  The
%cutoff frequency comes from the value of the numeric edit field and the
%order from the slider.  The output should be the filtered recorded data. 

function lowpass = myfilter(x,filterOrderInput,cutOffInput)

    if cutOffInput >= 1.00
      cutOffInput = 0.9999999;
    end %making sure value is between 0 and 1
    [b,a] = butter(filterOrderInput,cutOffInput);
    lowpass = filter(b,a,x);
 

    %the input data x using a rational transfer function defined by the 
    %numerator and denominator coefficients b and a

end