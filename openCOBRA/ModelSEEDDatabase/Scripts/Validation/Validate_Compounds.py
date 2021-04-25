#! /usr/bin/env python

import argparse
import re
import sys

from rdkit import RDLogger
from rdkit.Chem import AllChem

from repostat.stash import StatStash
from .error_reporting import find_new_errors, report_errors
from ..Biochem_Helper import BiochemHelper

desc1 = '''
NAME
      Validate_Compounds -- validate a compounds file

SYNOPSIS
'''

desc2 = '''
DESCRIPTION
      Validate a compounds file by checking for duplicate IDs and names, missing
      formulas, and invalid charges.  The cpdfile argument specifies the path
      to a compounds file which describes the compounds in a biochemistry.  The
      first line of the file is a header with the field names.  There is one
      compound per line with fields separated by tabs.

      The --charge optional argument specifies a value for invalid charges.  When
      the absolute value of the charge from the compound is larger than the value,
      the charge is invalid.  The default value is 50.

      When the --show-details optional argument is specified, details on all
      problems are displayed.  When the other --show optional arguments are
      specified, details on the corresponding type of problem are displayed.

      When the --fix-dup-names optional argument is specified, duplicate names
      are fixed by appending the string " (dupN)" to the name and abbreviation
      of duplicate compounds (where N is a number starting with 2).  The compounds
      file is rewritten with the fixed data.
'''

desc3 = '''
EXAMPLES
      Show summary data about a compounds file:
      > Validate_Compounds.py compounds.tsv
      
      Show details on compounds that have problems:
      > Validate_Compounds.py --show-details compounds.tsv

SEE ALSO
      Validate_Reactions

AUTHORS
      Mike Mundy 
'''

