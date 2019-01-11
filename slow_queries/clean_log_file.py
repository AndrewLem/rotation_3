import re


def main():
    log_file = 'collated_logs.txt'
    out_file = 'slow_query_logs.txt'

    with open(log_file, 'r') as f:
        file_string = f.read()

    file_string = re.sub(';', '', file_string, 0, re.I)
    file_string = re.sub('2018-\d\d-\d\d \d\d:\d\d:\d\d UTC', ';', file_string, 0, re.I)
    file_string = re.sub('\n', '', file_string, 0, re.I)
    file_string = re.sub(';', ';\n', file_string, 0, re.I)

    lines = file_string.split('\n')
    filtered_lines = [line for line in lines if include_line_check(line)]
    write_string = '\n'.join(filtered_lines)

    write_string = re.sub(' ms  statement: ', '\n', write_string, 0, re.I)

    with open(out_file, 'w') as f_out:
        f_out.write(write_string)


def include_line_check(line):
    """

    :param line: string from list
    :return: boolean value based on below conditions
    """
    return re.search('duration:', line) and not (re.search('COPY', line) or
                                                 re.search('count\(.*\)', line) or
                                                 re.search('vacuum', line) or
                                                 re.search('create', line))
    # return not (re.search('^.*connection.*', line, re.I) or
    #             re.search('^.*out of shared memory.*', line, re.I) or
    #             re.search('^.*statement: +COPY.*', line, re.I) or
    #             re.search('^.*statement: create.*', line, re.I) or
    #             re.search('^.*statement: vacuum.*', line, re.I) or
    #             re.search('^.*statement: analyse.*', line, re.I) or
    #             re.search('^\s*CONTEXT:.*', line, re.I) or
    #             re.search('^\s*DETAIL:.*', line, re.I) or
    #             re.search('^\s*FATAL:.*', line, re.I) or
    #             re.search('^\s*ERROR:.*', line, re.I) or
    #             re.search('^\s*HINT:.*', line, re.I) or
    #             re.search('^\s*LOG:  checkpoint.*', line, re.I) or
    #             re.search('^\s*LOG:  automatic.*', line, re.I) or
    #             re.search('^.*count\(.*\).*', line, re.I) or
    #             re.search('^.*temporary file: path.*', line, re.I) or
    #             re.search('^.*could not send data.*', line, re.I) or
    #             re.search('^\s*;\s*', line, re.I))


if __name__ == '__main__':
    main()
