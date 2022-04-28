%3A A function that computes the Fast Fourier transform (complete with
%shifting and absolute value) of the data passed to it.  The output of this
%function is the transformed and formatted data.

function ref = myfft(data)

    ref = fftshift(data)   
    %taking original data and shifting so that middle point is zero
    %(shifting x axis) 
    ref = abs(ref) %makes sure y axis is positive
    

end


