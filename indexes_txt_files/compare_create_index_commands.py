import difflib

print('checking 1_lat_lon_time_index')
with open('1_lat_lon_time_index.txt') as f:
    content = f.readlines()
# you may also want to remove whitespace characters like `\n` at the end of each line
content = [x.strip() for x in content]

for i in range(0, len(content) - 1):
    s = difflib.SequenceMatcher(None, content[i], content[i+1])
    if s.ratio() < 0.9:
        print('%2d, %2d: %lf' % (i, i+1, s.ratio()))


##################################################
print('checking 1_platform_index')
with open('1_platform_index.txt') as f:
    content = f.readlines()
# you may also want to remove whitespace characters like `\n` at the end of each line
content = [x.strip() for x in content]

for i in range(0, len(content) - 1):
    s = difflib.SequenceMatcher(None, content[i], content[i + 1])
    if s.ratio() < 0.9:
        print('%2d, %2d: %lf' % (i, i + 1, s.ratio()))


##################################################
print('checking 1_time_lat_lon_index')
with open('1_time_lat_lon_index.txt') as f:
    content = f.readlines()
# you may also want to remove whitespace characters like `\n` at the end of each line
content = [x.strip() for x in content]

# for i in range(0, len(content)):
#     f = open(str(i)+'.sql', 'w')
#     f.write(content[i])
#     f.close()

for i in range(0, len(content) - 1):
    s = difflib.SequenceMatcher(None, content[i], content[i+1])
    if s.ratio() < 0.9:
        print('%2d, %2d: %lf' % (i, i+1, s.ratio()))


##################################################
print('checking 3_sat_path_sat_row_time_index')
with open('3_sat_path_sat_row_time_index.txt') as f:
    content = f.readlines()
# you may also want to remove whitespace characters like `\n` at the end of each line
content = [x.strip() for x in content]

for i in range(0, len(content) - 1):
    s = difflib.SequenceMatcher(None, content[i], content[i + 1])
    if s.ratio() < 0.9:
        print('%2d, %2d: %lf' % (i, i + 1, s.ratio()))


##################################################
print('checking 3_time_lat_lon_index')
with open('3_time_lat_lon_index.txt') as f:
    content = f.readlines()
# you may also want to remove whitespace characters like `\n` at the end of each line
content = [x.strip() for x in content]

for i in range(0, len(content) - 1):
    s = difflib.SequenceMatcher(None, content[i], content[i + 1])
    if s.ratio() < 0.9:
        print('%2d, %2d: %lf' % (i, i + 1, s.ratio()))


##################################################
print('checking 4_sat_path_sat_row_time_index')
with open('4_sat_path_sat_row_time_index.txt') as f:
    content = f.readlines()
# you may also want to remove whitespace characters like `\n` at the end of each line
content = [x.strip() for x in content]

for i in range(0, len(content) - 1):
    s = difflib.SequenceMatcher(None, content[i], content[i + 1])
    if s.ratio() < 0.9:
        print('%2d, %2d: %lf' % (i, i + 1, s.ratio()))


##################################################
print('checking 4_time_lat_lon_index')
with open('4_time_lat_lon_index.txt') as f:
    content = f.readlines()
# you may also want to remove whitespace characters like `\n` at the end of each line
content = [x.strip() for x in content]

for i in range(0, len(content) - 1):
    s = difflib.SequenceMatcher(None, content[i], content[i + 1])
    if s.ratio() < 0.9:
        print('%2d, %2d: %lf' % (i, i + 1, s.ratio()))
