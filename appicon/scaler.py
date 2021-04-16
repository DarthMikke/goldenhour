#!/usr/bin/env python3
#-*- coding: utf-8 -*-

import os
from PIL import Image

sizes = [20, 40, 60, 58, 87, 80, 120, 180, 29, 58, 40, 80, 76, 152, 167, 1024]
done  = []

fullname = "Appicon gradient.png"
#fullname = "appicon-v2.png"
filename, extension = os.path.splitext(fullname)

im = Image.open(fullname)

for size in sizes:
	print("{} px… ".format(size), end='')
	if size in done:
		print("Already done")
		continue

	try:
		newfilename = "{}px-{}{}".format(size, filename, extension)
		newimage = im.resize((size, size))
		newimage.save(newfilename)
	except:
		print("Error")
	else:
		print("Done @ {}".format(newfilename))

	done.append(size)