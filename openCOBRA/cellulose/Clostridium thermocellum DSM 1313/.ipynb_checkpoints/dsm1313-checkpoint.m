%% Changing working directory in matlab to current script dir with running blocks 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));
% initialize no update
% initCobraToolbox(false);

%% read sbml
filename = 'cellulose.xml';
dsm=readSBML(filename,1000);

%% output sbml
% check
verifyModel(dsm);
% repair
dsm.rules{186}='x(217) | x(216) | x(215)';
dsm.rules{421}='x(368) | x(367)';
writeCbModel(dsm, 'format','sbml','fileName','cellulose_repaired.xml');

%% check model
printUptakeBound(dsm)
printConstraints(dsm,-1000,1000)
% output medium
for a=1:length(dsm.mets)
    id=dsm.mets{a};
    name=dsm.metNames{a};
    if contains(id,'[C_e]')
        fprintf('id: %s name: %s\n', id, name);
    end
end
%% anaerobic FBA
FBAsolution = optimizeCbModel(dsm,'max');

%% output none zero flux
fluxData = FBAsolution.v;
nonZeroFlag = 1;
printFluxVector(dsm, fluxData, nonZeroFlag);

%% output exchange flux
% id: m20[C_e] name: Cellobiose_C12H22O11  
% id: m55[C_e] name: Hydrogen_H2
% id: m51[C_e] name: Ethanol_C2H6O
% id: m52[C_e] name: Acetate_C2H4O2
% id: m53[C_e] name: Formate_CH2O2
% id: m54[C_e] name: (S)-Lactate_C3H6O3
% the reaction of cellulos degradation occurs extracellularly
% id: m101[C_e] name: Glucose Eq
% id: m103[C_e] name: Glucose Eq 2
% id: m104[C_e] name: Glucose Eq 2
excFlag = 1;
formulaFlag=1;
printFluxVector(dsm, fluxData, nonZeroFlag, excFlag,formulaFlag)