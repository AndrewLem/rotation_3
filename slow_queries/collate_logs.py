log_files = ['postgresql-Sat.log',
             'postgresql-Sun.log',
             'postgresql-Mon.log',
             'postgresql-Tue.log',
             'postgresql-Wed.log',
             'postgresql-Thu.log',
             'postgresql-Fri.log']

out_file = 'collated_logs.txt'

with open(out_file, 'w') as f_out:
    for filename in log_files:
        with open(filename, 'r') as log_f:
            for line in log_f:
                f_out.write(line)

