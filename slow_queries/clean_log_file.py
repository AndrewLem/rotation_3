import re

log_file = 'collated_logs.txt'
out_file = 'slow_query_logs.txt'

with open(out_file, 'w') as f_out:
    with open(log_file, 'r') as f_in:
        for line in f_in:
            if not (re.search('^\s*2018.*connection.*', line, re.I) or
                    re.search('^\s*2018.*out of shared memory.*', line, re.I) or
                    re.search('^\s*2018.*statement: COPY.*', line, re.I) or
                    re.search('^\s*2018.*statement:.*count\(.*\).*', line, re.I) or
                    re.search('^\s*2018.*CONTEXT:  COPY.*', line, re.I) or
                    # re.search('^\s*2018.*statement:.*count\(*.\).*', line, re.I) or
                    re.search('^\s*2018.*temporary file: path.*', line, re.I) or
                    re.search('^\s*2018.*create.*', line, re.I) or
                    re.search('^\s*2018.*UTC ERROR:.*', line, re.I) or
                    re.search('^\s*2018.*UTC DETAIL:.*', line, re.I) or
                    re.search('^\s*2018.*UTC CONTEXT:.*', line, re.I) or
                    re.search('^\s*PL/pgSQL function.*', line, re.I) or
                    re.search('^\s*2018.*automatic vacuum.*', line, re.I) or
                    re.search('^\s*2018.*automatic analyze.*', line, re.I) or
                    re.search('^\s*2018.*LOG:  checkpoint.*', line, re.I) or
                    re.search('^\s*SQL statement.*', line, re.I) or
                    re.search('^\s*pages:.*', line, re.I) or
                    re.search('^\s*tuples:.*', line, re.I) or
                    re.search('^\s*buffer usage:.*', line, re.I) or
                    re.search('^\s*avg read rate:.*', line, re.I) or
                    re.search('^\s*system usage:.*', line, re.I) or
                    re.search('^\s*cat:.*', line, re.I) or
                    re.search('^\s*tail:.*', line, re.I) or
                    re.search('^\s*2018.*could not send.*', line, re.I)):
                f_out.write(line)
#
# with open(out_file, 'r') as f:
#     file_string = f.read()
#
# file_string = re.sub('2018-\d\d-\d\d \d\d:\d\d:\d\d UTC LOG:  duration: ', ';', file_string, 0, re.I)
# file_string = re.sub('\n', '', file_string, 0, re.I)
# file_string = re.sub(';', ';\n', file_string, 0, re.I)
# file_string = re.sub(' ms  statement: ', '\n', file_string, 0, re.I)
#
# with open(out_file, 'w') as f:
#     f.write(file_string)
