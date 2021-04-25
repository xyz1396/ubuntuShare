%% Changing working directory in matlab to current script dir with running blocks 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));
% initialize no update
% initCobraToolbox(false);

%% read sbml
filename = '12918_2009_420_MOESM3_ESM.XML';
% iSR432
isr=readSBML(filename,1000);

%% output sbml
% check
% missingFields:
% genes
% rules
verifyModel(isr);
% repair
writeCbModel(isr, 'format','sbml','fileName','isr_repaired.xml');

%% check model
printUptakeBound(isr)
printConstraints(isr,-1000,1000)
% output medium
% 234 id: h[Extraorganism] 
% 205 id: cellobiose[Extraorganism] 
for a=1:length(isr.mets)
    id=isr.mets{a};
    % metNames is empty
    % name=isr.metNames{a};
    if contains(id,'[Extraorganism]')
        fprintf('%d id: %s \n',a, id);
    end
end

%% output medium reactions
% 239 ESC_h_e id: . escape flux
% 505 SRC_cellulose_e id: . source flux
for a=1:length(isr.rxns)
    id=isr.rxns{a};
    % metNames is empty
    name=isr.rxnNames{a};
    if contains(id,'_e')
        fprintf('%d %s id: %s \n',a, id, name);
    end
end

%% add constrain
isr = changeRxnBounds(isr,'SRC_cellulose_e',2.2472,'b');

%% anaerobic FBA
FBAsolution = optimizeCbModel(isr,'max');

%% output exchange flux
fluxData = FBAsolution.v;
excFlag = 1;
formulaFlag=0;
nonZeroFlag=0;
printFluxVector(isr, fluxData, nonZeroFlag, excFlag,formulaFlag)