import math

def my_sin(theta):
    theta = math.fmod(theta + math.pi, 2 * math.pi) - math.pi
    result = 0
    termsign = 1
    power = 1

    for i in range(10):
        result += (math.pow(theta, power) / math.factorial(power)) * termsign
        termsign *= -1
        power += 2
    return result

def my_cos(theta):
    theta = math.fmod(theta + math.pi, 2 * math.pi) - math.pi
    result = 0
    termsign = 1
    power = 0

    for i in range(10):
        result += (math.pow(theta, power) / math.factorial(power)) * termsign
        termsign *= -1
        power += 2
    return result

def my_tan(theta):
    return my_sin(theta) / my_cos(theta)

print(my_sin(101))
print(math.sin(101))

print(my_cos(101))
print(math.cos(101))

print(my_tan(101))
print(math.tan(101))
