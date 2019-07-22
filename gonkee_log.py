import math

# Gonkee's log function - full tutorial https://youtu.be/PLx5VJGGwfw

def my_log(base, product, it = 20):
    # housekeeping
    if base <= 0 or base == 1 or product <= 0:
        return float('nan')
    if base == product:
        return 1
    if product == 1:
        return 0

    current_pow = 1
    closest_int = False
    while not closest_int:
        current_err = math.fabs(product - math.pow(base, current_pow))
        if current_err > math.fabs(product - math.pow(base, current_pow + 1)):
            current_pow += 1
        elif current_err > math.fabs(product - math.pow(base, current_pow - 1)):
            current_pow -= 1
        else:
            closest_int = True

    iterations = it
    pow_change = 1
    for i in range(iterations):
        pow_change /= 2
        current_err = math.fabs(product - math.pow(base, current_pow))
        if current_err > math.fabs(product - math.pow(base, current_pow + pow_change)):
            current_pow += pow_change
        elif current_err > math.fabs(product - math.pow(base, current_pow - pow_change)):
            current_pow -= pow_change
    return current_pow

print(my_log(27, 81))
print(my_log(5, 5))
print(my_log(12, 1))
print(my_log(1, 12))
print(my_log(-2, 30))
print(my_log(10, -100))
print(my_log(7, 2093486761))

for i in range(20):
    print(i, ' iterations: ', my_log(10, 0.0125, i), ' verification: ', math.pow(10, my_log(10, 0.0125, i)), ' remaining error: ', math.fabs(0.0125 - math.pow(10, my_log(10, 0.0125, i))))
