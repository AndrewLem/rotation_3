import re


def main():
    log_file = 'collated_logs.log'
    out_file = 'slow_query_logs.tsv'

    with open(log_file, 'r') as f:
        file_string = f.read()

    # remove semicolons as they do not exist in the queries that we're interested in
    file_string = re.sub(';', '', file_string, 0, re.I)
    # change the log timestamp to semicolons, semicolons are going to be our 'new log entry' identifier
    file_string = re.sub('2018-\d\d-\d\d \d\d:\d\d:\d\d UTC', ';', file_string, 0, re.I)
    # replace all white space (new lines, tabs and multiple spaces) with a single space
    file_string = re.sub('\s+', ' ', file_string, 0, re.I)
    # using semicolons as our marker, separate all log entries onto individual lines
    file_string = re.sub(';', ';\n', file_string, 0, re.I)
    # last line would be missing a semicolon
    file_string = file_string + ';'
    # split the string into lines for filtering
    lines = file_string.split('\n')
    # filter the lines using the include_line_check function
    filtered_lines = [line for line in lines if include_line_check(line)]
    # add Duration and Query column headings
    filtered_lines.reverse()
    filtered_lines.append('Duration\tQuery')
    filtered_lines.reverse()
    # join the lines back into one string
    write_string = '\n'.join(filtered_lines)

    write_string = re.sub(' ms statement: ', '\t', write_string, 0, re.I)
    write_string = re.sub(' LOG: duration: ', '', write_string, 0, re.I)

    with open(out_file, 'w') as f_out:
        f_out.write(write_string)


def include_line_check(line):
    """

    :param line: string from list
    :return: boolean value based on below conditions
    includes:
        duration
    excludes:
        copy
        count(*)
        vacuum
        analyse
        create
    """
    return re.search('duration:', line) and not (re.search('COPY', line, re.I) or
                                                 re.search('count\(.*\)', line, re.I) or
                                                 re.search('vacuum', line, re.I) or
                                                 re.search('analyse', line, re.I) or
                                                 re.search('create', line, re.I))


if __name__ == '__main__':
    main()
