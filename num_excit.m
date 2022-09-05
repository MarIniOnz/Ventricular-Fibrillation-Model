function num_excited=num_excit(row,column,H_state)

% Function calculating the number of excited neighboring elements to the
% indicated element (row, column) in the H_state (50x50) matrix.

num_excited=0;

% With the following variables, we will define the coefficients for the
% loop, that will analyze the neighboring elements.

% For example, if we have a non-special row (nor 1, nor 50) or column,
% we will want to analyze the elements in +1, 0 and -1 rows and the items
% in the +1, 0 and -1 columns (without taking itself into account) 


% Which row are we using?
switch row
    case 1 
    array_row=[0,1]; % First row will not have others below
    case 50
    array_row=[-1,0]; % Last row will not have others on top
    otherwise
    array_row=[-1,0,1]; % Any other row
end

% Which column are we using?
switch column
    case 1
    array_column=[49,0,1]; % First column will have the 50th by its side
    case 50
    array_column=[-1,0,-49]; % Last column will have the 1st by its side
    otherwise
    array_column=[-1,0,1]; % Any other column
end


for i=array_row
    for j=array_column
        if ~(i==0 && j==0) % We do not use its own state.
        num_excited = num_excited + single(H_state(row+i,column+j)==3);
        end
    end
end
end
