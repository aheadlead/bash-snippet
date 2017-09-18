from datetime import datetime
from math import pi, sin

now = datetime.now()
h = now.hour
m = now.minute

x = (h * 60 + m) / 100.0
print(int( 15 * sin( 2 * pi / 14.4 * (x - 3.5)) + 15 ))