if __name__ == "__main__":
    # Parse options.
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter, prog='Validate_Compounds', epilog=desc3)
    parser.add_argument('cpdfile', help='path to compounds file', action='store')
    parser.add_argument('--charge', help='flag compounds with charge larger than value', action='store', dest='charge', type=int, default=50)
    parser.add_argument('--show-details', help='show details on all problems', action='store_true', dest='showDetails', default=False)
    parser.add_argument('--show-dup-ids', help='show details on duplicate IDs', action='store_true', dest='showDupIds', default=False)
    parser.add_argument('--show-bad-ids', help='show details on bad IDs', action='store_true', dest='showBadIds', default=False)
    parser.add_argument('--show-dup-names', help='show details on duplicate names', action='store_true', dest='showDupNames', default=False)
    parser.add_argument('--show-bad-names', help='show details on bad names', action='store_true', dest='showBadNames', default=False)
    parser.add_argument('--show-dup-abbrs', help='show details on duplicate abbreviations', action='store_true', dest='showDupAbbrs', default=False)
    parser.add_argument('--show-bad-abbrs', help='show details on bad abbreviations', action='store_true', dest='showBadAbbrs', default=False)
    parser.add_argument('--show-formulas', help='show details on missing formulas', action='store_true', dest='showFormulas', default=False)
    parser.add_argument('--show-charges', help='show details on invalid charges', action='store_true', dest='showCharges', default=False)
    parser.add_argument('--show-dup-compounds', help='show details on duplicate compounds', action='store_true', dest='showDupStruct', default=False)
    parser.add_argument('--show-cofactors', help='show details on invalid cofactors', action='store_true', dest='showCofactors', default=False)
    parser.add_argument('--fix-dup-names', help='fix on duplicate names', action='store_true', dest='fixDupNames', default=False)
    usage = parser.format_usage()
    parser.description = desc1 + '      ' + usage + desc2
    parser.usage = argparse.SUPPRESS
    args = parser.parse_args()

    # The --show-details option turns on all of the detail options.
    if args.showDetails:
        args.showDupIds = True
        args.showBadIds = True
        args.showDupNames = True
        args.showBadNames = True
        args.showDupAbbrs = True
        args.showBadAbbrs = True
        args.showFormulas = True
        args.showCharges = True
        args.showDupStruct = True
        args.showCofactors = True

    # Read the compounds from the specified file.
    print('Compound file: %s' % args.cpdfile)
    helper = BiochemHelper()
    compounds = helper.readCompoundsFile(args.cpdfile)
    if compounds is None:
        print('Error reading compounds file')
        exit(1)
    print('Number of compounds: %d' % len(compounds))

    # Create a dictionary keyed by id for fast lookup of compounds.
    compoundDict = helper.buildIndexDictFromListOfObjects(compounds)

    # Suppress RDKit output
    lg = RDLogger.logger()
    lg.setLevel(RDLogger.CRITICAL)

    # Check for duplicates, missing and invalid values.
    idDict = dict()
    duplicateId = 0
    badIdChars = list()
    nameDict = dict()
    duplicateName = 0
    badNameChars = list()
    abbrDict = dict()
    duplicateAbbr = 0
    badAbbrChars = list()
    noFormula = list()
    inconsistentFormula = dict()
    largeCharge = list()
    noCharge = list()
    structureDict = dict()
    noStructure = list()
    duplicateStructure = dict()
    badCore = list()
    numCore = 0
    badObsolete = list()
    numObsolete = 0
    badLink = list()
    badCofactor = list()
    numCofactors = 0
    unknownDeltag = list()
    unknownDeltagErr = list()
    zeroDeltag = list()
    zeroDeltagErr = list()

    for index in range(len(compounds)):
        cpd = compounds[index]
        # Check for invalid is_obsolete flags. If obsolete, don't bother checking anything else
        if cpd['is_obsolete'] != 0 and cpd['is_obsolete'] != 1:
            badObsolete.append(index)
        if cpd['is_obsolete'] == 1:
            numObsolete += 1
            continue
        
        # Check for duplicate IDs.
        if cpd['id'] in idDict:
            if len(idDict[cpd['id']]) == 1:
                duplicateId += 1
            idDict[cpd['id']].append(index)
        else:
            idDict[cpd['id']] = [index]

        # Check for invalid characters in the ID.
        match = re.search(r'^cpd\d\d\d\d\d$', cpd['id'])
        if match is None:
            badIdChars.append(index)

        # Check for duplicate names.
        if cpd['name'] in nameDict:
            if len(nameDict[cpd['name']]) == 1:
                duplicateName += 1
            nameDict[cpd['name']].append(index)
        else:
            nameDict[cpd['name']] = [index]

        # Check for invalid characters in the name.
        try:
            cpd['name'].encode('ascii')
        except UnicodeEncodeError:
            badNameChars.append(index)
        if cpd['name'] != cpd['name'].strip():
            badNameChars.append(index)

        # Check for duplicate abbreviations.
        if cpd['abbreviation'] in abbrDict:
            if len(abbrDict[cpd['abbreviation']]) == 1:
                duplicateAbbr += 1
            abbrDict[cpd['abbreviation']].append(index)
        else:
            abbrDict[cpd['abbreviation']] = [index]

        # Check for invalid characters in the abbreviation.
        try:
            cpd['abbreviation'].encode('ascii')
        except UnicodeEncodeError:
            badAbbrChars.append(index)
        if cpd['abbreviation'] != cpd['abbreviation'].strip():
            badNameChars.append(index)

        # Check for missing or unknown formulas.
        if cpd['formula'] == '' or cpd['formula'] == 'noformula' or cpd['formula'] == 'unknown':
            noFormula.append(index)

        # Check for duplicate and missing compound structures.
        mol = AllChem.MolFromInchi(cpd['smiles'])
        if mol:
            inchikey = AllChem.InchiToInchiKey(cpd['smiles'])
            if inchikey in structureDict:
                if inchikey not in duplicateStructure:
                    duplicateStructure[inchikey] = [structureDict[inchikey]]
                duplicateStructure[inchikey].append(index)
            else:
                structureDict[inchikey] = index
            if cpd['formula'] != AllChem.CalcMolFormula(mol):
                inconsistentFormula[index] = (cpd['formula'], AllChem.CalcMolFormula(mol))
        else:
            noStructure.append(index)

        # Check for charges that are too big.
        if 'charge' in cpd:
            if abs(cpd['charge']) > args.charge:
                largeCharge.append(index)
        else:
            noCharge.append(index)

        # Check for invalid is_core flags.
        if cpd['is_core'] != 0 and cpd['is_core'] != 1:
            badCore.append(index)
        if cpd['is_core'] == 1:
            numCore += 1

        # Check that linked reactions are all valid.
        if 'linked_compound' in cpd:
            linkedCpds = cpd['linked_compound'].split(';')
            for cpdid in linkedCpds:
                if cpdid not in compoundDict:
                    badLink.append(index)

        # Check for invalid is_cofactor flags.
        if cpd['is_cofactor'] != 0 and cpd['is_cofactor'] != 1:
            badCofactor.append(index)
        if cpd['is_cofactor'] == 1:
            numCofactors += 1

        # Check for unknown deltaG and deltaGerr values.
        if 'deltag' in cpd:
            if cpd['deltag'] == float(0):
                zeroDeltag.append(index)
        else:
            unknownDeltag.append(index)
        if 'deltagerr' in cpd:
            if cpd['deltagerr'] == float(0):
                zeroDeltagErr.append(index)
        else:
            unknownDeltagErr.append(index)

    # Print summary data.
    print('Number of compounds with duplicate IDs: %d' % duplicateId)
    print('Number of compounds with bad characters in ID: %d' % len(badIdChars))
    print('Number of compounds with duplicate names: %d' % duplicateName)
    print('Number of compounds with bad characters in name: %d' % len(badNameChars))
    print('Number of compounds with duplicate abbreviations: %d' % duplicateAbbr)
    print('Number of compounds with bad characters in abbreviation: %d' % len(badAbbrChars))
    print('Number of compounds with no formula: %d' % len(noFormula))
    print('Number of compounds with inconsistent formula and structure: %d' % len(inconsistentFormula))
    print('Number of compounds with charge larger than %d: %d' % (args.charge, len(largeCharge)))
    print('Number of compounds with no charge: %d' % len(noCharge))
    print('Number of compounds with no structure: %d' % len(noStructure))
    print('Number of compounds with duplicate structure: %d' % len(duplicateStructure))
    print('Number of compounds with bad is_core flag: %d' % len(badCore))
    print('Number of compounds flagged as core: %d' % numCore)
    print('Number of compounds with bad is_obsolete flag: %d' % len(badObsolete))
    print('Number of compounds flagged as obsolete: %d' % numObsolete)
    print('Number of compounds with bad links : %d' % len(badLink))
    print('Number of compounds with bad is_cofactor flag: %d' % len(badCofactor))
    print('Number of compounds flagged as cofactor: %d' % numCofactors)
    print('Number of compounds with unknown deltaG value: %d' % len(unknownDeltag))
    print('Number of compounds with zero deltaG value: %d' % len(zeroDeltag))
    print('Number of compounds with unknown deltaGErr value: %d' % len(unknownDeltagErr))
    print('Number of compounds with zero deltaGErr value: %d' % len(zeroDeltagErr))
    print()

    # Print details if requested.
    if args.showDupIds:
        for id in idDict:
            if len(idDict[id]) > 1:
                print('Duplicate compound ID: %s' % id)
                for dup in idDict[id]:
                    print('Line %05d: %s' % (compounds[dup]['linenum'], compounds[dup]))
                print()
    if args.showBadIds:
        if len(badIdChars) > 0:
            print('Compounds with bad characters in ID:')
            for index in range(len(badIdChars)):
                print('Line %05d: %s' % (compounds[badIdChars[index]]['linenum'], compounds[badIdChars[index]]))
            print()
    if args.showDupNames:
        for name in nameDict:
            if len(nameDict[name]) > 1:
                print('Duplicate compound name: %s' % name)
                for dup in nameDict[name]:
                    print('Line %05d: %s' % (compounds[dup]['linenum'], compounds[dup]['id']))
                print()
    if args.showBadNames:
        if len(badNameChars) > 0:
            print('Compounds with bad characters in name:')
            for index in range(len(badNameChars)):
                print('Line %05d: %s' % (compounds[badNameChars[index]]['linenum'], compounds[badNameChars[index]]['id']))
            print()
    if args.showDupAbbrs:
        for abbr in abbrDict:
            if len(abbrDict[abbr]) > 1:
                print('Duplicate compound abbreviation: %s' % abbr)
                for dup in abbrDict[abbr]:
                    print('Line %05d: %s' % (compounds[dup]['linenum'], compounds[dup]['id']))
                print()
    if args.showBadAbbrs:
        if len(badAbbrChars) > 0:
            print('Compounds with bad characters in abbreviation:')
            for index in range(len(badAbbrChars)):
                print('Line %05d: %s' % (compounds[badAbbrChars[index]]['linenum'], compounds[badAbbrChars[index]]))
            print()
    if args.showFormulas:
        if len(noFormula) > 0:
            print('Compounds with no formula:')
            for index in range(len(noFormula)):
                print('Line %05d: %s' % (compounds[noFormula[index]]['linenum'], compounds[noFormula[index]]))
            print()
        if len(inconsistentFormula) > 0:
            print('Compounds with formulas that do not match their structures')
            for index in inconsistentFormula:
                print('%s: %s, %s' % (compounds[index]['id'], inconsistentFormula[index][0], inconsistentFormula[index][1]))
            print()
    if args.showCharges:
        if len(largeCharge) > 0:
            print('Compounds with charge larger than %d:' %(args.charge))
            for index in range(len(largeCharge)):
                print('Line %05d: %s' % (compounds[largeCharge[index]]['linenum'], compounds[largeCharge[index]]))
            print()

    if args.showDupStruct:
        for inchikey, indices in duplicateStructure.items():
            print('Duplicated chemical structure: %s' % inchikey)
            for index in indices:
                print('Line %05d: %s' % (compounds[index]['linenum'], compounds[index]['id']))
            print()

    if args.showCofactors:
        if len(badCofactor) > 0:
            print('Compounds with bad isCofactor flag:')
            for index in range(len(badCofactor)):
                print('Line %05d: %s' % (compounds[badCofactor[index]]['linenum'], compounds[badCofactor[index]]))
            print()

    if args.fixDupNames:
        for name in nameDict:
            if len(nameDict[name]) > 1:
                for index in range(1, len(nameDict[name])): # Leave the first duplicate unchanged
                    dup = nameDict[name][index]
                    compounds[dup]['name'] += ' (dup%d)' % (index+1)
                    compounds[dup]['abbreviation'] = compounds[dup]['name']
                    if compounds[dup]['formula'] != compounds[nameDict[name][0]]['formula']:
                        print('WARNING: formula mismatch')
                        print('Line %05d: %s' % (compounds[nameDict[name][0]]['linenum'], compounds[nameDict[name][0]]))
                        print('Line %05d: %s' % (compounds[dup]['linenum'], compounds[dup]))

        with open(args.cpdfile, 'w') as handle:
            handle.write('id\tname\tabbreviation\tformula\tcharge\tisCofactor\n')
            for index in range(len(compounds)):
                cpd = compounds[index]
                line = '%s\t%s\t%s\t%s\t%d\t%d\n' % (cpd['id'], cpd['name'], cpd['abbreviation'], cpd['formula'], cpd['defaultCharge'], cpd['isCofactor'])
                handle.write(line)

    error_fields = ['duplicateId', 'duplicateAbbr', 'duplicateName',
                    'duplicateStructure', 'noCharge', 'badIdChars',
                    'badAbbrChars', 'badCofactor', 'badCore', 'badLink',
                    'badNameChars', 'badObsolete', 'inconsistentFormula']
    errors = dict([(x, eval(x)) if isinstance(eval(x), int)
                   else (x, len(eval(x)))for x in error_fields])
    new_errors = find_new_errors('compounds', errors)
    report_errors('compounds', errors)
    stash = StatStash('redis://redis-16221.c12.us-east-1-4.ec2.cloud.redislabs.com:16221')
    stash.report_stats('compounds', errors)

    if new_errors:
        print("NEW ERRORS: " + ", ".join(new_errors), file=sys.stderr)
        exit(1)
