function tests = test_flatten2supertrial()
    tests = functiontests(localfunctions);
end

function test_flatten2d_append2(test_case)
    dim_trial = 1;
    dim_append = 2;
    y = rand(2,1000);
    expected = horzcat(y(1,:), y(2,:));

    output = flatten2supertrial(y,dim_trial,dim_append);

    verifyEqual(test_case, output, expected);
end

function test_flatten2d_append1(test_case)
    dim_trial = 2;
    dim_append = 1;
    y = rand(1000,2);
    expected = vertcat(y(:,1), y(:,2));

    output = flatten2supertrial(y,dim_trial,dim_append);

    verifyEqual(test_case, output, expected);
end

function test_flatten3d_to_5d(test_case)
    for y_ndims = 3:5
        sz = 3:(3+y_ndims-1);
        y = reshape(1:prod(sz),sz);
        for dim_trl = 1:y_ndims
            for dim_append = setdiff(1:y_ndims,dim_trl)
                expected = [];
                for i = 1:size(y,dim_trl)
                    ind = repmat({':'},[1 ndims(y)]);
                    ind{dim_trl} = i;
                    expected = cat(dim_append, expected, y(ind{:}));
                end
                
                output = flatten2supertrial(y,dim_trl,dim_append);

                verifyEqual(test_case, output, expected, sprintf('Fail at dim_trial %i and dim_append %i', dim_trl, dim_append));
            end
        end
    end
end
