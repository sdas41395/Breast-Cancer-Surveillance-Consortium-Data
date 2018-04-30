#!/usr/bin/env python
import sys
import os
from subprocess import call


# Querying this file to read from the ./backend/risk.txt
# This backend function is called everytime a submit is ran from the Shiny frontend. 

class cancer_lists:
	"""Class of cancer lists that will return values back to Shiny R frontend

	Variables:
		cancer_relations: can be used for future development. Basic template of risk.txt (not used)
		keys: set of keys that are edited based on constraints, risk.txt is parsed based on matching keys and values
		invasive + carcinoma: final values after parsing risk.txt
		save_result: if TRUE then save resulting data points to ./backend/saved_results.txt
	"""
	list_searches = []

	def __init__(self):
		self.cancer_relations = cancer_relations = {"menopaus" : [0]*3, "agegrp" : [0]*10, "density" : [0]*5, "race" : [0]*6, 
			"Hispanic" : [0]*3, "bmi" : [0]*5, "agefirst" : [0]*4, "nrelbc" : [0] *4, "brstproc" : [0]*3,
			"lastmamm" : [0]*3, "surgmeno" : [0]*3, "hrt" : [0]*3}

		self.keys = keys = [[0,1,9], [1,2,3,4,5,6,7,8,9,10], [1,2,3,4,9], [1,2,3,4,5,9], [0,1,9], [1,2,3,4,9], [0,1,2,9], 
				[0,1,2,9], [0,1,9], [0,1,9], [0,1,9], [0,1,9]]

		#0 is no 1 is yes
		self.invasive = [0,0]
		self.carcinoma = [0,0]	
		self.save_result = False


def file_opener():
	"""Opens risk.txt file for reading. Takes in parameters from front end and fills in parameter list 

	Args:
		None but reads in parameters from system.argv[]. Parameters should be constraints for risk.txt

	Returns:
		file_dataset: The risk.txt dataset taken from the Breast Cancer Surveillance Consortium
		parameter_list: The constraints given by the front end. Passing in the values to edit keys
		save_key: If true writes data points to saved_results.txt. If false prints nothing
	"""

	parameter_list = []																			# Local parameter_list that takes in constraints from system call

	for attribute_argument in sys.argv[1:(len(sys.argv) - 1)]:
		param_array = []
		attribute_argument = attribute_argument.split('.')
		for user_selection in attribute_argument[1:]:											# attribute_argument[1] gives the exact values for the constraint
			param_array.append(int(user_selection))
		parameter_list.append(param_array)	

	for iterator in range(len(parameter_list)):
		if len(parameter_list[iterator]) == 0:
			parameter_list[iterator] = [-1]														# Filling in non chosen constraints with values of -1. Retaining structure of keys

	print (parameter_list)

	save_key = sys.argv[13].split('.')
	save_key = save_key[1]
	print(save_key)

	file_dataset = open(".\\backend\\dataset\\risk.txt", "r")			#Opening the risk.txt file
	

	return file_dataset, parameter_list, save_key

	

def accumulate_keys(file_dataset, param_list, save_key):
	"""Storing argument passed in by file_opener into cancer_list class. 

	Args:
		file_dataset: risk.txt file
		param_list: the specific constraints given by Shiny R
		save_key: if TRUE print into saved_results

	Return:
		cancer_local: class with edited keys and save_values. Used to parse through risk.txt
	"""

	cancer_local = cancer_lists()															# Creating instance of cancer_list
	cancer_local.save_result = save_key

	for attribute_iterator in range(len(param_list)):										# Looping through constraints from user
		
		list_attributes = []

		for key_iterator in range(len(cancer_local.keys[attribute_iterator])):								# If the parameter_list returns a -1 we leave the keys at default value and move on 
			if len(param_list[attribute_iterator]) == 1 and param_list[attribute_iterator][0] == -1:
				break

			if cancer_local.keys[attribute_iterator][key_iterator] not in param_list[attribute_iterator]:		# If the key is user specified then we need to remove from the cancer list keys 
				cancer_local.keys[attribute_iterator][key_iterator] = -1

	print (cancer_local.keys)
		
	return (cancer_local)




def get_totals(file_dataset, file_output, cancer_local, saved_file):

	"""Parse risk.txt based on the cancer_list edited key values. Edits output.txt to be read by Shiny R front end

	Args:
		file_dataset: risk.txt file
		file_output: output.txt file that takes in invasive and carcinoma values
		cancer_local: cancer_list instance with edited keys
		saved_file: if save_file = TRUE, print matching lines to saved_result.txt

	Return:
		None
	"""
	for line in file_dataset:										# Reading risk.txt line by line
		saved_line = line
		line = line.split(" ")

		for iterator in line:										# Remove spaces from line list
			if iterator == "" or iterator == " ":
				line.remove(iterator)

		data_index = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
		multiple = int(line[len(line) - 1].rstrip())
		cancer_local_iterator = 0
		flag_break = 0												# flag_break ends parsing a line prematurely if a value does not agree with a key

		for iterator in range(len(data_index)):
			if int(line[iterator]) not in cancer_local.keys[iterator]:			# Comparing value on edited key 
				flag_break = 1
				break
		
		if flag_break == 0:
			if int(line[12]) == 0:									# If the keys all agree with values append to instance of cancer_list
				cancer_local.invasive[0] += multiple
			if int(line[12]) == 1:
				cancer_local.invasive[1] += multiple
			if int(line[13]) == 0:
				cancer_local.carcinoma[0] += multiple
			if int(line[13]) == 1:
				cancer_local.carcinoma[1] += multiple
			
			# if the save button is pressed keep the data

			if cancer_local.save_result == "TRUE":					# Print to saved_result.txt if needed
				saved_file.write(str(saved_line))
		

		flag_break = 0


	return



def print_output(file_output, cancer_local):
	
	"""Printing to output.txt to be read by Shiny R

	Args:
		file_output: output.txt to be read by frontend
		cancer_local: edited instance of cancer_list with invasive and carcinoma values

	Return:
		None but edits output.txt

	"""
	yes_invasive = cancer_local.invasive[1]
	no_invasive = cancer_local.invasive[0]

	yes_carcinoma = cancer_local.carcinoma[1]
	no_carcinoma = cancer_local.carcinoma[0]

	invasive_csv = str(yes_invasive) + "," + str(no_invasive)
	file_output.write(invasive_csv)
	file_output.write("\n")
	carcinoma_csv = str(yes_carcinoma) + "," + str(no_carcinoma)
	file_output.write(carcinoma_csv)

	return


def main():																							# Defining main to prevent execution upon import

	dataset, parameter_list, save_key = file_opener()
	file_output = open("output.txt", "w")
	file_saved_results = open("saved_results.txt", 'w')
	cancer_local = accumulate_keys(dataset, parameter_list, save_key)
	get_totals(dataset, file_output, cancer_local, file_saved_results)
	print_output(file_output, cancer_local)


if __name__ == '__main__':
	main()

