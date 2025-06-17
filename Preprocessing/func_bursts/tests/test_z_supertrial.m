function tests = test_z_supertrial()
    tests = functiontests(localfunctions);
end

function test_4darray_dimtrl1_dimzref4(test_case)
    trl_to_normalise = 2;
    trl_ref = 1:2;
    dim_trl = 1;
    dim_zref = 4;
    n_trl = 2;
    n_ch = 2;
    n_frq = 2;
    n_time = 2;
    sz = [n_trl n_ch n_frq n_time];
    X = randi(100,sz);
    supertrial = cat(4,X(1,:,:,:),X(2,:,:,:));
    mu = mean(supertrial,4);
    sd = std(supertrial,[],4);
    expected = (X(trl_to_normalise,:,:,:)-mu)./sd;

    output = z_supertrial(X,trl_to_normalise,trl_ref,dim_trl,dim_zref);

    verifyEqual(test_case, output, expected);
end
