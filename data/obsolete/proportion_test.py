proportion = 0.33333333333
total = 30

full_count = 0
chosen_count = 0
for i in range(total):
    full_count += 1
    if chosen_count / full_count > proportion:
        print(i)
    else:
        chosen_count += 1
    