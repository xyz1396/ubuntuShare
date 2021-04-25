import keen
import subprocess
import copy
from collections import defaultdict

keen.project_id = "594bd6a50935ce9ceaaaaf63"
keen.read_key = '7856E5E161A29A43701E1F65BCCB6FDD1C0DF3B3624A5212C9946D8419C98A6E8F32D0BEA5616B60E92C4567571E23B32EAF7438458814654F7DE37F885E59D15F434D19C386D975F907B890F9F546D1CE2D3DA2F400C437557150639A37AF4B'
keen.write_key = "C32909E224E40349F0EDF73F18D1ED18EDCF28B2831DA2C45A5EBF07FEA9BC61243413CC58120C65D58CC488E711B351D1CA43C97035565E6BA854C536E6AACC6E3BB1FA6034BEB8DF905628463AF380BB90A497C87ACDBB21D18F7F5A41B93B"

local_head = subprocess.check_output(['git', 'log', '-n', '1', '--pretty=format:%H']).decode("utf-8")
current_branch = subprocess.check_output(['git', 'rev-parse', '--abbrev-ref', 'HEAD']).decode("utf-8").strip()


def get_master_errors(stream):
    hit = keen.extraction(stream, 'this_3_years', filters=[
        {"property_name": "branch", "operator": "eq",
         "property_value": 'HEAD'}])
    if not hit:
        raise ValueError('No data for master branch found')
    return hit[-1]


def report_errors(stream, error_counts):
    error_rep = copy.copy(error_counts)
    error_rep['commit'] = local_head
    error_rep['branch'] = current_branch
    keen.add_event(stream, error_rep)


def find_new_errors(script, errors):
    master_errors = defaultdict(int)
    master_errors.update(get_master_errors(script))
    new_errors = []
    for err, val in errors.items():
        # this checks to see if any errors types get worse
        if val > master_errors[err]:
            print("%s new %s errors detected" % (val - master_errors[err], err))
            new_errors.append(err)
    return new_errors
