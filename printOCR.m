function printOCR(Array)
for k=1:length(Array)
    if Array(k)<10
        fprintf('%d ', Array(k));
    elseif Array(k)==10
        fprintf('0 ');
    elseif Array(k)==11
        fprintf('+ ');
    elseif Array(k)==12
        fprintf('- ');
    elseif Array(k)==13
        fprintf('/ ');
    elseif Array(k)==14
        fprintf('* ');
    elseif Array(k)==15
        fprintf('^ ');
    elseif Array(k)==16
        fprintf('( ');
    elseif Array(k)==17
        fprintf(') ');
    end
end
fprintf('\n');
